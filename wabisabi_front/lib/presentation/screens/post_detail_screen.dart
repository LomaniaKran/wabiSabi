import 'package:flutter/material.dart';
import 'package:wabisabi_front/data/models/post.dart';
import 'package:wabisabi_front/data/models/comment.dart';
import 'package:wabisabi_front/data/mock_data/mock_comments.dart';
import 'package:wabisabi_front/data/mock_data/mock_posts.dart';
import 'package:wabisabi_front/data/mock_data/mock_users.dart';
import 'package:wabisabi_front/presentation/widgets/comment_item.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';
import 'package:wabisabi_front/core/constants/text_styles.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  
  const PostDetailScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late List<Comment> _comments;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isDescriptionExpanded = false;
  final String _currentUserId = 'sakura_art';

  @override
  void initState() {
    super.initState();
    _loadComments();
    _commentController.addListener(_updateSendButton);
  }

  @override
  void dispose() {
    _commentController.removeListener(_updateSendButton);
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _updateSendButton() {
    setState(() {});
  }

  void _loadComments() {
    setState(() {
      _comments = MockComments.getCommentsForPost(widget.post.id);
    });
    _updatePostCommentCount();
  }

  void _updatePostCommentCount() {
    MockPosts.updateCommentCount(widget.post.id, _comments.length);
  }

  void _toggleMarkAsHelpfulByAuthor(String commentId) {
    setState(() {
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = _comments[index];
        _comments[index] = comment.copyWith(
          isMarkedAsHelpfulByAuthor: !comment.isMarkedAsHelpfulByAuthor,
        );
        MockComments.updateComment(_comments[index]);
      }
    });
  }

  void _toggleThankYou(String commentId) {
    setState(() {
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = _comments[index];
        
        if (comment.authorId == _currentUserId) {
          return;
        }
        
        List<String> updatedThankYouIds = List.from(comment.helpfulUserIds);
        
        if (comment.saidThankYou(_currentUserId)) {
          updatedThankYouIds.remove(_currentUserId);
        } else {
          updatedThankYouIds.add(_currentUserId);
        }
        
        _comments[index] = comment.copyWith(
          helpfulUserIds: updatedThankYouIds,
        );
        MockComments.updateComment(_comments[index]);
      }
    });
  }

  void _editComment(String commentId, String newText, List<String>? imageUrls, String? overlayImageUrl) {
    setState(() {
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = _comments[index];
        _comments[index] = comment.copyWith(
          text: newText,
          imageUrls: imageUrls,
          overlayImageUrl: overlayImageUrl,
          isEditing: false,
          isEdited: true,
        );
        MockComments.updateComment(_comments[index]);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Комментарий обновлён'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      authorId: _currentUserId,
      text: text,
      imageUrls: null,
      overlayImageUrl: null,
      createdAt: DateTime.now(),
      helpfulUserIds: [],
      isMarkedAsHelpfulByAuthor: false,
    );
    
    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
      _commentFocusNode.unfocus();
    });
    
    MockComments.comments.insert(0, newComment);
    _updatePostCommentCount();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Комментарий добавлен'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Удаление комментария
  void _deleteComment(String commentId) {
    setState(() {
      _comments.removeWhere((c) => c.id == commentId);
    });
    
    // Удаляем из MockComments
    MockComments.comments.removeWhere((c) => c.id == commentId);
    
    // Обновляем счётчик комментариев в посте
    _updatePostCommentCount();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Комментарий удалён'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Жалоба на комментарий
  void _reportComment(String commentId) {
    final comment = _comments.firstWhere((c) => c.id == commentId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Пожаловаться на комментарий'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Выберите причину жалобы:'),
            const SizedBox(height: 16),
            _buildReportReason('Спам или реклама'),
            _buildReportReason('Оскорбления или токсичность'),
            _buildReportReason('Не относится к теме'),
            _buildReportReason('Другое'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportReason(String reason) {
    return ListTile(
      title: Text(reason, style: const TextStyle(fontSize: 14)),
      leading: const Icon(Icons.flag_outlined, size: 20, color: AppColors.textSecondary),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Жалоба отправлена: $reason'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
        // TODO: Отправить жалобу на сервер
      },
      dense: true,
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Редактировать исходник'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Редактирование исходника в разработке'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_file, color: AppColors.primary),
                title: const Text('Прикрепить файл'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Прикрепление файла в разработке'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ],
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  final postAuthor = MockUsers.getUserById(widget.post.authorId);
  final isCurrentUserPost = widget.post.authorId == _currentUserId;
  final bool hasImages = widget.post.imageUrls.isNotEmpty && widget.post.imageUrls.first.isNotEmpty;

  return Scaffold(
    backgroundColor: AppColors.background,
    body: CustomScrollView(
      slivers: [
        // AppBar с кнопкой назад - показываем изображение только если оно есть
        SliverAppBar(
          expandedHeight: hasImages ? 300 : 100, // Уменьшаем высоту, если нет изображения
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary,
          ),
          title: Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          centerTitle: true,
          flexibleSpace: hasImages
              ? FlexibleSpaceBar(
                  background: Image.network(
                    widget.post.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.brush,
                        size: 50,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
        ),
        
        // ... остальной код

          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: postAuthor.avatarUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    postAuthor.avatarUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${widget.post.authorId}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                widget.post.timeAgo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (widget.post.isAskingForHelp)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Нужен совет',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (widget.post.description != null && widget.post.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.description!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.5,
                            ),
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          if (widget.post.description!.length > 150)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDescriptionExpanded = !_isDescriptionExpanded;
                                });
                              },
                              child: Text(
                                _isDescriptionExpanded ? 'Свернуть' : 'Показать полностью',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  if (widget.post.isAskingForHelp && widget.post.question != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.question_mark,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Автор просит совета:',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.post.question!,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: widget.post.categories.map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '#$category',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const Divider(height: 1),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              focusNode: _commentFocusNode,
                              decoration: const InputDecoration(
                                hintText: 'Написать комментарий...',
                                hintStyle: TextStyle(color: AppColors.textSecondary),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: 3,
                              minLines: 1,
                              onSubmitted: (_) => _addComment(),
                            ),
                          ),
                          
                          IconButton(
                            icon: Icon(
                              Icons.attach_file,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: _showAttachmentOptions,
                          ),
                          
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: _commentController.text.trim().isNotEmpty
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            onPressed: _commentController.text.trim().isNotEmpty
                                ? _addComment
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Комментарии (${_comments.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final comment = _comments[index];
                final commentAuthor = MockUsers.getUserById(comment.authorId);
                
                return CommentItem(
                  comment: comment,
                  author: commentAuthor,
                  isPostAuthor: widget.post.authorId == comment.authorId,
                  onMarkAsHelpful: () => _toggleMarkAsHelpfulByAuthor(comment.id),
                  onToggleThankYou: () => _toggleThankYou(comment.id),
                  isCurrentUserPost: isCurrentUserPost,
                  currentUserId: _currentUserId,
                  onEditComment: _editComment,
                  onDeleteComment: () => _deleteComment(comment.id),  // Добавить эту строку
                  onReportComment: () => _reportComment(comment.id),  // Добавить эту строку
                );
              },
              childCount: _comments.length,
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}