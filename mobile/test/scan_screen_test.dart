import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:elora_mobile/core/config.dart';
import 'package:elora_mobile/core/providers.dart';
import 'package:elora_mobile/features/crop_health/scan_provider.dart';
import 'package:elora_mobile/features/crop_health/scan_screen.dart';
import 'package:elora_mobile/core/network/api_client.dart';
import 'package:elora_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';

final _capture = GlobalKey();

void main() {
  setUpAll(() async {
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  for (final language in ['en', 'si', 'ta']) {
    testWidgets(
      'Scan route, selection, unavailable result and retry in $language',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final bytes = File('test/fixtures/scan-synthetic.png')
            .readAsBytesSync();
        final keys = <String>[];
        final api = EloraApiClient(
          baseUrl: _config.apiUrl,
          token: (_) async => 'fixture-token',
          client: MockClient((request) async {
            if (request.method == 'POST') {
              keys.add(request.headers['Idempotency-Key']!);
              return http.Response(
                jsonEncode({'scan_id': '7b78da34-f80b-4de5-8ccf-08f75ac50df2'}),
                202,
              );
            }
            return http.Response(
              '{"status":"failed","result":null,"error":{"code":"MODEL_UNAVAILABLE"}}',
              200,
            );
          }),
        );
        addTearDown(api.close);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              configProvider.overrideWithValue(_config),
              initialLocaleProvider.overrideWithValue(Locale(language)),
              authStateProvider.overrideWith(
                (ref) => Stream.value(_VerifiedUser()),
              ),
              profileProvider.overrideWith((ref) async => null),
              plantsProvider.overrideWith((ref) async => []),
              apiProvider.overrideWithValue(api),
              scanImagePickerProvider.overrideWithValue(
                (source) async => XFile.fromData(bytes, name: 'synthetic.png'),
              ),
            ],
            child: RepaintBoundary(
              key: _capture,
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Banner(
                  message: 'MOCK API',
                  textStyle: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  location: BannerLocation.topEnd,
                  child: EloraApp(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(EloraApp));
        final container = ProviderScope.containerOf(context);
        container.read(routerProvider).go('/feature/crop-health');
        await tester.pumpAndSettle();
        expect(find.byType(ScanScreen), findsOneWidget);
        final gallery = find.byIcon(Icons.photo_library_outlined);
        await _reveal(tester, gallery);
        await tester.tap(gallery);
        await tester.pumpAndSettle();
        expect(container.read(scanProvider).bytes, bytes);
        await tester.runAsync(
          () => precacheImage(
            MemoryImage(bytes),
            tester.element(find.byType(ScanScreen)),
          ),
        );
        await tester.pumpAndSettle();
        final submit = find.byType(FilledButton);
        await _reveal(tester, submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(container.read(scanProvider).error, 'MODEL_UNAVAILABLE');
        expect(
          find.text('7b78da34-f80b-4de5-8ccf-08f75ac50df2'),
          findsOneWidget,
        );
        await _reveal(tester, submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(keys.length, 2);
        expect(keys.first, keys.last);
        expect(container.read(scanProvider).bytes, bytes);
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('RECORD_SCAN_DEMO')) {
          await _record(tester, 'scan-failed-$language');
        }
        // Leaving the route and returning retains the current account's selection.
        container.read(routerProvider).go('/garden');
        await tester.pumpAndSettle();
        container.read(routerProvider).go('/feature/crop-health');
        await tester.pumpAndSettle();
        expect(container.read(scanProvider).bytes, bytes);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'picker cancellation and permission failure keep the selected photo',
    (tester) async {
      var mode = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWithValue(_config),
            authStateProvider.overrideWith(
              (ref) => Stream.value(_VerifiedUser()),
            ),
            profileProvider.overrideWith((ref) async => null),
            plantsProvider.overrideWith((ref) async => []),
            scanImagePickerProvider.overrideWithValue((_) async {
              if (mode == 1) {
                throw PlatformException(code: 'camera_access_denied');
              }
              return null;
            }),
          ],
          child: const EloraApp(),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(EloraApp)),
      );
      container.read(routerProvider).go('/feature/crop-health');
      await tester.pumpAndSettle();
      final bytes = File('test/fixtures/scan-synthetic.png').readAsBytesSync();
      container.read(scanProvider.notifier).select(bytes);
      await tester.pumpAndSettle();
      final key = container.read(scanProvider).operationId;
      final gallery = find.byIcon(Icons.photo_library_outlined);
      await _reveal(tester, gallery);
      await tester.tap(gallery);
      await tester.pumpAndSettle();
      expect(container.read(scanProvider).operationId, key);
      mode = 1;
      await tester.tap(gallery);
      await tester.pumpAndSettle();
      expect(container.read(scanProvider).bytes, bytes);
      expect(find.textContaining('Photo access failed'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find
          .descendant(
            of: find.byType(ScanScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}

Future<void> _record(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary =
        _capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final output = File('../tmp/issue44/$name.png');
    await output.parent.create(recursive: true);
    await output.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

class _VerifiedUser extends Fake implements User {
  @override
  String get uid => 'widget-fixture-user';
  @override
  bool get emailVerified => true;
}

const _config = AppConfig(
  apiUrl: 'https://example.test',
  firebaseApiKey: 'fixture',
  firebaseAppId: 'fixture',
  firebaseSenderId: 'fixture',
  firebaseProjectId: 'fixture',
);
