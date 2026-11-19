class CareTask {
  const CareTask({
    required this.id,
    required this.userId,
    this.plantId,
    required this.taskType,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    this.advisoryRationale,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? plantId;
  final String taskType;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status;
  final String? advisoryRationale;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';
  bool get isCancelled => status == 'cancelled';

  factory CareTask.fromJson(Map<String, dynamic> json) {
    return CareTask(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      plantId: json['plant_id'] as String?,
      taskType: json['task_type'] as String? ?? 'watering',
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String? ?? 'pending',
      advisoryRationale: json['advisory_rationale'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plant_id': plantId,
      'task_type': taskType,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'advisory_rationale': advisoryRationale,
    };
  }
}
