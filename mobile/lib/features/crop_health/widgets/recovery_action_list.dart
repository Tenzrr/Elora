import 'package:flutter/material.dart';
import 'package:garden_mobile/core/theme/app_theme.dart';
import 'package:garden_mobile/features/crop_health/models/crop_health_models.dart';

/// Renders the structured, icon-guided 3-step recovery action plan.
/// Conforms strictly to docs/screens/Crop diagnosis results.png.
class RecoveryActionList extends StatelessWidget {
  const RecoveryActionList({
    super.key,
    required this.cropName,
    required this.steps,
  });

  final String cropName;
  final List<RecoveryStep> steps;

  IconData _getIcon(String iconIdentifier) {
    switch (iconIdentifier.toLowerCase()) {
      case 'shears':
        return Icons.content_cut_outlined;
      case 'airflow':
        return Icons.air_outlined;
      case 'expert':
      case 'chat':
        return Icons.chat_bubble_outline;
      default:
        return Icons.eco_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help your $cropName recover',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GardenColors.ink,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          ...steps.map((step) => _buildStepTile(step)),
        ],
      ),
    );
  }

  Widget _buildStepTile(RecoveryStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: GardenColors.mint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(step.icon),
              color: GardenColors.deepGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${step.stepNumber}. ${step.title}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GardenColors.ink,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: GardenColors.muted,
                    height: 1.35,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
