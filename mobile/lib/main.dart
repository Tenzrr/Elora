import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'core/config.dart';
import 'core/elora_shell.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/agricultural_agent/screens/chat_screen.dart';
import 'features/predictive_farming/screens/farming_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/auth_screen.dart';
import 'screens/garden_screen.dart';
import 'screens/profile_screen.dart';
import 'features/crop_health/scan_screen.dart';
import 'features/produce_quality/quality_screen.dart';
import 'features/community/community_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Inter',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  const config = AppConfig.fromEnvironment();
  String? startupError;
  if (config.configured) {
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: config.firebaseApiKey,
          appId: config.firebaseAppId,
          messagingSenderId: config.firebaseSenderId,
          projectId: config.firebaseProjectId,
        ),
      );
      if (config.googleWebClientId.isNotEmpty) {
        await GoogleSignIn.instance.initialize(
          serverClientId: config.googleWebClientId,
        );
      }
    } catch (_) {
      startupError = 'FIREBASE_SETUP_FAILED';
    }
  }
  final preferences = await SharedPreferences.getInstance();
  final language = preferences.getString('language');
  runApp(
    ProviderScope(
      overrides: [
        configProvider.overrideWithValue(config),
        initialLocaleProvider.overrideWithValue(
          Locale({'en', 'si', 'ta'}.contains(language) ? language! : 'en'),
        ),
        startupErrorProvider.overrideWithValue(startupError),
      ],
      child: const EloraApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final config = ref.watch(configProvider);
  final error = ref.watch(startupErrorProvider);
  final router = GoRouter(
    initialLocation: '/garden',
    redirect: (context, state) {
      final path = state.uri.path;
      if (!config.configured || error != null) {
        return path == '/setup' ? null : '/setup';
      }
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return path == '/loading' ? null : '/loading';
      final user = auth.asData?.value;
      if (user == null) return path == '/auth' ? null : '/auth';
      if (!user.emailVerified) return path == '/verify' ? null : '/verify';
      if ({'/auth', '/verify', '/loading', '/setup'}.contains(path)) {
        return '/garden';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/setup', builder: (_, state) => const SetupScreen()),
      GoRoute(
        path: '/loading',
        builder: (_, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/auth', builder: (_, state) => const AuthScreen()),
      GoRoute(path: '/verify', builder: (_, state) => const VerifyScreen()),
      ShellRoute(
        builder: (_, state, child) =>
            EloraShell(path: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/garden', builder: (_, state) => const GardenScreen()),
          GoRoute(
            path: '/profile',
            builder: (_, state) => const ProfileScreen(),
          ),
          for (final module in EloraModule.values)
            GoRoute(
              path: module.path,
              builder: (context, state) {
                if (module == EloraModule.quality) {
                  return const QualityScreen();
                }
                if (module == EloraModule.assistant) {
                  return const ChatScreen();
                }
                if (module == EloraModule.farming) {
                  return const FarmingScreen();
                }
                if (module == EloraModule.cropHealth) {
                  return const ScanScreen();
                }
                if (module == EloraModule.community) {
                  return const CommunityScreen();
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppLocalizations.of(context)!.notImplemented,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    ],
  );
  ref.listen(authStateProvider, (previous, next) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

class EloraApp extends ConsumerWidget {
  const EloraApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Elora',
      debugShowCheckedModeBanner: false,
      theme: EloraTheme.light(),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return DropdownButton<String>(
      value: ref.watch(localeProvider).languageCode,
      underline: const SizedBox.shrink(),
      hint: Text(t.language),
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'si', child: Text('සිංහල')),
        DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
      ],
      onChanged: (value) async {
        if (value == null) return;
        try {
          await ref.read(localeProvider.notifier).choose(value);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(t.actionFailed)));
          }
        }
      },
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elora'),
        actions: const [LanguagePicker()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(t.setupNeeded, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
