import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elora_mobile/features/crop_health/models/crop_health_models.dart';
import 'package:elora_mobile/features/crop_health/widgets/recovery_action_list.dart';
import 'package:elora_mobile/features/crop_health/widgets/viewfinder_reticle.dart';

void main() {
  group('Crop Health Model Tests', () {
    test('CropHealthAnalysisResult parses JSON correctly', () {
      final json = {
        'session_id': 'test-session-123',
        'crop_slug': 'tomato',
        'task': 'disease',
        'detected_label': 'Early Blight',
        'botanical_pathogen': 'Alternaria solani',
        'confidence': 0.942,
        'severity_level': 'moderate',
        'visible_symptoms': ['Dark concentric target spots', 'Yellow leaf margins'],
        'recovery_steps': [
          {
            'step_number': 1,
            'icon': 'shears',
            'title': 'Remove badly affected leaves',
            'description': 'Bag and discard infected foliage.',
          },
          {
            'step_number': 2,
            'icon': 'airflow',
            'title': 'Keep leaves dry',
            'description': 'Water at soil level.',
          },
        ],
        'top_predictions': [
          {'label': 'Early Blight', 'confidence': 0.942},
          {'label': 'Late Blight', 'confidence': 0.038},
        ],
        'advisory_footnote': 'Illustrative scan disclaimer.',
        'model_version': 'CNN-TOM-DIS-v1.2',
        'created_at': '2026-10-27T10:00:00Z',
      };

      final result = CropHealthAnalysisResult.fromJson(json);

      expect(result.sessionId, 'test-session-123');
      expect(result.cropSlug, 'tomato');
      expect(result.detectedLabel, 'Early Blight');
      expect(result.botanicalPathogen, 'Alternaria solani');
      expect(result.confidence, 0.942);
      expect(result.recoverySteps.length, 2);
      expect(result.recoverySteps.first.title, 'Remove badly affected leaves');
      expect(result.topPredictions.length, 2);
    });
  });

  group('Crop Health Widget Tests', () {
    testWidgets('ViewfinderReticle renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ViewfinderReticle(boxSize: 280),
          ),
        ),
      );

      expect(find.byType(ViewfinderReticle), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('RecoveryActionList displays crop name and step items', (WidgetTester tester) async {
      const steps = [
        RecoveryStep(
          stepNumber: 1,
          icon: 'shears',
          title: 'Prune blighted foliage',
          description: 'Use sanitized tools.',
        ),
        RecoveryStep(
          stepNumber: 2,
          icon: 'airflow',
          title: 'Improve airflow',
          description: 'Ensure spacing.',
        ),
      ];

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecoveryActionList(
                cropName: 'tomato',
                steps: steps,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Help your tomato recover'), findsOneWidget);
      expect(find.text('1. Prune blighted foliage'), findsOneWidget);
      expect(find.text('2. Improve airflow'), findsOneWidget);
      expect(find.text('Use sanitized tools.'), findsOneWidget);
      expect(find.byIcon(Icons.content_cut_outlined), findsOneWidget);
      expect(find.byIcon(Icons.air_outlined), findsOneWidget);
    });
  });
}
