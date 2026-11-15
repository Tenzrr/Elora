import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'network/api_client.dart';

final configProvider = Provider((ref) => const AppConfig());
final initialLocaleProvider = Provider((ref) => const Locale('en'));
final startupErrorProvider = Provider<String?>((ref) => null);
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final authStateProvider = StreamProvider<User?>((ref) {
  if (!ref.watch(configProvider).configured ||
      ref.watch(startupErrorProvider) != null) {
    return Stream.value(null);
  }
  return ref.watch(firebaseAuthProvider).idTokenChanges();
});

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => ref.read(initialLocaleProvider);

  Future<void> choose(String language) async {
    state = Locale(language);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('language', language);
    if (ref.read(authStateProvider).asData?.value != null) {
      await ref
          .read(apiProvider)
          .request('PATCH', '/profile', body: {'language': language});
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
final apiProvider = Provider((ref) {
  final api = EloraApiClient(
    baseUrl: ref.watch(configProvider).apiUrl,
    token: (force) =>
        ref.read(firebaseAuthProvider).currentUser?.getIdToken(force) ??
        Future<String?>.value(null),
  );
  ref.onDispose(api.close);
  return api;
});

final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return null;
  return Map<String, dynamic>.from(
    await ref.read(apiProvider).request('POST', '/session') as Map,
  );
});

final plantsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (ref.watch(authStateProvider).asData?.value == null) return [];
  final page =
      await ref.watch(apiProvider).request('GET', '/plants?limit=100') as Map;
  return (page['items'] as List)
      .map((p) => Map<String, dynamic>.from(p as Map))
      .toList();
});
