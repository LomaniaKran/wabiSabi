import 'package:flutter/material.dart';
import 'package:wabisabi_front/data/mock_data/mock_posts.dart';
import 'package:wabisabi_front/data/models/post.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  bool _isAskingForHelp = false;
  List<String> _selectedCategories = [];
  List<String> _imageUrls = []; // Для будущих изображений
  
  final List<String> _availableCategories = [
    'Анатомия', 'Стилизация', 'Линия', 'Пропорции',
    'Перспектива', 'Цвет', 'Атмосфера', 'Акварель',
    'Дизайн', 'Колористика', 'Неон', 'Свет',
    'Скетчинг', 'Позы', 'Комикс', 'Динамика',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _questionController.dispose();
    super.dispose();
  }

void _createPost() {
  if (_descriptionController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Добавьте описание поста'),
        backgroundColor: AppColors.error,
      ),
    );
    return;
  }

  // Если нет изображений, оставляем пустой список
  final newPost = Post(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    authorId: 'sakura_art',
    description: _descriptionController.text.trim(),
    imageUrls: _imageUrls, // Может быть пустым списком
    createdAt: DateTime.now(),
    categories: _selectedCategories.isEmpty 
        ? ['Новый пост'] 
        : _selectedCategories,
    isAskingForHelp: _isAskingForHelp,
    question: _questionController.text.trim().isNotEmpty 
        ? _questionController.text.trim() 
        : null,
    commentCount: 0,
  );

  MockPosts.posts.insert(0, newPost);
  
  Navigator.pop(context, true);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Пост опубликован!'),
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 1),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'Создать пост',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _createPost,
            child: const Text(
              'Опубликовать',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Поле для описания (теперь обязательное)
            const Text(
              'Описание',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Расскажите о своей работе...',
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
                fillColor: AppColors.surface,
              ),
              maxLines: 5,
              minLines: 3,
              autofocus: true,
            ),
            
            const SizedBox(height: 20),
            
            // Кнопка добавления изображений
            GestureDetector(
              onTap: () {
                // TODO: Добавить выбор изображений
                setState(() {
                  if (_imageUrls.isEmpty) {
                    _imageUrls = [
                      'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800&auto=format&fit=crop'
                    ];
                  } else {
                    _imageUrls = [];
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _imageUrls.isEmpty 
                        ? AppColors.divider 
                        : AppColors.primary,
                    width: _imageUrls.isEmpty ? 1 : 2,
                  ),
                ),
                child: _imageUrls.isEmpty
                    ? Column(
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Добавить изображения',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Нажмите, чтобы добавить фото (до 5 шт)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_imageUrls.length} изображение добавлено',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Нажмите, чтобы изменить',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Категории
            const Text(
              'Категории',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Переключатель "Нужен совет"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Нужен совет',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Отметьте, если хотите получить обратную связь',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _isAskingForHelp,
                    onChanged: (value) {
                      setState(() {
                        _isAskingForHelp = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  
                  if (_isAskingForHelp) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: 'О чём именно вы хотите спросить?',
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
                      ),
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}