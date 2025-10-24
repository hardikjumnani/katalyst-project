class User {
  String? id;
  String? username;
  String? email;
  String? password;
  String? password2;
  String? name;
  String? gender;
  String? headline;
  String? profileImage;
  String? about;
  String? countryCode;
  String? phoneNo;
  String? city;
  String? state;
  String? country;

  User({
    this.id,
    this.username,
    this.email,
    this.name,
    this.gender,
    this.headline,
    this.profileImage,
    this.about,
    this.countryCode,
    this.phoneNo,
    this.city,
    this.state,
    this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      gender: json['gender'],
      headline: json['headline'],
      profileImage: json['profile_image'],
      about: json['about'],
      phoneNo: json['phone_no'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'gender': gender,
      'headline': headline,
      'profile_image': profileImage,
      'about': about,
      'phone_no': phoneNo,
      'city': city,
      'state': state,
      'country': country,
    };
  }
}
