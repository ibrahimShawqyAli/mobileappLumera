class HomeModel {
  final int id;
  final String name;
  final String timezone;
  final String role; // e.g., owner

  const HomeModel({
    required this.id,
    required this.name,
    required this.timezone,
    required this.role,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    id: json['id'] as int,
    name: (json['name'] ?? '').toString(),
    timezone: (json['timezone'] ?? '').toString(),
    role: (json['role'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'timezone': timezone,
    'role': role,
  };
}
