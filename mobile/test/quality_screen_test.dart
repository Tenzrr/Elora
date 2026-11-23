import 'dart:convert';
import 'dart:io';

import 'package:elora_mobile/core/config.dart';
import 'package:elora_mobile/core/network/api_client.dart';
import 'package:elora_mobile/core/providers.dart';
import 'package:elora_mobile/core/theme/app_theme.dart';
import 'package:elora_mobile/features/produce_quality/quality_models.dart';
import 'package:elora_mobile/features/produce_quality/quality_provider.dart';
import 'package:elora_mobile/features/produce_quality/quality_screen.dart';
import 'package:elora_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';

const _scanId = '5f3c8e2a-7b1d-4c9a-9e4f-1a2b3c4d5e6f';

void main() {
  setUpAll(() async {
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  testWidgets('quality route shows subtype choices, pickers and fixtures', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWithValue(_config),
          authStateProvider.overrideWith(
            (ref) => Stream.value(_VerifiedUser()),
          ),
          profileProvider.overrideWith((ref) async => null),
          plantsProvider.overrideWith((ref) async => []),
        ],
        child: const EloraApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(EloraApp)),
    );
    container.read(routerProvider).go('/feature/quality');
    await tester.pumpAndSettle();

    expect(find.byType(QualityScreen), findsOneWidget);
    expect(find.text('Citrus quality check'), findsOneWidget);
    for (final label in ['Orange', 'Lemon', 'Lime']) {
      expect(find.text(label), findsOneWidget);
    }
    await _reveal(tester, find.byTooltip('Gallery'));
    expect(find.byTooltip('Gallery'), findsOneWidget);
    expect(find.byTooltip('Camera'), findsOneWidget);

    await _reveal(tester, find.text('Fixture Preview'));
    expect(find.text('Fixture Preview'), findsOneWidget);
    for (final title in ['Fresh', 'Spoiled', 'Unable to assess']) {
      await _reveal(tester, find.text(title));
      expect(find.text(title), findsOneWidget);
    }
    await _reveal(tester, find.byKey(const Key('quality-fixture-abstention')));
    expect(find.text('LABELLED FIXTURE (fixture-v0):'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('fixture previews match the shared labelled JSON fixtures', () {
    expect(citrusQualityFixtures, hasLength(3));
    for (final preview in citrusQualityFixtures) {
      final data = jsonDecode(
        File('../shared/fixtures/${preview.fixtureFile}').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(data['crop_slug'], 'citrus');
      expect(data['task'], 'quality');
      expect(data['model_id'], citrusQualityFixtureModelId);
      expect(data['model_version'], citrusQualityFixtureVersion);
      expect(data['origin'], 'server');
      expect(data['outcome'], preview.outcome);
      expect(data['label_id'], preview.labelId);
      expect(data['confidence'], preview.confidence);
      expect(data['reason'], preview.reason);
      final warnings = (data['warnings'] as List).cast<String>();
      expect(warnings.first, preview.warning);
      expect(warnings.first, startsWith('LABELLED FIXTURE (fixture-v0):'));
      final guidance = (data['guidance'] as List).cast<Map<String, dynamic>>();
      expect(guidance.first['text'], preview.guidance);
      final predictions = (data['top_predictions'] as List)
          .cast<Map<String, dynamic>>();
      expect(
        predictions
            .map((item) => [item['label_id'], item['confidence']])
            .toList(),
        preview.topPredictions
            .map((item) => [item.labelId, item.confidence])
            .toList(),
      );
    }
    expect(citrusQualityFixtures.map((fixture) => fixture.labelId).toList(), [
      'fresh',
      'spoiled',
      null,
    ]);
  });

  testWidgets(
    'camera selection submits citrus quality and shows receipt plus unavailable',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bytes = File('test/fixtures/scan-synthetic.png').readAsBytesSync();
      final keys = <String>[];
      final bodies = <String>[];
      var statusReads = 0;
      final api = EloraApiClient(
        baseUrl: 'https://example.test',
        token: (_) async => 'fixture-token',
        client: MockClient((request) async {
          if (request.method == 'POST') {
            keys.add(request.headers['Idempotency-Key']!);
            bodies.add(latin1.decode(request.bodyBytes));
            return http.Response(
              jsonEncode({
                'scan_id': _scanId,
                'status_url': '/api/v1/scans/$_scanId',
              }),
              202,
            );
          }
          statusReads++;
          expect(request.url.path, '/api/v1/scans/$_scanId');
          return http.Response(
            jsonEncode({
              'scan_id': _scanId,
              'status': 'failed',
              'result': null,
              'error': {'code': 'MODEL_UNAVAILABLE'},
            }),
            200,
          );
        }),
      );
      addTearDown(api.close);
      ImageSource? pickedFrom;
      final container = await _pumpScreen(
        tester,
        api: api,
        picker: (source) async {
          pickedFrom = source;
          return XFile.fromData(bytes, name: 'citrus.png');
        },
      );

      final camera = find.byTooltip('Camera');
      await _reveal(tester, camera);
      await tester.tap(camera);
      await tester.pumpAndSettle();
      expect(pickedFrom, ImageSource.camera);
      expect(container.read(qualityProvider).bytes, bytes);
      await tester.runAsync(
        () => precacheImage(
          MemoryImage(bytes),
          tester.element(find.byType(QualityScreen)),
        ),
      );
      await tester.pumpAndSettle();

      final submit = find.byKey(const Key('quality-submit'));
      await _reveal(tester, submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(keys, hasLength(1));
      expect(
        keys.single,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(bodies.single, contains('name="crop_slug"\r\n\r\ncitrus'));
      expect(bodies.single, contains('name="task"\r\n\r\nquality'));
      expect(bodies.single, contains('name="subtype"\r\n\r\norange'));
      expect(statusReads, 1);
      expect(find.text(_scanId), findsOneWidget);
      expect(
        find.textContaining('No quality model is connected'),
        findsOneWidget,
      );
      expect(container.read(qualityProvider).scanId, _scanId);
      expect(container.read(qualityProvider).status, 'failed');
      expect(container.read(qualityProvider).error, 'MODEL_UNAVAILABLE');
      expect(container.read(qualityProvider).bytes, bytes);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'lime submission shows INVALID_SUBTYPE and keeps the selected photo',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bytes = File('test/fixtures/scan-synthetic.png').readAsBytesSync();
      final bodies = <String>[];
      var statusReads = 0;
      final api = EloraApiClient(
        baseUrl: 'https://example.test',
        token: (_) async => 'fixture-token',
        client: MockClient((request) async {
          if (request.method == 'POST') {
            bodies.add(latin1.decode(request.bodyBytes));
            return http.Response(
              jsonEncode({
                'error': {
                  'code': 'INVALID_SUBTYPE',
                  'message': 'Choose orange or lemon for citrus quality.',
                  'details': null,
                },
              }),
              422,
            );
          }
          statusReads++;
          return http.Response('{}', 500);
        }),
      );
      addTearDown(api.close);
      final container = await _pumpScreen(
        tester,
        api: api,
        picker: (_) async => XFile.fromData(bytes, name: 'citrus.png'),
      );

      await tester.tap(find.byKey(const Key('quality-subtype-lime')));
      await tester.pumpAndSettle();
      expect(container.read(qualityProvider).subtype, CitrusSubtype.lime);

      final gallery = find.byTooltip('Gallery');
      await _reveal(tester, gallery);
      await tester.tap(gallery);
      await tester.pumpAndSettle();
      expect(container.read(qualityProvider).bytes, bytes);

      final submit = find.byKey(const Key('quality-submit'));
      await _reveal(tester, submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(bodies.single, contains('name="subtype"\r\n\r\nlime'));
      expect(statusReads, 0);
      expect(container.read(qualityProvider).error, 'INVALID_SUBTYPE');
      expect(container.read(qualityProvider).scanId, isNull);
      expect(container.read(qualityProvider).bytes, bytes);
      expect(find.byKey(const Key('quality-receipt')), findsNothing);
      await _reveal(tester, find.byKey(const Key('quality-error')));
      expect(
        find.textContaining('Lime is not supported for citrus quality'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

Future<ProviderContainer> _pumpScreen(
  WidgetTester tester, {
  required EloraApiClient api,
  required Future<XFile?> Function(ImageSource source) picker,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiProvider.overrideWithValue(api),
        authStateProvider.overrideWith((ref) => Stream.value(_VerifiedUser())),
        qualityImagePickerProvider.overrideWithValue(picker),
      ],
      child: MaterialApp(
        theme: EloraTheme.light(),
        home: const Scaffold(body: QualityScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(QualityScreen)));
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find
          .descendant(
            of: find.byType(QualityScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}

class _VerifiedUser extends Fake implements User {
  @override
  String get uid => 'quality-fixture-user';
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
