import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  final String id;
  final String userId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
    );
  }
}

class CommunityState {
  const CommunityState({
    this.posts = const [],
    this.nextCursor,
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasLoaded = false,
    this.errorCode,
  });

  final List<CommunityPost> posts;
  final String? nextCursor;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasLoaded;
  final String? errorCode;

  CommunityState copyWith({
    List<CommunityPost>? posts,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasLoaded,
    String? errorCode,
    bool clearError = false,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
    );
  }
}

class CommunityController extends Notifier<CommunityState> {
  @override
  CommunityState build() {
    ref.watch(
      authStateProvider.select((auth) => auth.asData?.value?.uid),
    );
    return const CommunityState();
  }

  Future<void> loadPosts({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && state.hasLoaded && state.nextCursor == null) return;

    final cursor = refresh ? null : state.nextCursor;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final path = cursor == null
          ? '/community/posts?limit=20'
          : '/community/posts?limit=20&cursor=$cursor';

      final response = await ref.read(apiProvider).request('GET', path)
          as Map;

      final items = (response['items'] as List)
          .map(
            (item) => CommunityPost.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      final combined = refresh || cursor == null
          ? items
          : [
              ...state.posts,
              ...items.where(
                (post) => !state.posts.any(
                  (existing) => existing.id == post.id,
                ),
              ),
            ];

      state = state.copyWith(
        posts: combined,
        nextCursor: response['next_cursor'] as String?,
        clearCursor: response['next_cursor'] == null,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorCode: error is ApiException
            ? error.code
            : 'REQUEST_FAILED',
      );
    }
  }

  Future<bool> createPost(String text) async {
    final content = text.trim();

    if (content.isEmpty || state.isSubmitting) return false;

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final response = await ref.read(apiProvider).request(
        'POST',
        '/community/posts',
        body: {'text': content},
      ) as Map;

      final post = CommunityPost.fromJson(
        Map<String, dynamic>.from(response),
      );

      state = state.copyWith(
        posts: [
          post,
          ...state.posts.where((item) => item.id != post.id),
        ],
        isSubmitting: false,
        hasLoaded: true,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorCode: error is ApiException
            ? error.code
            : 'REQUEST_FAILED',
      );

      return false;
    }
  }
}

final communityProvider =
    NotifierProvider<CommunityController, CommunityState>(
  CommunityController.new,
);
