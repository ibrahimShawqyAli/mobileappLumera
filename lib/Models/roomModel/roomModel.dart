class RoomModel {
  final int id; // local DB id
  final int serverId; // server_id من الـ backend
  final String name;
  final String iconPath;
  final int sortOrder;

  RoomModel({
    required this.id,
    required this.serverId,
    required this.name,
    required this.iconPath,
    required this.sortOrder,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: (map['id'] as num?)?.toInt() ?? -1, // local id
      serverId: (map['server_id'] as num?)?.toInt() ?? -1, // server id
      name: (map['name'] ?? '').toString(),
      iconPath: (map['icon_path'] ?? 'assets/images/room.png').toString(),
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  static List<RoomModel> fromList(List<Map<String, dynamic>> maps) {
    return maps.map(RoomModel.fromMap).toList();
  }

  factory RoomModel.empty() {
    return RoomModel(
      id: -1,
      serverId: -1,
      name: '',
      iconPath: 'assets/images/room.png',
      sortOrder: 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'server_id': serverId,
    'name': name,
    'icon_path': iconPath,
    'sort_order': sortOrder,
  };
}
