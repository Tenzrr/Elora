import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'community_provider.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
    final TextEditingController _postController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(communityProvider.notifier).loadPosts(refresh: true);
      }
    });
  }
  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
  Future<void> _refresh() {
    return ref.read(communityProvider.notifier).loadPosts(refresh: true);
  }

  Future<void> _composePost() async {
    final t = AppLocalizations.of(context)!;
    final controller = _postController;
    controller.clear();
    bool previewed = false;
    bool saving = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final content = controller.text.trim();

            return AlertDialog(
              title: Text(t.communityCreatePost),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      minLines: 4,
                      maxLines: 7,
                      maxLength: 2000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: t.communityTextHint,
                        alignLabelWithHint: true,
                      ),
                      onChanged: (_) {
                        setDialogState(() => previewed = false);
                      },
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: content.isEmpty || saving
                          ? null
                          : () => setDialogState(() => previewed = true),
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(t.communityPreview),
                    ),
                    if (previewed) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: EloraColors.cream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: EloraColors.mint),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.communityPreview,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(content),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: Text(t.cancel),
                ),
                FilledButton(
                  onPressed: !previewed || content.isEmpty || saving
                      ? null
                      : () async {
                          setDialogState(() => saving = true);
                          final result = await ref
                              .read(communityProvider.notifier)
                              .createPost(content);

                          if (!dialogContext.mounted) return;

                          if (result) {
                            Navigator.of(dialogContext).pop(true);
                          } else {
                            setDialogState(() => saving = false);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.communitySaveDraft),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted) return;

    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.communityPostSaved)),
      );
    } else if (ref.read(communityProvider).errorCode != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.communitySaveFailed)),
      );
    }
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');

    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  Widget _postCard(
    BuildContext context,
    CommunityPost post,
    String authorName,
    AppLocalizations t,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFDCE9DF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 21,
                  backgroundColor: EloraColors.mint,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: EloraColors.deepGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: EloraColors.deepGreen,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: EloraColors.muted,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: EloraColors.mint.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: EloraColors.deepGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t.communityDraft,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: EloraColors.deepGreen,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SelectableText(
              post.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: EloraColors.ink,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(communityProvider);
    final profile = ref.watch(profileProvider).asData?.value;
    final authorName = profile?['display_name'] as String? ?? t.communityYou;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.communityMyPosts,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: EloraColors.deepGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton.filled(
                tooltip: t.communityCreatePost,
                onPressed: _composePost,
                style: IconButton.styleFrom(
                  backgroundColor: EloraColors.deepGreen,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: EloraColors.mint.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: EloraColors.deepGreen,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.communityPrivatePostsNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EloraColors.deepGreen,
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (state.isLoading && !state.hasLoaded)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.errorCode != null && state.posts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 36,
                      color: EloraColors.muted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.communityLoadFailed,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _refresh,
                      child: Text(t.retry),
                    ),
                  ],
                ),
              ),
            )
          else if (state.posts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.edit_note_rounded,
                      size: 44,
                      color: EloraColors.leafGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.communityNoPosts,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _composePost,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(t.communityCreatePost),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            for (final post in state.posts) ...[
              _postCard(context, post, authorName, t),
              const SizedBox(height: 12),
            ],
            if (state.nextCursor != null)
              OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                        .read(communityProvider.notifier)
                        .loadPosts(),
                child: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.communityLoadMore),
              ),
          ],
        ],
      ),
    );
  }
}
