import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';        // Добавляем импорт Post
import '../data/models/comment.dart';     // Добавляем импорт Comment
import '../data/repositories/post_repository.dart';
import '../data/repositories/comment_repository.dart';
import '../data/repositories/user_repository.dart';

// Репозитории
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final repo = PostRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final repo = CommentRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Потоки данных
final postsStreamProvider = StreamProvider<List<Post>>((ref) {
  return ref.watch(postRepositoryProvider).postsStream;
});

final userPostsProvider = FutureProvider.family<List<Post>, String>((ref, userId) async {
  return ref.watch(postRepositoryProvider).getPostsByAuthor(userId);
});

final postCommentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  return ref.watch(commentRepositoryProvider).getCommentsForPost(postId);
});