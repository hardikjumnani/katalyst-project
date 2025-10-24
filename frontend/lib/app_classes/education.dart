
class School {
  final String id;
  final String? icon;
  final String name;
  final String city;
  final String state;
  final String country;

  School({
    required this.id, 
    this.icon,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
  });

  factory School.fromJson(Map<String, dynamic> json) =>
    School(
      id: json['id'], 
      icon: json['icon'],
      name: json['name'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
}

class Degree {
  final String id;
  final String name;

  Degree({required this.id, required this.name});

  factory Degree.fromJson(Map<String, dynamic> json) =>
      Degree(id: json['id'], name: json['name']);
}

class FieldOfStudy {
  final String id;
  final String name;

  FieldOfStudy({required this.id, required this.name});
  
  factory FieldOfStudy.fromJson(Map<String, dynamic> json) =>
      FieldOfStudy(id: json['id'], name: json['name']);
}

class Education {
  final String? eduId;
  final School school;
  final Degree degree;
  final FieldOfStudy fieldOfStudy;
  final String startDate;
  final String? endDate;
  final DateTime? createdAt;

  const Education({
    this.eduId,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      eduId: json['education_id'] ?? '',
      school: School.fromJson(json['school']),
      degree: Degree.fromJson(json['degree']),
      fieldOfStudy: FieldOfStudy.fromJson(json['field_of_study']),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}