import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';
import 'package:wabisabi_front/data/models/user.dart';
import 'package:wabisabi_front/presentation/widgets/post_card.dart'; // Импортируем PostCard
import 'package:wabisabi_front/providers/auth_provider.dart';
import 'package:wabisabi_front/providers/providers.dart'; // Импортируем postFutureProvider
import 'login_screen.dart';
import 'profile_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showAppBar) setState(() => _showAppBar = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showAppBar) setState(() => _showAppBar = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.currentUser;

    if (!authState.isAuthenticated || currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // --- ЗАМЕНЯЕМ ПУСТОЕ ТЕЛО НА ЗАГРУЗКУ ПОСТОВ ---
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: _buildDrawer(context, currentUser),
      body: _buildPostsFeed(), // Новый метод для отображения ленты
    );
  }

  // --- AppBar и Drawer оставляем как есть ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        height: 4,
        width: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      centerTitle: true,
      leading: IconButton(icon: const Icon(Icons.search), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Поиск в разработке')))),
      actions: [Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openEndDrawer()))],
    );
  }

  Widget _buildDrawer(BuildContext context, User currentUser) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(radius: 30, backgroundColor: AppColors.surface, child: currentUser.avatarUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.network(currentUser.avatarUrl!, fit: BoxFit.cover)) : const Icon(Icons.person, size: 40, color: AppColors.primary)),
                const SizedBox(height: 12),
                Text(currentUser.username, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(currentUser.status ?? 'Пользователь', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _buildDrawerItem(icon: Icons.person_outline, title: 'Мой профиль', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: currentUser.id)));
          }),
          _buildDrawerItem(icon: Icons.settings_outlined, title: 'Настройки', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Настройки в разработке')))),
          _buildDrawerItem(icon: Icons.help_outline, title: 'Техподдержка', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Поддержка в разработке')))),
          const Divider(height: 32),
          _buildDrawerItem(icon: Icons.info_outline, title: 'О приложении', onTap: () { /* About Screen */ }),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.exit_to_app, color: AppColors.error),
              title: Text('Выйти', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.error.withOpacity(0.05),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  // --- НОВЫЙ МЕТОД ДЛЯ ЗАГРУЗКИ И ОТОБРАЖЕНИЯ ПОСТОВ ---
  Widget _buildPostsFeed() {
    // Наблюдаем за провайдером, который загружает посты
    final postsAsyncValue = ref.watch(postsFutureProvider);

    return postsAsyncValue.when(
      // Состояние загрузки
      loading: () => const Center(child: CircularProgressIndicator()),
      // Состояние ошибки
      error: (err, stack) => Center(child: Text('Ошибка загрузки ленты: $err')),
      // Состояние успеха - данные получены
      data: (posts) {
        // Если постов нет, показываем сообщение
        if (posts.isEmpty) {
          return const Center(
            child: Text(
              'Пока нет постов. Создайте первый!',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          );
        }
        // Если посты есть, отображаем их в виде списка
        return ListView.builder(
          controller: _scrollController, // Привязываем контроллер прокрутки
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            // Используем PostCard для отображения каждого поста
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: PostCard(
                post: post,
                // TODO: Реализовать onTap для перехода к PostDetailScreen
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Открытие деталей поста в разработке')));
                },
                // TODO: Реализовать isSaved и onDelete, если нужно
                // isSaved: _isPostSaved(post.id), 
                // onDelete: () => _deletePost(post.id),
              ),
            );
          },
        );
      },
    );
  }
}