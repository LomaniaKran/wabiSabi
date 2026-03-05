import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wabisabi_front/data/mock_data/mock_users.dart';
import 'package:wabisabi_front/data/mock_data/mock_posts.dart';
import 'package:wabisabi_front/data/models/post.dart';
import 'package:wabisabi_front/data/models/user.dart';
import 'package:wabisabi_front/presentation/screens/create_post_screen.dart';
import 'package:wabisabi_front/presentation/screens/post_detail_screen.dart';
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
  late List<Post> _userPosts;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;
  int _selectedSection = 0;
  final PageController _pageController = PageController();
  final List<String> _savedPostIds = [];
  final String _currentUserId = 'sakura_art'; // ID текущего пользователя

  final List<String> _sections = [
    'Общая информация',
    'Посты',
    'Советы',
    'Комментарии',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
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

  void _loadUserData() {
    setState(() {
      _user = MockUsers.getUserById(widget.userId);
      _userPosts = MockPosts.getPostsByAuthor(widget.userId);
    });
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadUserData();
    }
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

  void _toggleSavePost(String postId) {
    setState(() {
      if (_savedPostIds.contains(postId)) {
        _savedPostIds.remove(postId);
      } else {
        _savedPostIds.add(postId);
      }
    });
  }

  // Удаление поста
void _deletePost(String postId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Удалить пост?'),
      content: const Text('Это действие нельзя будет отменить.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _userPosts.removeWhere((post) => post.id == postId);
              // Удаляем из MockPosts
              MockPosts.posts.removeWhere((post) => post.id == postId);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Пост удалён'),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 1),
              ),
            );
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
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'эксперт':
        return const Color(0xFF9C27B0).withOpacity(0.8);
      case 'профи':
        return const Color(0xFF2196F3).withOpacity(0.8);
      case 'любитель':
        return const Color(0xFF4CAF50).withOpacity(0.8);
      case 'новичок':
        return const Color(0xFFFF9800).withOpacity(0.8);
      default:
        return AppColors.primary.withOpacity(0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwnProfile = _user.isCurrentUser;

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
              centerTitle: true,
              title: _showAppBar ? _buildAppBarTitle() : null,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildProfileHeader(isOwnProfile),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: _buildSectionCarousel(),
              ),
            ),
          ];
        },
        body: _buildSelectedSection(isOwnProfile),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _showAppBar ? 1.0 : 0.0,
      child: Center(
        child: Container(
          height: 4,
          width: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isOwnProfile) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 70),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user.username,
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      
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
                      
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
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

  Widget _buildSelectedSection(bool isOwnProfile) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() => _selectedSection = index);
      },
      children: [
        _buildGeneralInfoSection(isOwnProfile),
        _buildPostsSection(isOwnProfile),
        _buildPlaceholderSection('Раздел "Советы" в разработке'),
        _buildPlaceholderSection('Раздел "Комментарии" в разработке'),
      ],
    );
  }

  Widget _buildGeneralInfoSection(bool isOwnProfile) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_user.bio != null && _user.bio!.isNotEmpty) ...[
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                if (isOwnProfile)
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
          ),
        ),
      ],
    );
  }

Widget _buildPlaceholderSection(String text) {
  return CustomScrollView(
    slivers: [
      SliverFillRemaining(
        child: Center(
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
        ),
      ),
    ],
  );
}

  Widget _buildPostsSection(bool isOwnProfile) {
    final String currentUserId = 'sakura_art';
    
    if (_userPosts.isEmpty) {
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
              isOwnProfile 
                  ? 'У вас пока нет постов' 
                  : 'У пользователя пока нет постов',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            if (isOwnProfile) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  ).then((_) => _loadUserData());
                },
                icon: const Icon(Icons.add),
                label: const Text('Создать первый пост'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    return CustomScrollView(
      slivers: [
        // Шапка раздела с кнопкой создания поста
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOwnProfile ? 'Мои посты' : 'Посты пользователя',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isOwnProfile)
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreatePostScreen(),
                            ),
                          ).then((_) => _loadUserData());
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Список постов - используем SliverList вместо ListView.builder
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = _userPosts[index];
              final bool isOwnPost = post.authorId == currentUserId;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: PostCard(
                  post: post,
                  isSaved: _isPostSaved(post.id),
                  showDeleteButton: isOwnProfile && isOwnPost,
                  onDelete: (isOwnProfile && isOwnPost) ? () => _deletePost(post.id) : null,
                  onAvatarTap: () {
                    if (!isOwnProfile) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: post.authorId),
                        ),
                      );
                    }
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    ).then((_) => _loadUserData());
                  },
                ),
              );
            },
            childCount: _userPosts.length,
          ),
        ),
        
        // Добавляем отступ снизу
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }
}