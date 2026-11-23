import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import 'quality_models.dart';

String _operationId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

class QualityController extends Notifier<QualityScanState> {
  int _generation = 0;

  @override
  QualityScanState build() {
    ref.watch(authStateProvider.select((auth) => auth.asData?.value?.uid));
    _generation++;
    return const QualityScanState();
  }

  void selectPhoto(Uint8List bytes) {
    _generation++;
    state = QualityScanState(
      bytes: bytes,
      operationId: _operationId(),
      subtype: state.subtype,
    );
  }

  void selectSubtype(CitrusSubtype subtype) {
    if (state.busy || subtype == state.subtype) return;
    _generation++;
    state = QualityScanState(
      bytes: state.bytes,
      operationId: state.bytes == null ? null : _operationId(),
      subtype: subtype,
    );
  }

  Future<void> submit() async {
    if (state.busy) return;
    final bytes = state.bytes;
    if (bytes == null) {
      state = state.copyWith(error: 'MISSING_IMAGE');
      return;
    }

    final generation = _generation;
    final operationId = state.operationId!;
    final subtype = state.subtype;
    state = state.copyWith(busy: true);
    try {
      final receipt = await ref
          .read(apiProvider)
          .uploadImage(
            '/scans',
            fields: {
              'crop_slug': 'citrus',
              'task': 'quality',
              'subtype': subtype.slug,
            },
            bytes: bytes,
            operationId: operationId,
          );
      final scanId = receipt is Map ? receipt['scan_id'] : null;
      if (scanId is! String) {
        throw const ApiException('INVALID_RESPONSE');
      }
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(scanId: scanId, busy: false);
      await _refresh(generation);
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
    _generation++;
    await _refresh(_generation);
  }

  Future<void> _refresh(int generation) async {
    final scanId = state.scanId;
    if (scanId == null) return;
    state = state.copyWith(busy: true);
    try {
      final job = await ref.read(apiProvider).request('GET', '/scans/$scanId');
      if (!ref.mounted || generation != _generation) return;
      final status = job is Map ? job['status'] : null;
      if (status is! String ||
          !{'queued', 'running', 'completed', 'failed'}.contains(status)) {
        throw const ApiException('INVALID_RESPONSE');
      }
      final error = job['error'];
      final errorCode = status == 'failed'
          ? (error is Map ? error['code'] as String? : null) ?? 'REQUEST_FAILED'
          : null;
      state = state.copyWith(status: status, error: errorCode, busy: false);
    } catch (error) {
      if (ref.mounted && generation == _generation) {
        state = state.copyWith(
          busy: false,
          error: error is ApiException ? error.code : 'REQUEST_FAILED',
        );
      }
    }
  }
}

final qualityProvider = NotifierProvider<QualityController, QualityScanState>(
  QualityController.new,
);
