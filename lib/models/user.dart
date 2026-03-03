class User {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? photoUrl;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool isPro;
  final DateTime? subscriptionUntil;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.photoUrl,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.isPro = false,
    this.subscriptionUntil,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String?,
      photoUrl: json['photo_url'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
      subscriptionUntil: json['subscription_until'] != null
          ? DateTime.tryParse(json['subscription_until'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'photo_url': photoUrl,
      'phone': phone,
      'address': address,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'gender': gender,
      'is_pro': isPro,
      'subscription_until': subscriptionUntil?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? token,
    String? photoUrl,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    bool? isPro,
    DateTime? subscriptionUntil,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isPro: isPro ?? this.isPro,
      subscriptionUntil: subscriptionUntil ?? this.subscriptionUntil,
    );
  }
}
