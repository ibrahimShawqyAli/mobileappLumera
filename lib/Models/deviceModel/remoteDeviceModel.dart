import 'dart:convert';

class DeviceModelLite {
  final Map<String, dynamic> raw;
  const DeviceModelLite(this.raw);

  factory DeviceModelLite.fromJson(Map<String, dynamic> json) =>
      DeviceModelLite(json);

  Map<String, dynamic> toJson() => raw;

  // ----- Common ids -----
  int? get serverId => (raw['id'] as num?)?.toInt(); // backend device PK
  int? get roomServerId => (raw['room_id'] as num?)?.toInt(); // backend room id

  // ----- Strings from API (with fallbacks) -----
  String get deviceUnitId => (raw['device_id'] ?? '').toString();
  String get type => (raw['device_type'] ?? raw['type'] ?? 'device').toString();

  String get iconPath =>
      (raw['icon_path']?.toString() ?? '').trim().isNotEmpty
          ? raw['icon_path'].toString()
          : 'assets/images/device.png';

  String get nickname => (raw['nickname'] ?? '').toString();
  String get nameRaw => (raw['name'] ?? '').toString();

  /// Preferred label for UI:
  /// nickname → name → device_id → "Device"
  String get displayName {
    if (nickname.trim().isNotEmpty) return nickname.trim();
    if (nameRaw.trim().isNotEmpty) return nameRaw.trim();
    if (deviceUnitId.trim().isNotEmpty) return deviceUnitId.trim();
    return 'Device';
  }

  // ----- Numbers/flags -----
  int get pin => (raw['pin'] as num?)?.toInt() ?? 0;
  bool get isActive => raw['is_active'] == true;

  // ----- Meta (may come as JSON string) -----
  Map<String, dynamic> get metaMap {
    final m = raw['meta'];
    if (m is Map<String, dynamic>) return m;
    if (m is String && m.isNotEmpty) {
      try {
        final decoded = jsonDecode(m);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return const {};
  }
}
