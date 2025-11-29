import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _prefs;

  /// Call once before runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ----------------- Backward compatibility -----------------
  static const _kToken = 'auth_token';

  static Future<bool> saveToken(String token) async {
    return _prefs.setString(_kToken, token);
  }

  static String? getToken() {
    return _prefs.getString(_kToken);
  }

  static Future<bool> removeToken() async {
    return _prefs.remove(_kToken);
  }

  // ----------------- New: Standardized auth keys -----------------
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUser = 'user';
  static const _kOverview = 'overview';

  // Access token
  static Future<bool> saveAccessToken(String token) =>
      _prefs.setString(_kAccessToken, token);

  static String? getAccessToken() => _prefs.getString(_kAccessToken);

  static Future<bool> removeAccessToken() => _prefs.remove(_kAccessToken);

  // Refresh token
  static Future<bool> saveRefreshToken(String token) =>
      _prefs.setString(_kRefreshToken, token);

  static String? getRefreshToken() => _prefs.getString(_kRefreshToken);

  static Future<bool> removeRefreshToken() => _prefs.remove(_kRefreshToken);

  // User (Map<String, dynamic>)
  static Future<bool> saveUser(Map<String, dynamic> user) =>
      _prefs.setString(_kUser, jsonEncode(user));

  static Map<String, dynamic>? getUser() {
    final raw = _prefs.getString(_kUser);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  static Future<bool> removeUser() => _prefs.remove(_kUser);

  // Overview (List<Map<String, dynamic>>)
  static Future<bool> saveOverview(List<Map<String, dynamic>> overview) =>
      _prefs.setString(_kOverview, jsonEncode(overview));

  static List<Map<String, dynamic>>? getOverview() {
    final raw = _prefs.getString(_kOverview);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .cast<Map<String, dynamic>>()
            .toList();
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> removeOverview() => _prefs.remove(_kOverview);

  /// Convenience: save both tokens at once
  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _prefs.setString(_kAccessToken, access);
    await _prefs.setString(_kRefreshToken, refresh);
  }

  /// Convenience: remove both tokens
  static Future<void> removeTokens() async {
    await _prefs.remove(_kAccessToken);
    await _prefs.remove(_kRefreshToken);
  }

  // ----------------- Generic helpers -----------------
  /// Save any primitive, Map, or List. Maps/Lists are JSON-encoded.
  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return _prefs.setString(key, value);
    if (value is bool) return _prefs.setBool(key, value);
    if (value is int) return _prefs.setInt(key, value);
    if (value is double) return _prefs.setDouble(key, value);
    if (value is List<String>) return _prefs.setStringList(key, value);

    // Fallback: encode Map/List/other to JSON string
    try {
      final encoded = jsonEncode(value);
      return _prefs.setString(key, encoded);
    } catch (_) {
      // As a last resort, store toString()
      return _prefs.setString(key, value.toString());
    }
  }

  /// Get any value. If it’s a JSON string representing Map/List, it will be decoded.
  static dynamic getData({required String key}) {
    final obj = _prefs.get(key);
    if (obj is String) {
      // Try to decode JSON for Map/List
      try {
        final decoded = jsonDecode(obj);
        return decoded;
      } catch (_) {
        return obj; // plain string
      }
    }
    return obj; // bool/int/double/List<String> or null
  }

  static Future<bool> removeData({required String key}) => _prefs.remove(key);

  /// Wipe everything (use with care)
  static Future<bool> clear() => _prefs.clear();
}
