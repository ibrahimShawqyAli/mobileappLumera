import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // --------------------------- OPEN ---------------------------
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'smarthome.db');
    return await openDatabase(
      path,
      version: 2, // << bump
      onConfigure: (db) async {
        // PRAGMAs that return rows -> use rawQuery
        final jm = await db.rawQuery(
          'PRAGMA journal_mode=WAL',
        ); // <- note no spaces around =
        await db.rawQuery('PRAGMA busy_timeout=10000');

        // This one is fine with execute
        await db.execute('PRAGMA foreign_keys = ON;');

        // (optional) log what SQLite actually set
        // debugPrint('journal_mode => $jm');
      },
      onCreate: (db, version) async {
        // USERS
        await db.execute('''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id INTEGER UNIQUE,
  name TEXT,
  email TEXT,
  mobile TEXT
);
''');

        // HOMES
        await db.execute('''
CREATE TABLE homes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id INTEGER UNIQUE NOT NULL,
  name TEXT NOT NULL,
  timezone TEXT,
  role TEXT
);
''');

        // ROOMS
        await db.execute('''
CREATE TABLE rooms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id INTEGER UNIQUE NOT NULL,
  home_server_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  icon_path TEXT NOT NULL DEFAULT 'assets/images/room.png',
  sort_order INTEGER
);
''');

        // DEVICES (now includes nickname; default icon matches helper)
        await db.execute('''
CREATE TABLE devices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id INTEGER,
  name TEXT NOT NULL,
  nickname TEXT,
  device_unit_id TEXT,
  device_type TEXT,
  icon_path TEXT NOT NULL DEFAULT 'assets/images/device.png',
  room_id INTEGER,
  room_server_id INTEGER,
  pin INTEGER DEFAULT 0
);
''');

        await db.execute('''
CREATE TABLE fast_actions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  device_unit_id TEXT NOT NULL,
  device_type TEXT,
  icon_path TEXT,
  room_id INTEGER,
  sort_order INTEGER
);
''');

        // Seed "Public"
        await db.insert('rooms', {
          'server_id': -1,
          'home_server_id': -1,
          'name': 'Public',
          'icon_path': 'assets/images/public.png',
          'sort_order': 0,
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add nickname to devices if coming from v1
          final cols = await db.rawQuery("PRAGMA table_info(devices)");
          final hasNickname = cols.any(
            (c) => (c['name'] as String) == 'nickname',
          );
          if (!hasNickname) {
            await db.execute("ALTER TABLE devices ADD COLUMN nickname TEXT");
          }
        }
      },
    );
  }

  // --------------------------- DEFAULT ICONS ---------------------------
  static String defaultRoomIcon(String name) {
    name = (name).toLowerCase();
    if (name.contains('bed')) return 'assets/images/bedroom.png';
    if (name.contains('living')) return 'assets/images/living.png';
    if (name.contains('kitchen')) return 'assets/images/kitchen.png';
    return 'assets/images/room.png';
  }

  // Keep consistent with DB default: 'assets/images/device.png'
  static String defaultDeviceIcon(String type) {
    type = (type).toLowerCase();
    if (type.contains('rgb')) return 'assets/images/color wheel icon.png';
    if (type.contains('ir')) return 'assets/images/remoteIR.png';
    if (type.contains('on-off') || type.contains('switch')) {
      return 'assets/images/switch.png';
    }
    return 'assets/images/device.png'; // << aligned
  }

  static String _normalizeRoomIcon(String? icon, String roomName) {
    final v = (icon ?? '').trim();
    return v.isNotEmpty ? v : defaultRoomIcon(roomName);
  }

  static String _normalizeDeviceIcon(String? incomingOrExisting, String type) {
    final v = (incomingOrExisting ?? '').trim();
    return v.isNotEmpty ? v : defaultDeviceIcon(type);
  }

  static String _bestDeviceName({
    String? nickname,
    String? name,
    required String unitId,
  }) {
    final nn = (nickname ?? '').trim();
    if (nn.isNotEmpty && nn.toLowerCase() != 'device') return nn;
    final nm = (name ?? '').trim();
    if (nm.isNotEmpty && nm.toLowerCase() != 'device') return nm;
    return unitId;
  }

  // =========================== USERS ===========================
  static Future<void> upsertUser({
    required int serverId,
    required String email,
    String? name,
    String? mobile,
  }) async {
    final db = await database;
    final cur = await db.query(
      'users',
      where: 'server_id=?',
      whereArgs: [serverId],
      limit: 1,
    );
    if (cur.isEmpty) {
      await db.insert('users', {
        'server_id': serverId,
        'name': name,
        'email': email,
        'mobile': mobile,
      });
    } else {
      await db.update(
        'users',
        {'name': name, 'email': email, 'mobile': mobile},
        where: 'server_id=?',
        whereArgs: [serverId],
      );
    }
  }

  static Future<Map<String, dynamic>?> getUserByServerId(int serverId) async {
    final db = await database;
    final r = await db.query(
      'users',
      where: 'server_id=?',
      whereArgs: [serverId],
      limit: 1,
    );
    return r.isEmpty ? null : r.first;
  }

  static Future<void> clearUsers() async {
    final db = await database;
    await db.delete('users');
  }

  // =========================== HOMES ===========================
  static Future<void> upsertHome({
    required int serverId,
    required String name,
    required String timezone,
    required String role,
  }) async {
    final db = await database;
    final cur = await db.query(
      'homes',
      where: 'server_id=?',
      whereArgs: [serverId],
      limit: 1,
    );
    if (cur.isEmpty) {
      await db.insert('homes', {
        'server_id': serverId,
        'name': name,
        'timezone': timezone,
        'role': role,
      });
    } else {
      await db.update(
        'homes',
        {'name': name, 'timezone': timezone, 'role': role},
        where: 'server_id=?',
        whereArgs: [serverId],
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getAllHomes() async {
    final db = await database;
    return db.query('homes', orderBy: 'name ASC');
  }

  static Future<Map<String, dynamic>?> getHomeByServerId(int serverId) async {
    final db = await database;
    final r = await db.query(
      'homes',
      where: 'server_id=?',
      whereArgs: [serverId],
      limit: 1,
    );
    return r.isEmpty ? null : r.first;
  }

  static Future<void> deleteHomeByServerId(int serverId) async {
    final db = await database;
    // Move rooms/devices to "Public"
    final public = await db.query(
      'rooms',
      where: 'server_id=?',
      whereArgs: [-1],
      limit: 1,
    );
    final publicId =
        public.isEmpty
            ? await db.insert('rooms', {
              'server_id': -1,
              'home_server_id': -1,
              'name': 'Public',
              'icon_path': 'assets/images/public.png',
              'sort_order': 0,
            })
            : public.first['id'] as int;

    final rooms = await db.query(
      'rooms',
      where: 'home_server_id=?',
      whereArgs: [serverId],
    );
    for (final r in rooms) {
      final localRoomId = r['id'] as int;
      await db.update(
        'devices',
        {'room_id': publicId, 'room_server_id': -1},
        where: 'room_id=?',
        whereArgs: [localRoomId],
      );
    }
    await db.delete('rooms', where: 'home_server_id=?', whereArgs: [serverId]);
    await db.delete('homes', where: 'server_id=?', whereArgs: [serverId]);
  }

  // =========================== ROOMS ===========================
  static Future<int> addRoom(String name, String iconPath) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(sort_order) as maxOrder FROM rooms',
    );
    final currentMax = result.first['maxOrder'] as int? ?? -1;
    final newOrder = currentMax + 1;
    return await db.insert('rooms', {
      'server_id': DateTime.now().millisecondsSinceEpoch * -1,
      'home_server_id': -1,
      'name': name,
      'icon_path': _normalizeRoomIcon(iconPath, name),
      'sort_order': newOrder,
    });
  }

  static Future<void> updateRoomSortOrder(List<int> roomIdsInOrder) async {
    final db = await database;
    final batch = db.batch();
    for (int i = 0; i < roomIdsInOrder.length; i++) {
      batch.update(
        'rooms',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [roomIdsInOrder[i]],
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<int> editRoom(
    int roomId,
    String newName,
    String iconPath,
  ) async {
    final db = await database;
    return await db.update(
      'rooms',
      {'name': newName, 'icon_path': _normalizeRoomIcon(iconPath, newName)},
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  static Future<void> deleteRoom(int roomId) async {
    final db = await database;
    final public = await db.query(
      'rooms',
      where: 'server_id=?',
      whereArgs: [-1],
      limit: 1,
    );
    final publicRoomId =
        public.isEmpty
            ? await db.insert('rooms', {
              'server_id': -1,
              'home_server_id': -1,
              'name': 'Public',
              'icon_path': 'assets/images/public.png',
              'sort_order': 0,
            })
            : public.first['id'] as int;

    await db.update(
      'devices',
      {'room_id': publicRoomId, 'room_server_id': -1},
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
    await db.delete('rooms', where: 'id = ?', whereArgs: [roomId]);
  }

  static Future<List<Map<String, dynamic>>> getAllRooms() async {
    final db = await database;
    return await db.query('rooms', orderBy: 'sort_order ASC');
  }

  static Future<int> ensureLocalRoomByServer({
    required int roomServerId,
    required int homeServerId,
    required String name,
    required int sortOrder,
    String? iconPath,
  }) async {
    final db = await database;
    final cur = await db.query(
      'rooms',
      where: 'server_id=?',
      whereArgs: [roomServerId],
      limit: 1,
    );
    if (cur.isNotEmpty) {
      final existingIcon = cur.first['icon_path'] as String?;
      await db.update(
        'rooms',
        {
          'home_server_id': homeServerId,
          'name': name,
          'icon_path': _normalizeRoomIcon(iconPath ?? existingIcon, name),
          'sort_order': sortOrder,
        },
        where: 'server_id=?',
        whereArgs: [roomServerId],
      );
      return cur.first['id'] as int;
    }

    final id = await db.insert('rooms', {
      'server_id': roomServerId,
      'home_server_id': homeServerId,
      'name': name,
      'icon_path': _normalizeRoomIcon(iconPath, name),
      'sort_order': sortOrder,
    });
    return id;
  }

  // =========================== DEVICES ===========================
  static Future<int> addDevice(
    String name,
    String deviceUnitId,
    String deviceType,
    int roomId,
    String iconPath, {
    int pin = 0,
  }) async {
    final db = await database;
    return await db.insert('devices', {
      'server_id': null,
      'name': name,
      'nickname': null,
      'device_unit_id': deviceUnitId,
      'device_type': deviceType,
      'room_id': roomId,
      'room_server_id': -1,
      'icon_path': iconPath,
      'pin': pin,
    });
  }

  static Future<int> editDevice(
    int deviceId, {
    required String newName,
    required String newType,
    required String newIconPath,
    required int newRoomId,
  }) async {
    final db = await database;
    return await db.update(
      'devices',
      {
        'name': newName,
        'device_type': newType,
        'icon_path': newIconPath,
        'room_id': newRoomId,
      },
      where: 'id = ?',
      whereArgs: [deviceId],
    );
  }

  static Future<int> assignDeviceToRoom(int deviceId, int roomId) async {
    final db = await database;
    return await db.update(
      'devices',
      {'room_id': roomId},
      where: 'id = ?',
      whereArgs: [deviceId],
    );
  }

  static Future<int> deleteDevice(int deviceId) async {
    final db = await database;
    return await db.delete('devices', where: 'id = ?', whereArgs: [deviceId]);
  }

  static Future<List<Map<String, dynamic>>> getAllDevices() async {
    final db = await database;
    return await db.query('devices');
  }

  static Future<List<Map<String, dynamic>>> getDevicesForRoom(
    int roomId,
  ) async {
    final db = await database;
    return await db.query('devices', where: 'room_id = ?', whereArgs: [roomId]);
  }

  static Future<void> upsertDeviceByServer({
    int? serverId,
    required String name,
    required String unitId,
    required String type,
    required int roomServerId,
    int pin = 0,
    String? iconPath,
    String? nickname,
  }) async {
    final db = await database;

    final roomCur = await db.query(
      'rooms',
      where: 'server_id=?',
      whereArgs: [roomServerId],
      limit: 1,
    );
    int localRoomId;
    if (roomCur.isEmpty) {
      localRoomId = await db.insert('rooms', {
        'server_id': roomServerId,
        'home_server_id': -1,
        'name': 'Room $roomServerId',
        'icon_path': defaultRoomIcon('Room'),
        'sort_order': 9999,
      });
    } else {
      localRoomId = roomCur.first['id'] as int;
    }

    await _upsertDeviceRecord(
      db: db,
      serverId: serverId,
      name: _bestDeviceName(nickname: nickname, name: name, unitId: unitId),
      unitId: unitId,
      type: type,
      roomServerId: roomServerId,
      localRoomId: localRoomId,
      pin: pin,
      iconPath: iconPath,
      nickname: nickname,
    );
  }

  static Future<void> _upsertDeviceRecord({
    required Database db,
    int? serverId,
    required String name,
    required String unitId,
    required String type,
    required int roomServerId,
    required int localRoomId,
    int pin = 0,
    String? iconPath,
    String? nickname,
  }) async {
    final cur = await db.query(
      'devices',
      where: 'device_unit_id=? AND room_server_id=? AND pin=?',
      whereArgs: [unitId, roomServerId, pin],
      limit: 1,
    );

    final finalName = _bestDeviceName(
      nickname: nickname,
      name: name,
      unitId: unitId,
    );

    if (cur.isEmpty) {
      await db.insert('devices', {
        'server_id': serverId,
        'name': finalName,
        'nickname': nickname,
        'device_unit_id': unitId,
        'device_type': type,
        'room_id': localRoomId,
        'room_server_id': roomServerId,
        'icon_path': _normalizeDeviceIcon(iconPath, type),
        'pin': pin,
      });
    } else {
      final existingIcon = cur.first['icon_path'] as String?;
      await db.update(
        'devices',
        {
          'server_id': serverId,
          'name': finalName,
          'nickname': nickname,
          'device_type': type,
          'room_id': localRoomId,
          'room_server_id': roomServerId,
          'icon_path': _normalizeDeviceIcon(iconPath ?? existingIcon, type),
          'pin': pin,
        },
        where: 'id=?',
        whereArgs: [cur.first['id']],
      );
    }
  }

  // =========================== FAST ACTIONS ===========================
  static Future<int> addFastAction({
    required String name,
    required String deviceUnitId,
    required String deviceType,
    required int roomId,
    required String iconPath,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(sort_order) as maxOrder FROM fast_actions',
    );
    final currentMax = result.first['maxOrder'] as int? ?? -1;
    final newOrder = currentMax + 1;

    return await db.insert('fast_actions', {
      'name': name,
      'device_unit_id': deviceUnitId,
      'device_type': deviceType,
      'room_id': roomId,
      'icon_path': iconPath,
      'sort_order': newOrder,
    });
  }

  static Future<void> updateFastActionSortOrder(List<int> idsInOrder) async {
    final db = await database;
    final batch = db.batch();
    for (int i = 0; i < idsInOrder.length; i++) {
      batch.update(
        'fast_actions',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [idsInOrder[i]],
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getAllFastActions() async {
    final db = await database;
    return await db.query('fast_actions', orderBy: 'sort_order ASC');
  }

  static Future<int> deleteFastActionsByDevice(String deviceUnitId) async {
    final db = await database;
    return await db.delete(
      'fast_actions',
      where: 'device_unit_id = ?',
      whereArgs: [deviceUnitId],
    );
  }

  // =========================== SYNC FROM OVERVIEW ===========================
  // =========================== SYNC FROM OVERVIEW ===========================
  static Future<void> syncFromOverview(List<dynamic> overview) async {
    final db = await database;

    await db.transaction((txn) async {
      for (final ho in overview) {
        final home = ho.home;

        // --------- HOMES UPSERT ---------
        final homeCur = await txn.query(
          'homes',
          where: 'server_id=?',
          whereArgs: [home.id],
          limit: 1,
        );
        if (homeCur.isEmpty) {
          await txn.insert('homes', {
            'server_id': home.id,
            'name': home.name,
            'timezone': home.timezone,
            'role': home.role,
          });
        } else {
          await txn.update(
            'homes',
            {'name': home.name, 'timezone': home.timezone, 'role': home.role},
            where: 'server_id=?',
            whereArgs: [home.id],
          );
        }

        // ==================== ROOMS UPSERT ====================
        for (int i = 0; i < ho.rooms.length; i++) {
          final r = ho.rooms[i];
          final cur = await txn.query(
            'rooms',
            where: 'server_id=?',
            whereArgs: [r.id],
            limit: 1,
          );
          final incomingIcon = (r.iconPath);
          if (cur.isEmpty) {
            await txn.insert('rooms', {
              'server_id': r.id,
              'home_server_id': home.id,
              'name': r.name,
              'icon_path': _normalizeRoomIcon(incomingIcon, r.name),
              'sort_order': i,
            });
          } else {
            final existingIcon = cur.first['icon_path'] as String?;
            await txn.update(
              'rooms',
              {
                'home_server_id': home.id,
                'name': r.name,
                'icon_path': _normalizeRoomIcon(
                  incomingIcon ?? existingIcon,
                  r.name,
                ),
                'sort_order': i,
              },
              where: 'server_id=?',
              whereArgs: [r.id],
            );
          }
        }

        // ==================== DELETE REMOVED ROOMS ====================
        // كل الـ room_ids اللي جاية من الـ overview للـ home ده
        final incomingRoomServerIds =
            ho.rooms.map<int>((r) => r.id as int).toSet();

        // كل الغرف المحلية لهذا الـ home (مع server_id != -1 عشان ما نمسّش Public)
        final existingRooms = await txn.query(
          'rooms',
          where: 'home_server_id=? AND server_id != ?',
          whereArgs: [home.id, -1],
          columns: ['id', 'server_id'],
        );

        final List<int> roomsToDeleteLocalIds = [];
        for (final row in existingRooms) {
          final srvId = row['server_id'] as int;
          if (!incomingRoomServerIds.contains(srvId)) {
            roomsToDeleteLocalIds.add(row['id'] as int);
          }
        }

        if (roomsToDeleteLocalIds.isNotEmpty) {
          // تأكد من وجود Public room
          final public = await txn.query(
            'rooms',
            where: 'server_id=?',
            whereArgs: [-1],
            limit: 1,
          );
          int publicRoomId;
          if (public.isEmpty) {
            publicRoomId = await txn.insert('rooms', {
              'server_id': -1,
              'home_server_id': -1,
              'name': 'Public',
              'icon_path': 'assets/images/public.png',
              'sort_order': 0,
            });
          } else {
            publicRoomId = public.first['id'] as int;
          }

          // placeholders لـ IN(...)
          final placeholders = List.filled(
            roomsToDeleteLocalIds.length,
            '?',
          ).join(',');

          // نقل الأجهزة بتاعة الغرف المحذوفة إلى Public
          await txn.update(
            'devices',
            {'room_id': publicRoomId, 'room_server_id': -1},
            where: 'room_id IN ($placeholders)',
            whereArgs: roomsToDeleteLocalIds,
          );

          // حذف الغرف اللي اختفت من الـ overview
          await txn.delete(
            'rooms',
            where: 'id IN ($placeholders)',
            whereArgs: roomsToDeleteLocalIds,
          );
        }

        // ==================== DEVICES UPSERT ====================
        for (final d in ho.devices) {
          final raw = d.toJson();
          final serverId = (raw['id'] as num?)?.toInt();
          if (serverId == null) {
            continue;
          }

          final unit =
              (raw['device_id'] ?? raw['device_unit_id'] ?? '').toString();
          final nickname = (raw['nickname'] as String?)?.trim();
          final name = (raw['name'] as String?)?.trim();
          final type =
              (raw['device_type'] ?? raw['type'] ?? 'device').toString();
          final roomServerId = (raw['room_id'] as num?)?.toInt();
          final pin = (raw['pin'] as num?)?.toInt() ?? 0;
          final incomingIcon = (raw['icon_path'] as String?)?.toString();

          int localRoomId = -1;
          if (roomServerId != null) {
            final roomCur = await txn.query(
              'rooms',
              where: 'server_id=?',
              whereArgs: [roomServerId],
              limit: 1,
            );
            if (roomCur.isNotEmpty) {
              localRoomId = roomCur.first['id'] as int;
            } else {
              localRoomId = await txn.insert('rooms', {
                'server_id': roomServerId,
                'home_server_id': home.id,
                'name': 'Room $roomServerId',
                'icon_path': defaultRoomIcon('Room'),
                'sort_order': 9999,
              });
            }
          } else {
            final public = await txn.query(
              'rooms',
              where: 'server_id=?',
              whereArgs: [-1],
              limit: 1,
            );
            localRoomId =
                public.isEmpty
                    ? await txn.insert('rooms', {
                      'server_id': -1,
                      'home_server_id': -1,
                      'name': 'Public',
                      'icon_path': 'assets/images/public.png',
                      'sort_order': 0,
                    })
                    : public.first['id'] as int;
          }

          final finalName = _bestDeviceName(
            nickname: nickname,
            name: name,
            unitId: unit,
          );

          final cur = await txn.query(
            'devices',
            where: 'server_id=?',
            whereArgs: [serverId],
            limit: 1,
          );

          if (cur.isEmpty) {
            await txn.insert('devices', {
              'server_id': serverId,
              'name': finalName,
              'nickname': nickname,
              'device_unit_id': unit,
              'device_type': type,
              'room_id': localRoomId,
              'room_server_id': roomServerId ?? -1,
              'icon_path': _normalizeDeviceIcon(incomingIcon, type),
              'pin': pin,
            });
          } else {
            final existingIcon = cur.first['icon_path'] as String?;
            await txn.update(
              'devices',
              {
                'server_id': serverId,
                'name': finalName,
                'nickname': nickname,
                'device_unit_id': unit,
                'device_type': type,
                'room_id': localRoomId,
                'room_server_id': roomServerId ?? -1,
                'icon_path': _normalizeDeviceIcon(
                  incomingIcon ?? existingIcon,
                  type,
                ),
                'pin': pin,
              },
              where: 'id=?',
              whereArgs: [cur.first['id']],
            );
          }
        }
      }
    });
  }
}
