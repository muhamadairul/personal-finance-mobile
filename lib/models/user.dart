class User {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? photoUrl;
  final bool isPro;
  final DateTime? subscriptionUntil;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.photoUrl,
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
    bool? isPro,
    DateTime? subscriptionUntil,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      photoUrl: photoUrl ?? this.photoUrl,
      isPro: isPro ?? this.isPro,
      subscriptionUntil: subscriptionUntil ?? this.subscriptionUntil,
    );
  }
}
