class Experience {
  final String? expId;
  final String title;
  final String? description;
  final String companyName;
  final String? cityOrOnline;
  final String? state;
  final String? country;
  final String startDate;
  final String endDate;
  final DateTime? createdAt;

  const Experience({
    this.expId,
    required this.title,
    this.description,
    required this.companyName,
    this.cityOrOnline,
    this.state,
    this.country,
    required this.startDate,
    required this.endDate,
    this.createdAt,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      expId: json['exp_id'],
      title: json['title'],
      description: json['description'],
      companyName: json['company_name'],
      cityOrOnline: json['city_or_online'],
      state: json['state'],
      country: json['country'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}