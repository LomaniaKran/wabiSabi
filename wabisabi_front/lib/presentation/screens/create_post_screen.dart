import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wabisabi_front/data/models/post.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';
import 'package:wabisabi_front/providers/providers.dart';
import 'package:wabisabi_front/providers/auth_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  bool _isAskingForHelp = false;
  bool _isLoading = false;
  List<String> _selectedCategories = [];
  List<String> _imageUrls = []; 
  
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

  Future<void> _createPost() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте описание поста'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).currentUser;
      if (user == null) throw Exception("Пользователь не авторизован");

      // Формируем новый пост
      final newPost = Post(
        id: '', // Сервер сам сгенерирует
        authorId: user.id,
        authorUsername: user.username,
        authorAvatarUrl: user.avatarUrl,
        description: _descriptionController.text.trim(),
        imageUrls: _imageUrls, 
        categories: _selectedCategories.isEmpty ? ['Общее'] : _selectedCategories,
        isAskingForHelp: _isAskingForHelp,
        question: _isAskingForHelp ? _questionController.text.trim() : null,
      );

      // Отправляем на сервер
      await ref.read(postRepositoryProvider).createPost(newPost);

      if (mounted) {
        Navigator.pop(context, true); // Возвращаем true, чтобы сказать, что пост создан
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пост опубликован!'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка публикации: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: const Text('Создать пост', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          _isLoading 
            ? const Padding(padding: EdgeInsets.only(right: 20), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
            : TextButton(
                onPressed: _createPost,
                child: const Text('Опубликовать', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Описание', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Расскажите о своей работе...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            
            // Заглушка для выбора картинок (пока работает так)
            GestureDetector(
              onTap: () {
                 setState(() {
                  _imageUrls = _imageUrls.isEmpty 
                    ? ['https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800https://images.unsplash.com/photo-1611605698335-8b1569810432?w=800&auto=format&fit=crop'] 
                    : [];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _imageUrls.isEmpty ? AppColors.divider : AppColors.primary)),
                child: Center(child: Text(_imageUrls.isEmpty ? 'Добавить изображение' : 'Изображение добавлено')),
              ),
            ),
            
            const SizedBox(height: 20),
            const Text('Категории', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: _availableCategories.map((cat) => FilterChip(
                label: Text(cat),
                selected: _selectedCategories.contains(cat),
                onSelected: (val) => setState(() => val ? _selectedCategories.add(cat) : _selectedCategories.remove(cat)),
              )).toList(),
            ),
            
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Нужен совет'),
              value: _isAskingForHelp,
              onChanged: (val) => setState(() => _isAskingForHelp = val),
            ),
            if (_isAskingForHelp)
              TextField(controller: _questionController, decoration: const InputDecoration(hintText: 'О чем спросить?')),
          ],
        ),
      ),
    );
  }
}