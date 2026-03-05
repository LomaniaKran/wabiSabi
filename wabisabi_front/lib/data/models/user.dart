class User {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String status;
  final List<String> strongSides;
  final List<String> needHelpIn;
  final bool isAcceptingAdvice;
  final bool isLookingForHelp;
  final Map<String, int> adviceStats;
  final bool isCurrentUser;

  const User({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.status,
    required this.strongSides,
    required this.needHelpIn,
    required this.isAcceptingAdvice,
    required this.isLookingForHelp,
    required this.adviceStats,
    required this.isCurrentUser,
  });

  int get totalAdviceCount {
    return adviceStats.values.fold(0, (sum, value) => sum + value);
  }
}