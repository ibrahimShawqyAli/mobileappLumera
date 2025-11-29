class MemberModel {
  final int userId;
  final String name;
  final String email;
  final String mobile;
  final String role;
  final List<RoomAccess> allowedRooms;

  MemberModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    required this.allowedRooms,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      userId: json['user_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? 'member',
      allowedRooms:
          (json['allowed_rooms'] as List<dynamic>?)
              ?.map((r) => RoomAccess.fromJson(r))
              .toList() ??
          [],
    );
  }
}

class RoomAccess {
  final int id;
  final String name;

  RoomAccess({required this.id, required this.name});

  factory RoomAccess.fromJson(Map<String, dynamic> json) {
    return RoomAccess(id: json['id'], name: json['name'] ?? '');
  }
}
