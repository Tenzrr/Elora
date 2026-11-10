import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elora_mobile/core/theme/app_theme.dart';
import 'package:elora_mobile/features/crop_health/models/crop_health_models.dart';
import 'package:elora_mobile/features/crop_health/providers/crop_health_provider.dart';
import 'package:elora_mobile/features/crop_health/widgets/recovery_action_list.dart';

/// Screen displaying the diagnostic scan findings, symptom tags, and actionable recovery plan.
/// Strictly implements the visual composition of docs/screens/Crop diagnosis results.png.
class CropDiagnosisResultsScreen extends ConsumerStatefulWidget {
  const CropDiagnosisResultsScreen({
    super.key,
    required this.imagePath,
    this.cropSlug = 'tomato',
  });

  final String imagePath;
  final String cropSlug;

  @override
  ConsumerState<CropDiagnosisResultsScreen> createState() =>
      _CropDiagnosisResultsScreenState();
}

class _CropDiagnosisResultsScreenState
    extends ConsumerState<CropDiagnosisResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cropHealthProvider.notifier).analyzeImage(
            filePath: widget.imagePath,
            cropSlug: widget.cropSlug,
          );
    });
  }

  void _saveResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diagnosis saved to plant checkup history.'),
        backgroundColor: EloraColors.deepGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cropHealthProvider);
    final result = state.result;

    return Scaffold(
      backgroundColor: EloraColors.cream,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top curved mint header
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: EloraColors.leafGreen,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Analyzing leaf symptoms...',
                            style: TextStyle(
                              color: EloraColors.ink,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Image Card with "Sample result" tag
                          _buildHeroImageCard(),
                          const SizedBox(height: 16),

                          // Primary Diagnosis Card
                          _buildDiagnosisCard(result),
                          const SizedBox(height: 18),

                          // Visible Symptoms Section
                          _buildSymptomsSection(result),
                          const SizedBox(height: 18),

                          // 3-Step Recovery Action Plan Card
                          RecoveryActionList(
                            cropName: widget.cropSlug,
                            steps: result?.recoverySteps ?? _defaultSteps(),
                          ),
                          const SizedBox(height: 16),

                          // Advisory Footnote
                          _buildAdvisoryFootnote(result),
                          const SizedBox(height: 24),

                          // Dual CTAs (Scan again & Save result)
                          _buildDualCTAs(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
                  'Scan results',
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImageCard() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 220,
            width: double.infinity,
            color: const Color(0xFF28362E),
            child: File(widget.imagePath).existsSync()
                ? Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  )
                : const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Sample result',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisCard(CropHealthAnalysisResult? result) {
    final label = result?.detectedLabel ?? 'Possible powdery mildew';
    final cropDisplay = '${widget.cropSlug[0].toUpperCase()}${widget.cropSlug.substring(1)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: EloraColors.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.coronavirus_outlined,
                  color: EloraColors.deepGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: EloraColors.deepGreen,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$cropDisplay • illustrative scan',
                      style: const TextStyle(
                        fontSize: 13,
                        color: EloraColors.muted,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Not a confirmed diagnosis',
              style: TextStyle(
                color: Color(0xFF856404),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsSection(CropHealthAnalysisResult? result) {
    final symptoms = result?.visibleSymptoms.isNotEmpty == true
        ? result!.visibleSymptoms
        : const ['White powdery patches', 'Pale leaf edges'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visible in this sample',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: EloraColors.ink,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptoms.map((symptom) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: EloraColors.mint.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                symptom,
                style: const TextStyle(
                  fontSize: 13,
                  color: EloraColors.deepGreen,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvisoryFootnote(CropHealthAnalysisResult? result) {
    final note = result?.advisoryFootnote ??
        'Demo only. Other issues can look similar; a photo alone cannot confirm a disease.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 16, color: EloraColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            note,
            style: const TextStyle(
              fontSize: 12,
              color: EloraColors.muted,
              height: 1.35,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDualCTAs(BuildContext context) {
    return Row(
      children: [
        // Left CTA: "Scan again"
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.center_focus_weak, size: 20),
              label: const Text(
                'Scan again',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: EloraColors.mint,
                foregroundColor: EloraColors.deepGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Right CTA: "Save result"
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saveResult,
              icon: const Icon(Icons.bookmark_outline, size: 20),
              label: const Text(
                'Save result',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: EloraColors.deepGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<RecoveryStep> _defaultSteps() {
    return const [
      RecoveryStep(
        stepNumber: 1,
        icon: 'shears',
        title: 'Remove badly affected leaves',
        description: 'Bag them and clean your pruning tools.',
      ),
      RecoveryStep(
        stepNumber: 2,
        icon: 'airflow',
        title: 'Keep leaves dry & improve airflow',
        description: 'Water at the soil; give plants some space.',
      ),
      RecoveryStep(
        stepNumber: 3,
        icon: 'expert',
        title: 'Confirm before treating',
        description: 'If it spreads, ask a local plant expert.',
      ),
    ];
  }
}
