import '../models/post.dart';
import '../mock_data/mock_posts.dart';
import 'dart:async';

class PostRepository {
  final List<Post> _posts = [];
  final _controller = StreamController<List<Post>>.broadcast();

  PostRepository() {
    _init();
  }

  void _init() {
    _posts.addAll(MockPosts.posts);
    _controller.add(_posts);
  }

  Stream<List<Post>> get postsStream => _controller.stream;

  List<Post> getPosts() {
    return List.unmodifiable(_posts);
  }

  List<Post> getPostsByAuthor(String authorId) {
    return _posts.where((post) => post.authorId == authorId).toList();
  }

  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  void addPost(Post post) {
    _posts.insert(0, post);
    _controller.add(_posts);
  }

  void deletePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    _controller.add(_posts);
  }

  void updatePostCommentCount(String postId, int count) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(commentCount: count);
      _controller.add(_posts);
    }
  }

  void dispose() {
    _controller.close();
  }
}