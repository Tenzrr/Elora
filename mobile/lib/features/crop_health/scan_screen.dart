import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/images.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import 'scan_provider.dart';

final scanImagePickerProvider = Provider((ref) => selectCropImage);

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  late ScanController _controller;
  bool _picking = false;
  String? _selectionError;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(scanProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.foreground(true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _controller.foreground(state == AppLifecycleState.resumed);

  @override
  void dispose() {
    _controller.foreground(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _picking = true;
      _selectionError = null;
    });
    final previous = ref.read(scanProvider);
    try {
      final file = await ref.read(scanImagePickerProvider)(source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted || !identical(ref.read(scanProvider), previous)) return;
      _controller.select(bytes);
    } catch (_) {
      if (mounted) setState(() => _selectionError = 'IMAGE_SELECTION_FAILED');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scan = ref.watch(scanProvider);
    final disabled = scan.busy || _picking;
    final error = _selectionError ?? scan.error;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t.scanInterim, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: 'tomato',
                decoration: InputDecoration(labelText: t.scanCrop),
                items: [
                  DropdownMenuItem(value: 'tomato', child: Text(t.scanTomato)),
                ],
                onChanged: disabled ? null : (_) {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: 'disease',
                decoration: InputDecoration(labelText: t.scanType),
                items: [
                  DropdownMenuItem(
                    value: 'disease',
                    child: Text(t.scanDisease),
                  ),
                ],
                onChanged: disabled ? null : (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(t.scanFraming),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: scan.bytes == null
                ? ColoredBox(
                    color: EloraColors.mint,
                    child: Center(
                      child: Icon(
                        Icons.center_focus_strong,
                        size: 72,
                        color: EloraColors.deepGreen,
                        semanticLabel: t.scanFraming,
                      ),
                    ),
                  )
                : Image.memory(
                    scan.bytes!,
                    fit: BoxFit.cover,
                    semanticLabel: t.scanSelectedPhoto,
                    errorBuilder: (_, _, _) =>
                        Center(child: Text(t.scanPhotoInvalid)),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              tooltip: t.scanGallery,
              onPressed: disabled ? null : () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
            ),
            IconButton.filled(
              tooltip: t.scanCamera,
              iconSize: 40,
              onPressed: disabled ? null : () => _pick(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
            ),
          ],
        ),
        if (scan.busy) ...[
          const LinearProgressIndicator(),
          Text(scan.previewBusy ? t.scanPreviewRunning : t.scanChecking),
        ],
        if (scan.scanId != null) ...[
          Text(t.scanRecorded, style: Theme.of(context).textTheme.titleMedium),
          SelectableText(scan.scanId!),
          Text(switch (scan.status) {
            'queued' => t.scanQueued,
            'running' => t.scanRunning,
            'completed' => t.scanCompleted,
            'failed' => t.scanFailed,
            _ => t.scanChecking,
          }),
        ],
        if (error != null)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(switch (error) {
                'MODEL_UNAVAILABLE' => t.scanUnavailable,
                'IMAGE_SELECTION_FAILED' => t.scanSelectionFailed,
                'INVALID_IMAGE' ||
                'IMAGE_TOO_LARGE' ||
                'UNSUPPORTED_MEDIA_TYPE' => t.scanPhotoInvalid,
                _ => t.scanRequestFailed,
              }),
            ),
          ),
        if (scan.previewLabel != null)
          Card(
            color: EloraColors.mint,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.scanPreviewTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(scan.previewLabel!.replaceAll('_', ' ')),
                  Text('${t.scanPreviewModel}: ${scan.previewModelVersion}'),
                  Text(t.scanPreviewWarning),
                ],
              ),
            ),
          ),
        if (scan.previewError != null) Text(t.scanPreviewUnavailable),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: disabled || scan.bytes == null
              ? null
              : () => unawaited(_controller.preview()),
          child: Text(t.scanPreviewAction),
        ),
        FilledButton(
          onPressed: disabled || scan.bytes == null
              ? null
              : () {
                  setState(() => _selectionError = null);
                  unawaited(_controller.submit());
                },
          child: Text(
            scan.operationId != null &&
                    (scan.scanId != null || scan.error != null)
                ? t.scanRetry
                : t.scanSubmit,
          ),
        ),
        if (scan.scanId != null)
          OutlinedButton(
            onPressed: disabled
                ? null
                : () {
                    setState(() => _selectionError = null);
                    unawaited(_controller.refresh());
                  },
            child: Text(t.scanRefresh),
          ),
      ],
    );
  }
}
