class RoomModelLite {
  final int id;
  final int homeId;
  final String name;
  final int? sortOrder;
  final bool isPrivate;
  final String? iconPath; // <-- add this

  RoomModelLite({
    required this.id,
    required this.homeId,
    required this.name,
    this.sortOrder,
    required this.isPrivate,
    this.iconPath,
  });

  factory RoomModelLite.fromJson(Map<String, dynamic> j) => RoomModelLite(
    id: j['id'] as int,
    homeId: j['home_id'] as int,
    name: (j['name'] ?? '').toString(),
    sortOrder: (j['sort_order'] as num?)?.toInt(),
    isPrivate:
        j['is_private'] == true ||
        j['is_private'] == 1 ||
        j['is_private'] == 'true',
    iconPath: (j['icon_path'] as String?)?.toString(), // <-- map it
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'home_id': homeId,
    'name': name,
    'sort_order': sortOrder,
    'is_private': isPrivate,
    'icon_path': iconPath, // <-- keep it
  };
}
