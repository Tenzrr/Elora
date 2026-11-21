import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/images.dart';
import '../../core/theme/app_theme.dart';
import 'quality_models.dart';
import 'quality_provider.dart';

final qualityImagePickerProvider = Provider((ref) => selectCropImage);

class QualityScreen extends ConsumerStatefulWidget {
  const QualityScreen({super.key});

  @override
  ConsumerState<QualityScreen> createState() => _QualityScreenState();
}

class _QualityScreenState extends ConsumerState<QualityScreen> {
  bool _picking = false;
  String? _selectionError;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _picking = true;
      _selectionError = null;
    });
    final previous = ref.read(qualityProvider);
    try {
      final file = await ref.read(qualityImagePickerProvider)(source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted || !identical(ref.read(qualityProvider), previous)) return;
      ref.read(qualityProvider.notifier).selectPhoto(bytes);
    } on ImageSelectionException catch (error) {
      if (mounted) setState(() => _selectionError = error.code);
    } catch (_) {
      if (mounted) setState(() => _selectionError = 'IMAGE_SELECTION_FAILED');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quality = ref.watch(qualityProvider);
    final busy = quality.busy || _picking;
    final error = _selectionError ?? quality.error;
    final retry =
        quality.operationId != null &&
        (quality.scanId != null || error != null);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _introCard(context),
        const SizedBox(height: 20),
        Text(
          'Fruit type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: EloraColors.deepGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Orange and Lemon are supported. Lime demonstrates the API's "
          'INVALID_SUBTYPE rejection.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: EloraColors.muted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final subtype in CitrusSubtype.values)
              ChoiceChip(
                key: Key('quality-subtype-${subtype.slug}'),
                label: Text(subtype.label),
                selected: quality.subtype == subtype,
                showCheckmark: false,
                selectedColor: EloraColors.deepGreen,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: quality.subtype == subtype
                      ? EloraColors.deepGreen
                      : EloraColors.mint,
                ),
                labelStyle: TextStyle(
                  color: quality.subtype == subtype
                      ? Colors.white
                      : EloraColors.deepGreen,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: busy
                    ? null
                    : (_) => ref
                          .read(qualityProvider.notifier)
                          .selectSubtype(subtype),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _photoCard(context, quality),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SourceButton(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              tooltip: 'Gallery',
              onPressed: busy ? null : () => _pick(ImageSource.gallery),
            ),
            _SourceButton(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              tooltip: 'Camera',
              filled: true,
              onPressed: busy ? null : () => _pick(ImageSource.camera),
            ),
          ],
        ),
        if (busy) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
          const SizedBox(height: 6),
          Text(
            'Submitting citrus photo…',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: EloraColors.muted),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('quality-submit'),
          onPressed: busy || quality.bytes == null
              ? null
              : () {
                  setState(() => _selectionError = null);
                  unawaited(ref.read(qualityProvider.notifier).submit());
                },
          icon: Icon(retry ? Icons.refresh : Icons.center_focus_strong),
          label: Text(retry ? 'Retry same upload' : 'Submit citrus photo'),
        ),
        if (quality.scanId != null) ...[
          const SizedBox(height: 16),
          _receiptCard(context, quality, busy),
        ],
        if (error != null) ...[const SizedBox(height: 16), _errorCard(error)],
        const SizedBox(height: 28),
        Text(
          'Fixture Preview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: EloraColors.deepGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Synthetic fixture-v0 examples only. They are not real model results.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: EloraColors.muted),
        ),
        const SizedBox(height: 12),
        for (final fixture in citrusQualityFixtures) ...[
          _FixturePreviewCard(fixture: fixture),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _introCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EloraColors.mint.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: EloraColors.deepGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: EloraColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_outlined, color: EloraColors.deepGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Citrus quality check',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: EloraColors.deepGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose orange or lemon, add a fruit photo, and submit it to '
                  'the shared scan API. No quality model is connected yet.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: EloraColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoCard(BuildContext context, QualityScanState quality) {
    final bytes = quality.bytes;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: EloraColors.mint),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (bytes == null)
                ColoredBox(
                  color: EloraColors.mint.withValues(alpha: 0.5),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              color: EloraColors.cream.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.center_focus_strong,
                              size: 40,
                              color: EloraColors.deepGreen,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Add one citrus photo',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: EloraColors.deepGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Orange or Lemon • JPEG, PNG or WebP',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: EloraColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  semanticLabel: 'Selected citrus photo',
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: EloraColors.mint.withValues(alpha: 0.5),
                    child: Center(
                      child: Text(
                        'This photo cannot be displayed. Choose another photo.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: EloraColors.deepGreen.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'INTERIM UPLOAD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptCard(
    BuildContext context,
    QualityScanState quality,
    bool busy,
  ) {
    final failed = quality.status == 'failed';
    return Card(
      key: const Key('quality-receipt'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: EloraColors.leafGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload receipt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: EloraColors.deepGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: failed
                        ? EloraColors.danger.withValues(alpha: 0.1)
                        : EloraColors.mint.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(quality.status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: failed
                          ? EloraColors.danger
                          : EloraColors.deepGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'The server persisted this scan ID:',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: EloraColors.muted),
            ),
            const SizedBox(height: 4),
            SelectableText(
              quality.scanId!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EloraColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!busy) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('quality-refresh'),
                  onPressed: () =>
                      unawaited(ref.read(qualityProvider.notifier).refresh()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh status'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String error) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('quality-error'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EloraColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: EloraColors.danger.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: EloraColors.danger),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage(error),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EloraColors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String? status) => switch (status) {
    'queued' => 'Waiting',
    'running' => 'Processing',
    'completed' => 'Completed',
    'failed' => 'Failed',
    _ => 'Recorded',
  };

  String _errorMessage(String error) => switch (error) {
    'INVALID_SUBTYPE' =>
      'Lime is not supported for citrus quality. Choose Orange or Lemon.',
    'MODEL_UNAVAILABLE' =>
      'Upload saved. No quality model is connected, so no result was '
          'produced. Your photo is kept for retry.',
    'MISSING_IMAGE' => 'Choose a citrus photo before submitting.',
    'INVALID_IMAGE' || 'IMAGE_TOO_LARGE' || 'UNSUPPORTED_MEDIA_TYPE' =>
      'Choose a clear JPEG, PNG or WebP fruit photo under 10 MB.',
    'IMAGE_SELECTION_FAILED' =>
      'Photo access failed. Allow camera or gallery access, or try the other '
          'source.',
    'TIMEOUT' || 'NETWORK_UNAVAILABLE' =>
      'The server could not be reached. Your photo and receipt are kept. '
          'Check your connection and retry.',
    'UNAUTHORIZED' => 'Sign in again to submit a citrus photo.',
    _ =>
      'The request could not finish. Your photo is kept here. Retry or refresh '
          'the receipt.',
  };
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final button = filled
        ? IconButton.filled(
            tooltip: tooltip,
            onPressed: onPressed,
            iconSize: 28,
            style: IconButton.styleFrom(minimumSize: const Size(58, 58)),
            icon: Icon(icon),
          )
        : IconButton.filledTonal(
            tooltip: tooltip,
            onPressed: onPressed,
            iconSize: 28,
            style: IconButton.styleFrom(minimumSize: const Size(58, 58)),
            icon: Icon(icon),
          );
    return Column(
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: EloraColors.deepGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FixturePreviewCard extends StatelessWidget {
  const _FixturePreviewCard({required this.fixture});

  final QualityFixturePreview fixture;

  @override
  Widget build(BuildContext context) {
    final abstention = fixture.outcome == 'unable_to_assess';
    final spoiled = fixture.labelId == 'spoiled';
    final accent = abstention
        ? EloraColors.muted
        : spoiled
        ? EloraColors.danger
        : EloraColors.leafGreen;
    final icon = abstention
        ? Icons.help_outline
        : spoiled
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline;
    return Card(
      key: Key('quality-fixture-${fixture.labelId ?? 'abstention'}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fixture.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: EloraColors.deepGreen,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        abstention
                            ? 'Abstention • ${fixture.confidenceText}'
                            : 'Assessed • ${fixture.confidenceText}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: EloraColors.cream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: EloraColors.mint.withValues(alpha: 0.8),
                ),
              ),
              child: Text(
                'LABELLED FIXTURE (fixture-v0):',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EloraColors.deepGreen,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Synthetic example only — not a real assessment.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: EloraColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              abstention ? fixture.reason! : fixture.guidance,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: EloraColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
