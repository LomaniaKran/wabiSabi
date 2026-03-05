import '../models/comment.dart';

class MockComments {
  static List<Comment> comments = [
    Comment(
      id: '1',
      postId: '1',
      authorId: 'watercolor_dreams',
      text: 'Попробуй уменьшить подбородок на 15-20% и сделать линию челюсти более плавной. Также советую подвинуть глаза чуть ниже.',
      imageUrls: [
        'https://images.unsplash.com/photo-1579546929662-711aa81148cf?w=400&auto=format&fit=crop',
      ],
      overlayImageUrl: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      helpfulUserIds: ['sakura_art', 'digital_wizard'], // Два пользователя отметили как полезный
      isMarkedAsHelpfulByAuthor: true, // Автор поста отметил как полезный
    ),
    Comment(
      id: '2',
      postId: '1',
      authorId: 'digital_wizard',
      text: 'Согласен с предыдущим комментарием. Добавлю, что стоит обратить внимание на пропорции носа - он немного великоват для такого лица.',
      imageUrls: null,
      overlayImageUrl: 'https://via.placeholder.com/400x300/8BA888/FFFFFF?text=Overlay+правка',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      helpfulUserIds: ['sakura_art'],
      isMarkedAsHelpfulByAuthor: true,
    ),
    Comment(
      id: '3',
      postId: '1',
      authorId: 'ink_master',
      text: 'Мне нравится стилизация! Может, стоит добавить больше деталей в волосы?',
      imageUrls: null,
      overlayImageUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      helpfulUserIds: [],
      isMarkedAsHelpfulByAuthor: false,
    ),
  ];

  // Метод для получения комментариев к посту
  static List<Comment> getCommentsForPost(String postId) {
    return comments.where((comment) => comment.postId == postId).toList();
  }

  // Метод для обновления комментария
  static void updateComment(Comment updatedComment) {
    final index = comments.indexWhere((c) => c.id == updatedComment.id);
    if (index != -1) {
      comments[index] = updatedComment;
    }
  }
}