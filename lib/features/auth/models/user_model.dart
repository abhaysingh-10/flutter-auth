class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? profilePicture;
  final bool isVerified;
  final String authProvider;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.profilePicture,
    required this.isVerified,
    required this.authProvider,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'],
      authProvider: json['auth_provider'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'is_verified': isVerified,
      'auth_provider': authProvider,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
