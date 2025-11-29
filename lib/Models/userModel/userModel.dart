class UserModel {
  final int id;
  final String? name;
  final String? mobile;
  final String email;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.mobile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    name: json['name'] as String?,
    mobile: json['mobile'] as String?,
    email: (json['email'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mobile': mobile,
    'email': email,
  };
}
