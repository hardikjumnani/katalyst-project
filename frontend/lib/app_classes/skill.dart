class Skill {
  final String? skillId;
  final String name;
  final String level;
  final DateTime? createdAt;

  const Skill({
    this.skillId,
    required this.name,
    required this.level,
    this.createdAt,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      skillId: json['skill_id'],
      name: json['name'],
      level: json['level'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}