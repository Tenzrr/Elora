import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/care_task.dart';

/// AsyncNotifier managing the grower's list of plant care tasks (REQ-3.5).
class CareTasksNotifier extends AsyncNotifier<List<CareTask>> {
  @override
  Future<List<CareTask>> build() async {
    return _fetchTasks();
  }

  Future<List<CareTask>> _fetchTasks() async {
    final api = ref.read(apiProvider);
    try {
      final response = await api.request('GET', '/farming/tasks');
      final list = (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      return list.map(CareTask.fromJson).toList();
    } catch (_) {
      // In offline preview or before initial tasks are added, return empty list
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchTasks);
  }

  Future<void> createTask({
    String? plantId,
    String taskType = 'watering',
    required String title,
    String? description,
    required DateTime dueDate,
    String? advisoryRationale,
  }) async {
    final api = ref.read(apiProvider);
    await api.request(
      'POST',
      '/farming/tasks',
      body: {
        'plant_id': plantId,
        'task_type': taskType,
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'advisory_rationale': advisoryRationale,
      },
    );
    await refresh();
  }

  Future<void> completeTask(String taskId, {String? notes}) async {
    final api = ref.read(apiProvider);
    await api.request(
      'POST',
      '/farming/tasks/$taskId/complete',
      body: notes != null ? {'notes': notes} : null,
    );
    await refresh();
  }

  Future<void> skipTask(String taskId, {String? notes}) async {
    final api = ref.read(apiProvider);
    await api.request(
      'POST',
      '/farming/tasks/$taskId/skip',
      body: notes != null ? {'notes': notes} : null,
    );
    await refresh();
  }
}

final careTasksProvider =
    AsyncNotifierProvider<CareTasksNotifier, List<CareTask>>(
  CareTasksNotifier.new,
);
