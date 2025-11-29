import 'package:smart_home_iotz/Models/homeModel/home_overview.dart';
import 'package:smart_home_iotz/Models/userModel/auth_model.dart';
import 'package:smart_home_iotz/Models/userModel/userModel.dart';
import 'package:smart_home_iotz/shared/Cache/cacheHelper.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';

class AppSession {
  // In-memory globals
  static UserModel? currentUser;
  static String? accessToken;
  static String? refreshToken;
  static List<HomeOverview> overview = const [];

  /// Fill the session after login
  static void hydrateFromAuth(AuthResponse auth) {
    currentUser = auth.user;
    accessToken = auth.access;
    refreshToken = auth.refresh;
    overview = auth.overview;
    token = auth.access; // keep your existing global in sync if used elsewhere
  }

  /// Clear everything (e.g., on logout)
  static Future<void> clear() async {
    currentUser = null;
    accessToken = null;
    refreshToken = null;
    overview = const [];
    token = "";
    await CacheHelper.removeData(key: 'access_token');
    await CacheHelper.removeData(key: 'refresh_token');
    await CacheHelper.removeData(key: 'user');
    await CacheHelper.removeData(key: 'overview');
  }

  /// Restore from cache on app start
  static Future<void> bootstrap() async {
    final acc = await CacheHelper.getData(key: 'access_token');
    final ref = await CacheHelper.getData(key: 'refresh_token');
    final userJson = await CacheHelper.getData(key: 'user');
    final overviewJson = await CacheHelper.getData(key: 'overview');

    if (acc is String && acc.isNotEmpty) {
      accessToken = acc;
      token = acc; // sync your global token
    }
    if (ref is String && ref.isNotEmpty) {
      refreshToken = ref;
    }
    if (userJson is Map<String, dynamic>) {
      currentUser = UserModel.fromJson(userJson);
    }
    if (overviewJson is List) {
      overview =
          overviewJson
              .whereType<Map<String, dynamic>>()
              .map((e) => HomeOverview.fromJson(e))
              .toList();
    }
  }

  // ---------- Handy helpers you can call anywhere ----------
  static bool get isLoggedIn => (accessToken ?? '').isNotEmpty;

  static HomeOverview? firstHomeOverview() =>
      overview.isNotEmpty ? overview.first : null;

  static List<HomeOverview> homesByRole(String role) =>
      overview.where((h) => h.home.role == role).toList();

  static List roomsOfHome(int homeId) {
    final h = overview.firstWhere(
      (x) => x.home.id == homeId,
      orElse: () => firstHomeOverview() ?? overview.first,
    );
    return h.rooms;
  }

  // Find room by id across all homes
  static dynamic findRoomById(int roomId) {
    for (final hv in overview) {
      for (final r in hv.rooms) {
        if (r.id == roomId) return r;
      }
    }
    return null;
  }
}
