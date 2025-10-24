import 'user.dart';

class Comment {
  final String commentId;
  final String momentId;
  final String description;
  final DateTime createdAt;
  final User user;
  int reactionCount;
  bool hasReacted;

  Comment({
    required this.commentId,
    required this.momentId,
    required this.description,
    required this.createdAt,
    required this.user,
    this.reactionCount = 0,
    this.hasReacted = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['comment_id'],
      momentId: json['moment'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
      reactionCount: json['reaction_count'] ?? 0,
      hasReacted: json['has_reacted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'moment': momentId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'user': user.toJson(),
      'reaction_count': reactionCount,
      'has_reacted': hasReacted,
    };
  }
}
