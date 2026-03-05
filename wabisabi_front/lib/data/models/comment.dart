class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String text;
  final List<String>? imageUrls;
  final String? overlayImageUrl;
  final DateTime createdAt;
  final List<String> helpfulUserIds; // Кто сказал "Спасибо"
  final bool isMarkedAsHelpfulByAuthor; // Отметка автора поста
  bool isEditing = false; // Временное поле для UI
  bool isEdited = false; // Был ли отредактирован

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.text,
    this.imageUrls,
    this.overlayImageUrl,
    required this.createdAt,
    required this.helpfulUserIds,
    this.isMarkedAsHelpfulByAuthor = false,
    this.isEditing = false,
    this.isEdited = false,
  });

  // Количество пользователей, которые сказали "Спасибо"
  int get thankYouCount => helpfulUserIds.length;

  // Проверка, сказал ли пользователь "Спасибо"
  bool saidThankYou(String userId) {
    return helpfulUserIds.contains(userId);
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) return 'Только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays < 30) return '${difference.inDays} дн назад';
    
    final months = (difference.inDays / 30).floor();
    if (months < 12) return '$months мес назад';
    
    final years = (difference.inDays / 365).floor();
    return '$years г назад';
  }

  Comment copyWith({
    String? text,
    List<String>? helpfulUserIds,
    bool? isMarkedAsHelpfulByAuthor,
    bool? isEditing,
    bool? isEdited,
    List<String>? imageUrls,
    String? overlayImageUrl,
  }) {
    return Comment(
      id: id,
      postId: postId,
      authorId: authorId,
      text: text ?? this.text,
      imageUrls: imageUrls ?? this.imageUrls,
      overlayImageUrl: overlayImageUrl ?? this.overlayImageUrl,
      createdAt: createdAt,
      helpfulUserIds: helpfulUserIds ?? this.helpfulUserIds,
      isMarkedAsHelpfulByAuthor: isMarkedAsHelpfulByAuthor ?? this.isMarkedAsHelpfulByAuthor,
      isEditing: isEditing ?? this.isEditing,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}