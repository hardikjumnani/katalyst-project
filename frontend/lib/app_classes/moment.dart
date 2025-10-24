import 'package:shakala/app_classes/user.dart';

class Moment {
  String? momentId;
  String? title;
  String? description;
  String? imageUrl;
  String? createdAt;
  bool? impactful;
  bool? disabled;
  User? user;
  int reactionCount;
  bool hasReacted;

  Moment({
    this.momentId,
    this.title,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.impactful,
    this.disabled,
    this.user,
    this.reactionCount = 0,
    this.hasReacted = false,
  });

  factory Moment.fromJson(Map<String, dynamic> json) {
    return Moment(
      momentId: json['moment_id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      impactful: json['impactful'],
      disabled: json['disabled'],
      user: User.fromJson(json['user']),
      reactionCount: json['reaction_count'] ?? 0,
      hasReacted: json['has_reacted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moment_id': momentId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt,
      'impactful': impactful,
      'disabled': disabled,
      'user': user?.toJson(),
      'reaction_count': reactionCount,
      'has_reacted': hasReacted,
    };
  }
}
