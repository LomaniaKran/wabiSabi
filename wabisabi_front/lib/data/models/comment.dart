import 'package:wabisabi_front/data/models/reaction.dart';

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String text;
  final String? overlayImageUrl; // URL изображения с правками поверх арта
  final DateTime createdAt;
  final List<Reaction> reactions; // Типа "Совет помог"

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.text,
    this.overlayImageUrl,
    required this.createdAt,
    required this.reactions,
  });
}