import 'package:flutter/material.dart';
import 'package:wabisabi_front/data/models/post.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';
import 'package:wabisabi_front/core/constants/text_styles.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final bool isSaved;
  final bool showDeleteButton; // Добавляем флаг для отображения кнопки удаления
  final VoidCallback? onDelete; // Колбэк для удаления
  final VoidCallback? onAvatarTap; // Колбэк для клика на аватар
  
  const PostCard({
    Key? key,
    required this.post,
    this.onTap,
    this.isSaved = false,
    this.showDeleteButton = false,
    this.onDelete,
    this.onAvatarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageGallery(context),
            if (post.description != null && post.description!.isNotEmpty)
              _buildDescription(),
            if (post.isAskingForHelp && post.question != null)
              _buildQuestionSection(),
            _buildCategories(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    post.timeAgo,
                    style: AppTextStyles.caption,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: post.commentCount > 0 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: post.commentCount > 0 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                          color: post.commentCount > 0 
                              ? AppColors.primary 
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildImageGallery(BuildContext context) {
  // Проверяем, есть ли изображения и не пустой ли список
  final bool hasImages = post.imageUrls.isNotEmpty;
  
  if (!hasImages) return const SizedBox.shrink(); // Вообще не показываем контейнер
  
  return SizedBox(
    height: 280,
    child: Stack(
      children: [
        PageView.builder(
          itemCount: post.imageUrls.length,
          itemBuilder: (context, index) {
            final imageUrl = post.imageUrls[index];
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Обрабатываем ошибку загрузки изображения
                  },
                ),
              ),
              child: imageUrl.isEmpty
                  ? Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : null,
            );
          },
        ),
        
        if (post.imageUrls.length > 1)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo_library,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Кнопка сохранения
        Positioned(
          top: 16,
          right: showDeleteButton ? 56 : 16,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isSaved ? 'Убрано из избранного' : 'Сохранено в избранное',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        
        if (showDeleteButton)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        
        // Полупрозрачная полоска с информацией об авторе (всегда показываем)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: hasImages
                    ? [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ]
                    : [
                        AppColors.primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '@${post.authorId}',
                          style: TextStyle(
                            color: hasImages ? Colors.white : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.isAskingForHelp)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.help_outline,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Нужен совет',
                            style: TextStyle(
                              color: Colors.white,
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
          ),
        ),
      ],
    ), // Если нет изображений, не показываем SizedBox
  );
}
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        post.description!,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.question!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: post.categories.map((category) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '#$category',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}