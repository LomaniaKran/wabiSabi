import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/models/comment.dart';
import '../data/repositories/post_repository.dart';
import '../data/repositories/comment_repository.dart';
import '../data/repositories/user_repository.dart';

// Репозитории
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// --- ИЗМЕНЕНИЯ ЗДЕСЬ: Переходим с StreamProvider на FutureProvider ---

final postsFutureProvider = FutureProvider<List<Post>>((ref) async {
  return ref.watch(postRepositoryProvider).fetchPosts();
});

// Получение постов автора
final userPostsProvider = FutureProvider.family<List<Post>, String>((ref, userId) async {
  final allPosts = await ref.watch(postRepositoryProvider).fetchPosts();
  return allPosts.where((post) => post.authorId == userId).toList();
});

// Комментарии
final postCommentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  // Тут нужно будет убедиться, что у тебя есть метод в CommentRepository
  return ref.watch(commentRepositoryProvider).getCommentsForPost(postId);
});