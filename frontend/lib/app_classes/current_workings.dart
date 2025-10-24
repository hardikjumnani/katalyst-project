class CurrentWorking {
  final String? cwId;
  final String title;
  final String description;
  final DateTime? createdAt;

  CurrentWorking({
    this.cwId,
    required this.title,
    required this.description,
    this.createdAt,
  });

  factory CurrentWorking.fromJson(Map<String, dynamic> json) {
    return CurrentWorking(
      cwId: json['cw_id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }
}