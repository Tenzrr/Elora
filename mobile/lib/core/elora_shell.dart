import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'theme/app_theme.dart';

enum EloraModule {
  quality('quality', Icons.eco_outlined),
  farming('farming', Icons.bar_chart_rounded),
  cropHealth('crop-health', Icons.center_focus_strong_rounded),
  assistant('assistant', Icons.chat_bubble_outline_rounded),
  community('community', Icons.groups_outlined);

  const EloraModule(this.slug, this.icon);

  final String slug;
  final IconData icon;

  String get path => '/feature/$slug';

  String title(AppLocalizations t) => switch (this) {
    quality => t.quality,
    farming => t.farming,
    cropHealth => t.cropHealth,
    assistant => t.assistant,
    community => t.community,
  };

  String label(AppLocalizations t) => switch (this) {
    quality => t.qualityTab,
    farming => t.farmingTab,
    cropHealth => t.scanTab,
    assistant => t.chatTab,
    community => t.community,
  };
}

class EloraShell extends StatelessWidget {
  const EloraShell({required this.path, required this.child, super.key});

  final String path;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final module = EloraModule.values
        .where((module) => module.path == path)
        .firstOrNull;
    final isProfile = path == '/profile';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isProfile ? t.profile : module?.title(t) ?? t.garden,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: EloraColors.deepGreen,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: EloraColors.mint,
        foregroundColor: EloraColors.deepGreen,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          if (path != '/garden')
            IconButton(
              tooltip: t.garden,
              onPressed: () => context.go('/garden'),
              icon: const Icon(Icons.yard_outlined),
            ),
          if (!isProfile)
            IconButton(
              tooltip: t.profile,
              onPressed: () => context.go('/profile'),
              icon: const Icon(Icons.account_circle_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
      bottomNavigationBar: EloraBottomNavigation(
        selected: module,
        onSelected: (module) => context.go(module.path),
      ),
    );
  }
}

class EloraBottomNavigation extends StatelessWidget {
  const EloraBottomNavigation({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final EloraModule? selected;
  final ValueChanged<EloraModule> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Stack(
      children: [
        const Positioned.fill(
          top: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: EloraColors.navigation,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final module in EloraModule.values)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: module == EloraModule.cropHealth ? 0 : 22,
                      ),
                      child: Semantics(
                        button: true,
                        selected: module == selected,
                        child: Tooltip(
                          message: module.title(t),
                          excludeFromSemantics: true,
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => onSelected(module),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _TabIcon(
                                      module: module,
                                      selected: selected == module,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      module.label(t),
                                      semanticsLabel: module.title(t),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: selected == module
                                                ? EloraColors.mint
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.module, required this.selected});

  final EloraModule module;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isScan = module == EloraModule.cropHealth;
    return Ink(
      width: isScan ? 54 : 46,
      height: isScan ? 54 : 32,
      decoration: BoxDecoration(
        color: selected || isScan ? EloraColors.mint : Colors.transparent,
        borderRadius: BorderRadius.circular(isScan ? 27 : 16),
        border: isScan ? Border.all(color: EloraColors.cream, width: 2) : null,
      ),
      child: Icon(
        module.icon,
        size: isScan ? 28 : 22,
        color: selected || isScan ? EloraColors.deepGreen : Colors.white,
      ),
    );
  }
}
