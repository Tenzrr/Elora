import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/care_task.dart';
import '../models/weather_data.dart';
import '../providers/care_task_provider.dart';
import '../providers/weather_provider.dart';

class FarmingScreen extends ConsumerWidget {
  const FarmingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocation = ref.watch(selectedLocationProvider);
    final weatherAsync = ref.watch(farmingWeatherProvider);

    return Scaffold(
      backgroundColor: EloraColors.cream,
      body: RefreshIndicator(
        color: EloraColors.deepGreen,
        onRefresh: () async {
          ref.invalidate(farmingWeatherProvider);
          await ref.read(careTasksProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Location Header & Manual Selector (REQ-3.1)
              _buildLocationHeader(context, ref, selectedLocation),
              const SizedBox(height: 16),

              // 2. Weather & Advisory Content States
              weatherAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: EloraColors.leafGreen,
                    ),
                  ),
                ),
                error: (error, _) => _buildErrorCard(context, ref, error),
                data: (weather) => _buildWeatherContent(context, ref, weather),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader(
    BuildContext context,
    WidgetRef ref,
    String selectedLocation,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EloraColors.mint.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: EloraColors.deepGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: EloraColors.leafGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farming Area',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: EloraColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  selectedLocation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EloraColors.deepGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLocation,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: EloraColors.deepGreen),
              borderRadius: BorderRadius.circular(16),
              items: presetFarmingLocations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(
                    location,
                    style: const TextStyle(
                      color: EloraColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newLocation) {
                if (newLocation != null && newLocation != selectedLocation) {
                  ref
                      .read(selectedLocationProvider.notifier)
                      .setLocation(newLocation);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(
    BuildContext context,
    WidgetRef ref,
    WeatherForecastResponse weather,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Source & Freshness Attribution (REQ-3.2 / BR-03)
        _buildFreshnessChip(context, weather),
        const SizedBox(height: 16),

        // Prominent Explainable Advisory Card (REQ-3.4 / BR-13)
        _buildAdvisoryCard(context, ref, weather.advisory),
        const SizedBox(height: 24),

        // Section: "A Little Care, Next" (REQ-3.5 / Issue #70)
        _buildCareTasksSection(context, ref, weather.advisory),
        const SizedBox(height: 24),

        // Section Title: Current Conditions
        Text(
          'Current Weather',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: EloraColors.deepGreen,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),

        // 4-Card Current Weather Grid
        _buildMetricsGrid(context, weather),
        const SizedBox(height: 24),

        // Section Title: 7-Day Daily Forecast
        Text(
          '7-Day Forecast',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: EloraColors.deepGreen,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),

        // Daily Forecast Strip
        _buildDailyForecastList(context, weather),
      ],
    );
  }

  Widget _buildFreshnessChip(
    BuildContext context,
    WeatherForecastResponse weather,
  ) {
    final isStale = weather.isStale;
    final timeStr =
        '${weather.retrievalTime.hour.toString().padLeft(2, '0')}:${weather.retrievalTime.minute.toString().padLeft(2, '0')} UTC';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isStale ? const Color(0xFFFFF3CD) : EloraColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStale ? const Color(0xFFFFEEBA) : EloraColors.mint,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStale ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 16,
            color: isStale ? const Color(0xFF856404) : EloraColors.leafGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Source: ${weather.source} • Retrieved: $timeStr${isStale ? ' (Stale)' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: isStale ? const Color(0xFF856404) : EloraColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard(
    BuildContext context,
    WidgetRef ref,
    FarmingAdvisory advisory,
  ) {
    final isDelay = advisory.action == 'DELAY_IRRIGATION';
    final isWithheld = advisory.action == 'ADVISORY_WITHHELD';

    Color cardColor;
    Color accentColor;
    IconData icon;

    if (isWithheld) {
      cardColor = const Color(0xFFF1F3F5);
      accentColor = EloraColors.muted;
      icon = Icons.pause_circle_outline;
    } else if (isDelay) {
      cardColor = const Color(0xFFFFF8E7);
      accentColor = const Color(0xFFD97706);
      icon = Icons.water_drop_outlined;
    } else {
      cardColor = const Color(0xFFF0FDF4);
      accentColor = EloraColors.leafGreen;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARE RECOMMENDATION',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      advisory.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: EloraColors.ink,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            advisory.reasoning,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: EloraColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          // Rule Threshold Context Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expected Rain: ${advisory.precipitationExpectedMm} mm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: EloraColors.ink,
                  ),
                ),
                Text(
                  'Threshold: ${advisory.thresholdMm} mm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: EloraColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (advisory.missingContextNotice != null) ...[
            const SizedBox(height: 10),
            Text(
              advisory.missingContextNotice!,
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: EloraColors.muted,
              ),
            ),
          ],
          if (!isWithheld) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showScheduleTaskDialog(context, ref, advisory),
                icon: const Icon(Icons.add_task, size: 18),
                label: Text(
                  isDelay ? 'Schedule Recommended Care (Rain Delay)' : 'Schedule Recommended Care',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCareTasksSection(
    BuildContext context,
    WidgetRef ref,
    FarmingAdvisory advisory,
  ) {
    final tasksAsync = ref.watch(careTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A Little Care, Next',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EloraColors.deepGreen,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Scheduled tasks & activity logs',
                  style: TextStyle(
                    fontSize: 12,
                    color: EloraColors.muted,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: EloraColors.leafGreen),
              tooltip: 'New Care Task',
              onPressed: () => _showScheduleTaskDialog(context, ref, advisory),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: EloraColors.leafGreen),
            ),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: EloraColors.danger.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: EloraColors.danger),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Could not load tasks. Pull to refresh.',
                    style: TextStyle(fontSize: 13, color: EloraColors.muted),
                  ),
                ),
              ],
            ),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EloraColors.mint.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.spa_outlined,
                      size: 36,
                      color: EloraColors.leafGreen.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No care tasks scheduled yet',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: EloraColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add a task following today\'s weather advisory to maintain optimal plant health.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: EloraColors.muted),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildCareTaskCard(context, ref, task);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCareTaskCard(
    BuildContext context,
    WidgetRef ref,
    CareTask task,
  ) {
    IconData icon;
    Color iconColor;
    switch (task.taskType) {
      case 'fertilizer':
        icon = Icons.eco_outlined;
        iconColor = const Color(0xFFD97706);
        break;
      case 'pruning':
        icon = Icons.content_cut_outlined;
        iconColor = const Color(0xFF9333EA);
        break;
      case 'harvest':
        icon = Icons.shopping_basket_outlined;
        iconColor = const Color(0xFFE11D48);
        break;
      default:
        icon = Icons.water_drop_outlined;
        iconColor = const Color(0xFF2563EB);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? EloraColors.leafGreen.withValues(alpha: 0.3)
              : EloraColors.mint.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: EloraColors.deepGreen.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: EloraColors.ink,
                      ),
                    ),
                    Text(
                      'Due: ${task.dueDate.day}/${task.dueDate.month} at ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: EloraColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTaskStatusPill(task),
            ],
          ),
          if (task.advisoryRationale != null) ...[
            const SizedBox(height: 8),
            Text(
              task.advisoryRationale!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: EloraColors.muted,
              ),
            ),
          ],
          if (task.isPending) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                    foregroundColor: EloraColors.muted,
                    side: BorderSide(color: EloraColors.muted.withValues(alpha: 0.3)),
                  ),
                  onPressed: () => ref.read(careTasksProvider.notifier).skipTask(
                        task.id,
                        notes: 'Skipped by grower',
                      ),
                  icon: const Icon(Icons.skip_next, size: 16),
                  label: const Text('Skip', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                    backgroundColor: EloraColors.leafGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => ref.read(careTasksProvider.notifier).completeTask(
                        task.id,
                        notes: 'Completed by grower',
                      ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskStatusPill(CareTask task) {
    Color bg;
    Color fg;
    String label;

    if (task.isCompleted) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      label = 'Completed';
    } else if (task.isSkipped) {
      bg = const Color(0xFFF3F4F6);
      fg = EloraColors.muted;
      label = 'Skipped';
    } else if (task.isCancelled) {
      bg = const Color(0xFFFEE2E2);
      fg = EloraColors.danger;
      label = 'Cancelled';
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  void _showScheduleTaskDialog(
    BuildContext context,
    WidgetRef ref,
    FarmingAdvisory advisory,
  ) {
    final titleController = TextEditingController(
      text: advisory.action == 'DELAY_IRRIGATION'
          ? 'Check soil & reschedule watering'
          : 'Water plants (Normal care)',
    );
    final descController = TextEditingController(
      text: 'Based on weather advisory: ${advisory.title}',
    );
    String selectedType = 'watering';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Schedule Care Task',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: EloraColors.deepGreen,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Task Type',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'watering', child: Text('Watering')),
                      DropdownMenuItem(value: 'fertilizer', child: Text('Fertilizer')),
                      DropdownMenuItem(value: 'pruning', child: Text('Pruning')),
                      DropdownMenuItem(value: 'harvest', child: Text('Harvest')),
                      DropdownMenuItem(value: 'pest_control', child: Text('Pest Control')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Context',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: EloraColors.deepGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      Navigator.pop(bottomSheetContext);
                      await ref.read(careTasksProvider.notifier).createTask(
                            taskType: selectedType,
                            title: title,
                            description: descController.text.trim(),
                            dueDate: DateTime.now().add(const Duration(hours: 1)),
                            advisoryRationale: advisory.reasoning,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Care task scheduled successfully!'),
                            backgroundColor: EloraColors.deepGreen,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Save Care Task',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildMetricsGrid(
    BuildContext context,
    WeatherForecastResponse weather,
  ) {
    final cur = weather.current;
    final units = weather.units;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          context,
          label: 'Temperature',
          value: '${cur.temperature} ${units.temperature}',
          icon: Icons.thermostat_outlined,
          color: const Color(0xFFE07A5F),
        ),
        _buildMetricCard(
          context,
          label: 'Precipitation',
          value: '${cur.precipitation} ${units.precipitation}',
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF3D84A8),
        ),
        _buildMetricCard(
          context,
          label: 'Humidity',
          value: '${cur.relativeHumidity} ${units.humidity}',
          icon: Icons.water_outlined,
          color: EloraColors.leafGreen,
        ),
        _buildMetricCard(
          context,
          label: 'Wind Speed',
          value: '${cur.windSpeed} ${units.windSpeed}',
          icon: Icons.air_outlined,
          color: const Color(0xFF81B29A),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EloraColors.mint.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: EloraColors.deepGreen.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: EloraColors.muted,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: EloraColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastList(
    BuildContext context,
    WeatherForecastResponse weather,
  ) {
    return Column(
      children: weather.daily.map((day) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: EloraColors.mint.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day.date,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: EloraColors.ink,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.water_drop,
                      size: 14, color: Color(0xFF3D84A8)),
                  const SizedBox(width: 4),
                  Text(
                    '${day.precipitationSum} mm',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: EloraColors.muted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${day.temperatureMax.round()}° / ${day.temperatureMin.round()}°',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: EloraColors.deepGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    WidgetRef ref,
    Object error,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EloraColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: EloraColors.danger, size: 48),
          const SizedBox(height: 12),
          Text(
            'Unable to Load Weather',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: EloraColors.ink,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Could not retrieve weather data. Please check your backend server or internet connection.',
            textAlign: TextAlign.center,
            style: TextStyle(color: EloraColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: EloraColors.deepGreen,
            ),
            onPressed: () {
              ref.invalidate(farmingWeatherProvider);
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
