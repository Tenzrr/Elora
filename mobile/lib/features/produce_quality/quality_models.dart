import 'dart:typed_data';

enum CitrusSubtype {
  orange('orange', 'Orange', supported: true),
  lemon('lemon', 'Lemon', supported: true),
  lime('lime', 'Lime', supported: false);

  const CitrusSubtype(this.slug, this.label, {required this.supported});

  final String slug;
  final String label;
  final bool supported;
}

class QualityScanState {
  const QualityScanState({
    this.bytes,
    this.operationId,
    this.subtype = CitrusSubtype.orange,
    this.scanId,
    this.status,
    this.error,
    this.busy = false,
  });

  final Uint8List? bytes;
  final String? operationId;
  final CitrusSubtype subtype;
  final String? scanId;
  final String? status;
  final String? error;
  final bool busy;

  QualityScanState copyWith({
    String? scanId,
    String? status,
    String? error,
    bool? busy,
  }) => QualityScanState(
    bytes: bytes,
    operationId: operationId,
    subtype: subtype,
    scanId: scanId ?? this.scanId,
    status: status ?? this.status,
    error: error,
    busy: busy ?? this.busy,
  );
}

class QualityPrediction {
  const QualityPrediction({required this.labelId, required this.confidence});

  final String labelId;
  final double confidence;
}

class QualityFixturePreview {
  const QualityFixturePreview({
    required this.fixtureFile,
    required this.title,
    required this.outcome,
    required this.labelId,
    required this.confidence,
    required this.reason,
    required this.warning,
    required this.guidance,
    required this.topPredictions,
  });

  final String fixtureFile;
  final String title;
  final String outcome;
  final String? labelId;
  final double? confidence;
  final String? reason;
  final String warning;
  final String guidance;
  final List<QualityPrediction> topPredictions;

  String get confidenceText => confidence == null
      ? 'No label or confidence'
      : '${(confidence! * 100).round()}% confidence';
}

const citrusQualityFixtureModelId = 'citrus-quality-fixture';
const citrusQualityFixtureVersion = 'fixture-v0';
const citrusQualityFixtureWarning =
    'LABELLED FIXTURE (fixture-v0): Synthetic contract example only; not a '
    'real citrus quality assessment and not for commercial, food-safety or '
    'storage decisions.';
const citrusQualityGuidance =
    'Fresh and spoiled are dataset-backed visible-condition labels only; '
    'this fixture does not establish commercial grade, food safety or '
    'storage life.';
const citrusQualityAbstentionGuidance =
    'This fixture demonstrates abstention because no fresh or spoiled label '
    'is asserted; visible-condition labels come from the cited citrus dataset.';
const citrusQualityAbstentionReason =
    'Insufficient visible evidence to distinguish fresh from spoiled citrus '
    'in this labelled fixture.';

const citrusQualityFixtures = <QualityFixturePreview>[
  QualityFixturePreview(
    fixtureFile: 'citrus_quality_fresh.json',
    title: 'Fresh',
    outcome: 'assessed',
    labelId: 'fresh',
    confidence: 0.91,
    reason: null,
    warning: citrusQualityFixtureWarning,
    guidance: citrusQualityGuidance,
    topPredictions: [
      QualityPrediction(labelId: 'fresh', confidence: 0.91),
      QualityPrediction(labelId: 'spoiled', confidence: 0.09),
    ],
  ),
  QualityFixturePreview(
    fixtureFile: 'citrus_quality_spoiled.json',
    title: 'Spoiled',
    outcome: 'assessed',
    labelId: 'spoiled',
    confidence: 0.88,
    reason: null,
    warning: citrusQualityFixtureWarning,
    guidance: citrusQualityGuidance,
    topPredictions: [
      QualityPrediction(labelId: 'spoiled', confidence: 0.88),
      QualityPrediction(labelId: 'fresh', confidence: 0.12),
    ],
  ),
  QualityFixturePreview(
    fixtureFile: 'citrus_quality_abstention.json',
    title: 'Unable to assess',
    outcome: 'unable_to_assess',
    labelId: null,
    confidence: null,
    reason: citrusQualityAbstentionReason,
    warning: citrusQualityFixtureWarning,
    guidance: citrusQualityAbstentionGuidance,
    topPredictions: [],
  ),
];
