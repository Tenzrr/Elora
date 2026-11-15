import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/providers.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart' show LanguagePicker;

import 'package:go_router/go_router.dart';

const cropSlugs = [
  'tomato',
  'chilli',
  'citrus',
  'banana',
  'roses',
  'chrysanthemum',
];

class GardenScreen extends ConsumerWidget {
  const GardenScreen({this.module, super.key});
  final String? module;

  Future<void> editPlant(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? plant,
  ]) async {
    final t = AppLocalizations.of(context)!;
    final nickname = TextEditingController(
      text: plant?['nickname'] as String? ?? '',
    );
    final area = TextEditingController(
      text: plant?['growing_area'] as String? ?? '',
    );
    final form = GlobalKey<FormState>();
    var crop = plant?['crop_slug'] as String? ?? 'tomato';
    var busy = false;
    String? error;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialog) {
            return AlertDialog(
              title: Text(plant == null ? t.addPlant : t.edit),
              content: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: crop,
                        decoration: InputDecoration(labelText: t.crop),
                        items: cropSlugs
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: busy
                            ? null
                            : (value) => setDialog(() => crop = value!),
                      ),
                      TextFormField(
                        controller: nickname,
                        enabled: !busy,
                        maxLength: 80,
                        decoration: InputDecoration(labelText: t.nickname),
                      ),
                      TextFormField(
                        controller: area,
                        enabled: !busy,
                        maxLength: 160,
                        decoration: InputDecoration(labelText: t.area),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? t.requiredField
                            : null,
                      ),
                      if (error != null) Text(error!),
                      if (busy) const LinearProgressIndicator(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.pop(dialogContext),
                  child: Text(t.cancel),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          if (!form.currentState!.validate()) return;
                          setDialog(() {
                            busy = true;
                            error = null;
                          });
                          try {
                            await ref
                                .read(apiProvider)
                                .request(
                                  plant == null ? 'POST' : 'PATCH',
                                  plant == null
                                      ? '/plants'
                                      : '/plants/${plant['id']}',
                                  revision: plant?['revision'] as int?,
                                  body: {
                                    'crop_slug': crop,
                                    'growing_area': area.text.trim(),
                                    'nickname': nickname.text.trim().isEmpty
                                        ? null
                                        : nickname.text.trim(),
                                  },
                                );
                            ref.invalidate(plantsProvider);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (e) {
                            // Close/reload after a conflict; never silently overwrite a new revision.
                            ref.invalidate(plantsProvider);
                            if (dialogContext.mounted) {
                              setDialog(() {
                                busy = false;
                                error =
                                    e is ApiException &&
                                        e.code == 'REVISION_CONFLICT'
                                    ? t.conflict
                                    : t.actionFailed;
                              });
                            }
                          }
                        },
                  child: Text(t.save),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      // Dialog animations may still reference controllers after pop.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      nickname.dispose();
      area.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final titles = [
      t.garden,
      t.cropHealth,
      t.quality,
      t.farming,
      t.assistant,
      t.community,
    ];
    final modules = [
      'garden',
      'crop-health',
      'quality',
      'farming',
      'assistant',
      'community',
    ];
    final index = modules.indexOf(module ?? 'garden');
    final selected = index < 0 ? 0 : index;
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selected]),
        actions: [
          const LanguagePicker(),
          IconButton(
            tooltip: t.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await ref.read(firebaseAuthProvider).signOut();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(t.actionFailed)));
                }
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              for (var i = 0; i < modules.length; i++)
                ListTile(
                  title: Text(titles[i]),
                  selected: selected == i,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(i == 0 ? '/garden' : '/feature/${modules[i]}');
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: selected == 0 && profile.asData?.value != null
          ? FloatingActionButton(
              tooltip: t.addPlant,
              onPressed: () => editPlant(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.actionFailed),
              FilledButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: Text(t.retry),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          if (selected != 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.notImplemented, textAlign: TextAlign.center),
              ),
            );
          }
          return ref
              .watch(plantsProvider)
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, stack) => Center(
                  child: FilledButton(
                    onPressed: () => ref.invalidate(plantsProvider),
                    child: Text(t.retry),
                  ),
                ),
                data: (plants) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(plantsProvider);
                    await ref.read(plantsProvider.future);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        '${t.welcome}, ${profile['display_name']}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      if (plants.isEmpty) Text(t.noPlants),
                      for (final plant in plants)
                        Card(
                          child: ListTile(
                            title: Text(
                              plant['nickname'] as String? ??
                                  plant['crop_slug'] as String,
                            ),
                            subtitle: Text(plant['growing_area'] as String),
                            onTap: () => editPlant(context, ref, plant),
                            trailing: IconButton(
                              tooltip: t.deletePlant,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: Text(t.deleteConfirm),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: Text(t.cancel),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: Text(t.deletePlant),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed != true) return;
                                try {
                                  await ref
                                      .read(apiProvider)
                                      .request(
                                        'DELETE',
                                        '/plants/${plant['id']}',
                                        revision: plant['revision'] as int,
                                      );
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(t.actionFailed)),
                                    );
                                  }
                                } finally {
                                  ref.invalidate(plantsProvider);
                                }
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}
