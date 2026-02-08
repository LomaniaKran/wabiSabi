import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wabisabi_front/data/mock_data/mock_users.dart';
import 'package:wabisabi_front/data/mock_data/mock_posts.dart';
import 'package:wabisabi_front/data/models/user.dart';
import 'package:wabisabi_front/presentation/widgets/post_card.dart';
import 'package:wabisabi_front/core/constants/app_colors.dart';
import 'package:wabisabi_front/core/constants/text_styles.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  
  const ProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;
  int _selectedSection = 0;
  final PageController _pageController = PageController();
  final List<String> _savedPostIds = [];

  final List<String> _sections = [
    'Общая информация',
    'Посты',
    'Советы',
    'Комментарии',
  ];

  @override
  void initState() {
    super.initState();
    _user = MockUsers.getUserById(widget.userId);
    
    // Слушатель для скрытия/показа AppBar
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showAppBar) {
          setState(() => _showAppBar = false);
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_showAppBar) {
          setState(() => _showAppBar = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _isPostSaved(String postId) {
    return _savedPostIds.contains(postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280.0,
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
              backgroundColor: AppColors.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: AppColors.textPrimary,
              ),
              centerTitle: true, // Добавляем эту строку
              title: _showAppBar ? _buildAppBarTitle() : null,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildProfileHeader(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: _buildSectionCarousel(),
              ),
            ),
          ];
        },
        body: _buildSelectedSection(),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _showAppBar ? 1.0 : 0.0,
      child: Container(
        height: 4,
        width: 100, // Делаем ещё шире
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 70), // Отступ для AppBar
          
          // Аватар и основная информация
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: _user.avatarUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            _user.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                ),
                
                const SizedBox(width: 20),
                
                // Имя и статус
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user.username,
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      
                      // Статус (новичок/профи) - теперь пастельный
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_user.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(_user.status),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _user.status,
                          style: TextStyle(
                            color: _getStatusColor(_user.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Статусы в строку - обе плашки зелёные
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Тег "Даю/не даю советы"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _user.isAcceptingAdvice
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.textSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _user.isAcceptingAdvice
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _user.isAcceptingAdvice
                                      ? Icons.thumb_up
                                      : Icons.thumb_down,
                                  size: 14,
                                  color: _user.isAcceptingAdvice
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _user.isAcceptingAdvice
                                      ? 'Даю советы'
                                      : 'Не даю советов',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _user.isAcceptingAdvice
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Тег "Ищу/не ищу советы" - ТЕПЕРЬ ЗЕЛЁНЫЙ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _user.isLookingForHelp
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.textSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _user.isLookingForHelp
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _user.isLookingForHelp
                                      ? Icons.search
                                      : Icons.block,
                                  size: 14,
                                  color: _user.isLookingForHelp
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _user.isLookingForHelp
                                      ? 'Ищу советы'
                                      : 'Не ищу советов',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _user.isLookingForHelp
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
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
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'профи':
        return const Color(0xFF4CAF50); // Зелёный
      case 'любитель':
        return const Color(0xFF2196F3); // Синий
      case 'новичок':
        return const Color(0xFFFF9800); // Оранжевый
      default:
        return AppColors.primary;
    }
  }

  Widget _buildStatItem({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCarousel() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSection = index;
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _selectedSection == index
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                _sections[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _selectedSection == index
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _selectedSection == index
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedSection() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() => _selectedSection = index);
      },
      children: [
        // 1. Общая информация
        _buildGeneralInfoSection(),
        
        // 2. Посты пользователя
        _buildPostsSection(),
        
        // 3. Советы (заглушка)
        _buildPlaceholderSection('Раздел "Советы" в разработке'),
        
        // 4. Комментарии (заглушка)
        _buildPlaceholderSection('Раздел "Комментарии" в разработке'),
      ],
    );
  }

  Widget _buildGeneralInfoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Описание (био)
          if (_user.bio != null && _user.bio!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'О себе:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _user.bio!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          
          // Сильные стороны
          const Text(
            'Сильные стороны:',
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
            children: _user.strongSides.map((side) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  side,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary, // Чёрный текст
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Слабые стороны (бывшие "Нужна помощь в")
          const Text(
            'Слабые стороны:',
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
            children: _user.needHelpIn.map((area) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  area,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary, // Чёрный текст
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          
          // Кнопка редактирования (только для своего профиля)
          if (_user.isCurrentUser)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Переход к редактированию профиля
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Редактировать профиль'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    final userPosts = MockPosts.getPostsByAuthor(_user.id);
    
    if (userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Пока нет постов',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: PostCard(
            post: post,
            isSaved: _isPostSaved(post.id),
            onTap: () {
              // TODO: Переход к деталям поста
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderSection(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build,
            size: 60,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}