import 'package:flutter/material.dart';
import 'package:wabisabi_front/data/mock_data/mock_posts.dart';
import 'package:wabisabi_front/data/models/post.dart';
import 'package:wabisabi_front/presentation/screens/login_screen.dart';
import 'package:wabisabi_front/presentation/screens/profile_screen.dart';
import 'package:wabisabi_front/presentation/widgets/post_card.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<String> _savedPostIds = [];
  late List<Post> _posts;

  @override
  void initState() {
    super.initState();
    _posts = MockPosts.posts;
  }

  bool _isPostSaved(String postId) {
    return _savedPostIds.contains(postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: _buildDrawer(context),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        height: 4,
        width: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Фильтры поиска будут реализованы позже'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: AppColors.surface,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: AppColors.primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Гость',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Войдите для доступа ко всем функциям',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Пункт меню: Профиль
        _buildDrawerItem(
          icon: Icons.person_outline,
          title: 'Мой профиль',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userId: 'sakura_art', // ID текущего пользователя
                ),
              ),
            );
          },
        ),
        
        // Пункт меню: Настройки (возвращаем!)
        _buildDrawerItem(
          icon: Icons.settings_outlined,
          title: 'Настройки',
          onTap: () {
            Navigator.pop(context);
            // TODO: Переход к настройкам
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Раздел настроек в разработке'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        
        // Пункт меню: Техподдержка
        _buildDrawerItem(
          icon: Icons.help_outline,
          title: 'Техподдержка',
          onTap: () {
            Navigator.pop(context);
            // TODO: Переход к техподдержке
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Техподдержка будет доступна позже'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        
        const Divider(height: 32),
        
        // Пункт меню: О приложении
        _buildDrawerItem(
          icon: Icons.info_outline,
          title: 'О приложении',
          onTap: () {
            Navigator.pop(context);
            _showAboutAppDialog(context);
          },
        ),
        
        // Разделитель перед выходом
        const Divider(height: 32),
        
        // Пункт меню: Выйти (теперь только одна кнопка внизу)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: AppColors.error,
            ),
            title: Text(
              'Выйти',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: AppColors.error.withOpacity(0.05),
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    ),
  );
}
  Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? color,
}) {
  return ListTile(
    leading: Icon(icon, color: color ?? AppColors.textPrimary),
    title: Text(
      title,
      style: TextStyle(
        color: color ?? AppColors.textPrimary,
      ),
    ),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
  );
}

  Widget _buildBody() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: PostCard(
            post: post,
            isSaved: _isPostSaved(post.id),
            onTap: () {
              // TODO: Переход к деталям поста
              _showPostDetails(context, post);
            },
          ),
        );
      },
    );
  }

  void _showPostDetails(BuildContext context, Post post) {
    // TODO: Реализовать навигацию к детальному экрану
  }
  
  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.brush,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Wabi-Sabi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Сообщество художников для взаимопомощи',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Версия: 0.1.0 (Прототип)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Разработано в учебных целях',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Возможности:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('Делитесь процессом рисования'),
              _buildFeatureItem('Получайте советы от других художников'),
              _buildFeatureItem('Помогайте с правками через overlay'),
              _buildFeatureItem('Отмечайте полезные советы'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}