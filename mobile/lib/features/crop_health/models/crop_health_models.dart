/// Data models for the Crop Health Analysis vertical slice.
library;

class PredictionItem {
  const PredictionItem({
    required this.label,
    required this.confidence,
  });

  factory PredictionItem.fromJson(Map<String, dynamic> json) {
    return PredictionItem(
      label: json['label'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String label;
  final double confidence;

  Map<String, dynamic> toJson() => {
        'label': label,
        'confidence': confidence,
      };
}

class RecoveryStep {
  const RecoveryStep({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
  });

  factory RecoveryStep.fromJson(Map<String, dynamic> json) {
    return RecoveryStep(
      stepNumber: json['step_number'] as int? ?? 1,
      icon: json['icon'] as String? ?? 'expert',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  final int stepNumber;
  final String icon;
  final String title;
  final String description;

  Map<String, dynamic> toJson() => {
        'step_number': stepNumber,
        'icon': icon,
        'title': title,
        'description': description,
      };
}

class CropHealthAnalysisResult {
  const CropHealthAnalysisResult({
    required this.sessionId,
    required this.cropSlug,
    required this.task,
    required this.detectedLabel,
    this.botanicalPathogen,
    required this.confidence,
    required this.severityLevel,
    required this.visibleSymptoms,
    required this.recoverySteps,
    required this.topPredictions,
    required this.advisoryFootnote,
    required this.modelVersion,
    required this.createdAt,
  });

  factory CropHealthAnalysisResult.fromJson(Map<String, dynamic> json) {
    return CropHealthAnalysisResult(
      sessionId: json['session_id'] as String? ?? '',
      cropSlug: json['crop_slug'] as String? ?? 'tomato',
      task: json['task'] as String? ?? 'disease',
      detectedLabel: json['detected_label'] as String? ?? 'Unknown',
      botanicalPathogen: json['botanical_pathogen'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      severityLevel: json['severity_level'] as String? ?? 'moderate',
      visibleSymptoms: (json['visible_symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      recoverySteps: (json['recovery_steps'] as List<dynamic>?)
              ?.map((e) => RecoveryStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      topPredictions: (json['top_predictions'] as List<dynamic>?)
              ?.map((e) => PredictionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      advisoryFootnote: json['advisory_footnote'] as String? ??
          'Demo only. A photo alone cannot confirm a disease.',
      modelVersion: json['model_version'] as String? ?? 'v1.0',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  final String sessionId;
  final String cropSlug;
  final String task;
  final String detectedLabel;
  final String? botanicalPathogen;
  final double confidence;
  final String severityLevel;
  final List<String> visibleSymptoms;
  final List<RecoveryStep> recoverySteps;
  final List<PredictionItem> topPredictions;
  final String advisoryFootnote;
  final String modelVersion;
  final String createdAt;
}
