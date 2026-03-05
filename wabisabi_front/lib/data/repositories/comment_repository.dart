import '../models/comment.dart';
import '../mock_data/mock_comments.dart';
import 'dart:async';

class CommentRepository {
  final List<Comment> _comments = [];
  final _controller = StreamController<List<Comment>>.broadcast();

  CommentRepository() {
    _init();
  }

  void _init() {
    _comments.addAll(MockComments.comments);
    _controller.add(_comments);
  }

  Stream<List<Comment>> get commentsStream => _controller.stream;

  List<Comment> getCommentsForPost(String postId) {
    return _comments.where((comment) => comment.postId == postId).toList();
  }

  void addComment(Comment comment) {
    _comments.insert(0, comment);
    _controller.add(_comments);
  }

  void updateComment(Comment updatedComment) {
    final index = _comments.indexWhere((c) => c.id == updatedComment.id);
    if (index != -1) {
      _comments[index] = updatedComment;
      _controller.add(_comments);
    }
  }

  void deleteComment(String commentId) {
    _comments.removeWhere((c) => c.id == commentId);
    _controller.add(_comments);
  }

  void dispose() {
    _controller.close();
  }
}