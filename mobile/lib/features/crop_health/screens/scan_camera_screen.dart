import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elora_mobile/core/theme/app_theme.dart';
import 'package:elora_mobile/features/crop_health/screens/crop_diagnosis_results_screen.dart';
import 'package:elora_mobile/features/crop_health/widgets/viewfinder_reticle.dart';

/// Camera scanner screen for crop foliage disease detection.
/// Strictly implements the visual composition of docs/screens/Scan camera.png.
class ScanCameraScreen extends ConsumerStatefulWidget {
  const ScanCameraScreen({super.key});

  @override
  ConsumerState<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends ConsumerState<ScanCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isFlashOn = false;
  String _zoomLevel = '1x';
  final String _selectedCrop = 'tomato';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );

      if (picked == null) return;

      if (!mounted) return;

      // Navigate to results screen with picked file path
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => CropDiagnosisResultsScreen(
            imagePath: picked.path,
            cropSlug: _selectedCrop,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to acquire photo: $e')),
      );
    }
  }

  void _showHelpModal() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: EloraColors.cream,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'How to take a good leaf scan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: EloraColors.deepGreen,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '1. Focus on a single affected leaf inside the square reticle.\n'
                '2. Ensure natural daylight without strong shadows or glare.\n'
                '3. Avoid blurry photos by holding the phone steady 15-20cm away.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: EloraColors.ink,
                ),
              ),
              SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Mock camera preview background
            Positioned.fill(
              child: Container(
                color: const Color(0xFF1E2822),
                child: const Center(
                  child: Icon(
                    Icons.eco_outlined,
                    color: Color(0x3352B788),
                    size: 140,
                  ),
                ),
              ),
            ),

            // Reticle overlay
            const Positioned.fill(
              child: ViewfinderReticle(),
            ),

            // Top curved mint header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFA6E3C3),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: EloraColors.deepGreen,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Scan plant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: EloraColors.deepGreen,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            'My Elora',
                            style: TextStyle(
                              fontSize: 12,
                              color: EloraColors.deepGreen,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Help button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: EloraColors.deepGreen,
                          size: 20,
                        ),
                        onPressed: _showHelpModal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // In-Camera Flash Toggle (Top Left below header)
            Positioned(
              top: MediaQuery.of(context).padding.top + 82,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFlashOn = !_isFlashOn;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isFlashOn ? 'On' : 'Off',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // In-Camera Zoom Badge (Below reticle)
            Positioned(
              bottom: 126,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _zoomLevel = _zoomLevel == '1x' ? '2x' : '1x';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _zoomLevel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Shutter Control Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                color: Colors.black.withValues(alpha: 0.85),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gallery Picker
                    InkWell(
                      onTap: () => _pickImage(ImageSource.gallery),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.photo_library_outlined, color: Colors.white, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Gallery',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Shutter Button (72dp Dual Ring)
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.camera),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: EloraColors.deepGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Camera Flip
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Switched camera orientation')),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Flip',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
