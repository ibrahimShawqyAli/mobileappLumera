class DeviceModel {
  final int id;
  final int? serverId; // NEW
  final String name;
  final String? nickname; // NEW
  final String device_unit_id;
  final String device_type;
  final String iconPath;
  final int roomId;
  final int pin;
  bool state;

  DeviceModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.device_type,
    required this.device_unit_id,
    required this.roomId,
    required this.pin,
    this.serverId, // NEW
    this.nickname, // NEW
    this.state = false,
  });

  factory DeviceModel.empty() => DeviceModel(
    id: 0,
    serverId: null,
    name: '',
    nickname: null,
    iconPath: 'assets/images/device.png',
    device_type: '',
    device_unit_id: '',
    roomId: 0,
    pin: 0,
  );

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: _asInt(map['id']),
      serverId: (map['server_id'] as num?)?.toInt(), // NEW
      name: (map['name'] ?? '').toString(),
      nickname: (map['nickname'] as String?)?.toString(), // NEW
      iconPath: (map['icon_path'] ?? 'assets/images/device.png').toString(),
      device_type: (map['device_type'] ?? '').toString(),
      device_unit_id: (map['device_unit_id'] ?? '').toString(),
      roomId: _asInt(map['room_id']),
      pin: _asInt(map['pin']),
    );
  }

  static List<DeviceModel> fromList(List<Map<String, dynamic>> rows) =>
      rows.map(DeviceModel.fromMap).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'server_id': serverId, // NEW
    'name': name,
    'nickname': nickname, // NEW
    'icon_path': iconPath,
    'device_type': device_type,
    'device_unit_id': device_unit_id,
    'room_id': roomId,
    'pin': pin,
    'state': state,
  };

  DeviceModel copyWith({
    int? id,
    int? serverId,
    String? name,
    String? nickname,
    String? device_unit_id,
    String? device_type,
    String? iconPath,
    int? roomId,
    int? pin,
    bool? state,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      iconPath: iconPath ?? this.iconPath,
      device_type: device_type ?? this.device_type,
      device_unit_id: device_unit_id ?? this.device_unit_id,
      roomId: roomId ?? this.roomId,
      pin: pin ?? this.pin,
      state: state ?? this.state,
    );
  }
}
