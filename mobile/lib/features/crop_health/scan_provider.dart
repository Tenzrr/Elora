import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';

String _operationId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}

class ScanState {
  const ScanState({
    this.bytes,
    this.operationId,
    this.scanId,
    this.status,
    this.error,
    this.busy = false,
  });

  final Uint8List? bytes;
  final String? operationId;
  final String? scanId;
  final String? status;
  final String? error;
  final bool busy;

  ScanState copyWith({
    String? scanId,
    String? status,
    String? error,
    bool? busy,
  }) => ScanState(
    bytes: bytes,
    operationId: operationId,
    scanId: scanId ?? this.scanId,
    status: status ?? this.status,
    error: error,
    busy: busy ?? this.busy,
  );
}

class ScanController extends Notifier<ScanState> {
  Timer? _timer;
  int _generation = 0;
  int _delay = 2;
  bool _foreground = true;

  @override
  ScanState build() {
    ref.watch(authStateProvider.select((auth) => auth.asData?.value?.uid));
    _generation++;
    _timer?.cancel();
    ref.onDispose(() => _timer?.cancel());
    return const ScanState();
  }

  void select(Uint8List bytes) {
    _timer?.cancel();
    _generation++;
    state = ScanState(bytes: bytes, operationId: _operationId());
  }

  Future<void> submit() async {
    if (state.bytes == null || state.busy) return;
    final generation = _generation;
    state = state.copyWith(busy: true);
    try {
      final receipt = await ref
          .read(apiProvider)
          .uploadImage(
            '/scans',
            fields: {'crop_slug': 'tomato', 'task': 'disease'},
            bytes: state.bytes!,
            operationId: state.operationId!,
          );
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(scanId: receipt['scan_id'] as String, busy: false);
      _delay = 2;
      await refresh();
    } catch (error) {
      if (ref.mounted && generation == _generation) {
        state = state.copyWith(
          busy: false,
          error: error is ApiException ? error.code : 'REQUEST_FAILED',
        );
      }
    }
  }

  Future<void> refresh() async {
    if (state.scanId == null || state.busy) return;
    _timer?.cancel();
    final generation = _generation;
    state = state.copyWith(busy: true);
    try {
      final job = await ref
          .read(apiProvider)
          .request('GET', '/scans/${state.scanId}');
      if (!ref.mounted || generation != _generation) return;
      final status = job['status'] as String;
      if (!{'queued', 'running', 'completed', 'failed'}.contains(status)) {
        throw const ApiException('INVALID_RESPONSE');
      }
      state = state.copyWith(
        status: status,
        busy: false,
        error: status == 'failed'
            ? ((job['error']?['code'] as String?) ?? 'REQUEST_FAILED')
            : null,
      );
      if (_foreground && {'queued', 'running'}.contains(status)) {
        _timer = Timer(Duration(seconds: _delay), refresh);
        _delay = min(_delay * 2, 10);
      }
    } catch (error) {
      if (ref.mounted && generation == _generation) {
        state = state.copyWith(
          busy: false,
          error: error is ApiException ? error.code : 'REQUEST_FAILED',
        );
      }
    }
  }

  void foreground(bool active) {
    _foreground = active;
    if (!active) {
      _timer?.cancel();
    } else if (state.scanId != null &&
        state.status != 'failed' &&
        state.status != 'completed') {
      unawaited(refresh());
    }
  }
}

final scanProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);
