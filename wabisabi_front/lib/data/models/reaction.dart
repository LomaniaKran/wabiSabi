class Reaction {
  final String userId;
  final String type; // 'helpful', 'still_relevant', 'needs_clarity'
  final DateTime createdAt;

  Reaction({
    required this.userId,
    required this.type,
    required this.createdAt,
  });
}