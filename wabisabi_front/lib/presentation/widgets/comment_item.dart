import 'package:flutter/material.dart';
import 'package:wabisabi_front/data/models/comment.dart';
import 'package:wabisabi_front/data/models/user.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';
import 'package:wabisabi_front/core/constants/text_styles.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final User author;
  final bool isPostAuthor;
  final VoidCallback onMarkAsHelpful;
  final VoidCallback onToggleThankYou;
  final bool isCurrentUserPost;
  final String currentUserId;
  final Function(String commentId, String newText, List<String>? imageUrls, String? overlayImageUrl) onEditComment;
  final VoidCallback onDeleteComment; // ДОЛЖЕН БЫТЬ
  final VoidCallback onReportComment; // ДОЛЖЕН БЫТЬ

  const CommentItem({
    Key? key,
    required this.comment,
    required this.author,
    required this.isPostAuthor,
    required this.onMarkAsHelpful,
    required this.onToggleThankYou,
    required this.isCurrentUserPost,
    required this.currentUserId,
    required this.onEditComment,
    required this.onDeleteComment, // Добавлено
    required this.onReportComment, // Добавлено
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final TextEditingController _editController = TextEditingController();
  List<String>? _tempImageUrls;
  String? _tempOverlayUrl;

  @override
  void initState() {
    super.initState();
    _editController.text = widget.comment.text;
    _tempImageUrls = widget.comment.imageUrls != null 
        ? List.from(widget.comment.imageUrls!) 
        : null;
    _tempOverlayUrl = widget.comment.overlayImageUrl;
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _saveEdit() {
    if (_editController.text.trim().isNotEmpty) {
      widget.onEditComment(
        widget.comment.id, 
        _editController.text.trim(),
        _tempImageUrls,
        _tempOverlayUrl,
      );
    }
  }
  

  void _showEditAttachmentOptions() {
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
                leading: Icon(Icons.image, color: AppColors.primary),
                title: const Text('Прикрепить изображение'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _tempImageUrls = [
                      'https://images.unsplash.com/photo-1579546929662-711aa81148cf?w=400&auto=format&fit=crop'
                    ];
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Изображение добавлено (демо-режим)'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.secondary),
                title: const Text('Добавить правки поверх арта'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _tempOverlayUrl = 'https://via.placeholder.com/400x300/8BA888/FFFFFF?text=Overlay+правка';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Правки добавлены (демо-режим)'),
                      duration: Duration(seconds: 1),
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

  void _showCommentOptions() {
    final isCommentByCurrentUser = widget.comment.authorId == widget.currentUserId;
    
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
              if (isCommentByCurrentUser) ...[
                ListTile(
                  leading: Icon(Icons.edit, color: AppColors.primary),
                  title: const Text('Редактировать комментарий'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      widget.comment.isEditing = true;
                      _editController.text = widget.comment.text;
                      _tempImageUrls = widget.comment.imageUrls != null 
                          ? List.from(widget.comment.imageUrls!) 
                          : null;
                      _tempOverlayUrl = widget.comment.overlayImageUrl;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Удалить комментарий'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation();
                  },
                ),
                const Divider(),
              ],
              ListTile(
                leading: Icon(Icons.flag, color: AppColors.textSecondary),
                title: const Text('Пожаловаться'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onReportComment();
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Удалить комментарий?'),
        content: const Text('Это действие нельзя будет отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteComment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCommentByCurrentUser = widget.comment.authorId == widget.currentUserId;
    final saidThankYou = widget.comment.saidThankYou(widget.currentUserId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.comment.isMarkedAsHelpfulByAuthor
              ? AppColors.primary
              : AppColors.divider,
          width: widget.comment.isMarkedAsHelpfulByAuthor ? 2 : 1,
        ),
        boxShadow: widget.comment.isMarkedAsHelpfulByAuthor
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: widget.comment.isEditing
          ? _buildEditMode()
          : _buildViewMode(isCommentByCurrentUser, saidThankYou),
    );
  }

  Widget _buildViewMode(bool isCommentByCurrentUser, bool saidThankYou) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
                child: widget.author.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          widget.author.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.primary,
                      ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '@${widget.author.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(width: 6),
                        
                        if (widget.isPostAuthor)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Автор поста',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        
                        if (widget.comment.isEdited)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              '(ред.)',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    Text(
                      widget.comment.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Кнопка отметки от автора поста
              if (widget.isCurrentUserPost && !isCommentByCurrentUser)
                Container(
                  decoration: BoxDecoration(
                    color: widget.comment.isMarkedAsHelpfulByAuthor
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      widget.comment.isMarkedAsHelpfulByAuthor
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: widget.comment.isMarkedAsHelpfulByAuthor
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: widget.onMarkAsHelpful,
                    tooltip: widget.comment.isMarkedAsHelpfulByAuthor
                        ? 'Убрать отметку'
                        : 'Отметить как полезный совет',
                  ),
                ),
              
              // Кнопка меню (три точки)
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: _showCommentOptions,
              ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            widget.comment.text,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
          ),
        ),
        
        // Изображения в комментарии
        if (widget.comment.imageUrls != null && widget.comment.imageUrls!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.comment.imageUrls!.map((url) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.divider,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        
        // Overlay изображение
        if (widget.comment.overlayImageUrl != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Правки поверх арта',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.divider,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.comment.overlayImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Нижняя панель с "Спасибо"
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              // Счётчик "Спасибо"
              if (widget.comment.thankYouCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.comment.thankYouCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(width: 12),
              
              if (!isCommentByCurrentUser)  // Добавить это условие
                TextButton.icon(
                  onPressed: widget.onToggleThankYou,
                  icon: Icon(
                    saidThankYou ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: saidThankYou ? AppColors.primary : AppColors.textSecondary,
                  ),
                  label: Text(
                    saidThankYou ? 'Спасибо' : 'Спасибо',
                    style: TextStyle(
                      fontSize: 12,
                      color: saidThankYou ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: saidThankYou ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: saidThankYou
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Редактирование комментария',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _editController,
            decoration: InputDecoration(
              hintText: 'Редактировать комментарий...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
            minLines: 2,
            autofocus: true,
          ),
          
          const SizedBox(height: 12),
          
          if (_tempImageUrls != null && _tempImageUrls!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Прикреплённые изображения:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tempImageUrls!.map((url) {
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tempImageUrls = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          
          if (_tempOverlayUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Правки поверх арта:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                          image: DecorationImage(
                            image: NetworkImage(_tempOverlayUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _tempOverlayUrl = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _showEditAttachmentOptions,
                icon: Icon(Icons.attach_file, size: 16, color: AppColors.primary),
                label: const Text('Прикрепить'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_tempImageUrls != null || _tempOverlayUrl != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _tempImageUrls = null;
                      _tempOverlayUrl = null;
                    });
                  },
                  icon: Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
                  label: const Text('Очистить'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.comment.isEditing = false;
                    _editController.text = widget.comment.text;
                    _tempImageUrls = widget.comment.imageUrls != null 
                        ? List.from(widget.comment.imageUrls!) 
                        : null;
                    _tempOverlayUrl = widget.comment.overlayImageUrl;
                  });
                },
                child: const Text('Отмена'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}