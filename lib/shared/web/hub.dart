// socket.dart

import 'package:flutter/foundation.dart';
import 'package:smart_home_iotz/shared/WS/webSocketHelper.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';

class SocketHub {
  static SocketService? _socket;

  static Future<bool> init(String url) async {
    try {
      debugPrint('SocketHub****: try → $url');
      _socket = SocketService(url); // جواه reconnect
      debugPrint('SocketHub: connected → $url');
      return true;
    } catch (e, st) {
      debugPrint('SocketHub.init ERROR: $e');
      debugPrintStack(stackTrace: st);
      _socket = null;
      return false;
    }
  }

  static bool get isReady => _socket != null;

  static SocketService? get maybe => _socket;

  static SocketService get I {
    final s = _socket;
    if (s == null) {
      throw StateError(
        'SocketHub not initialized. Call SocketHub.init() first.',
      );
    }
    return s;
  }

  static Future<void> dispose() async {
    try {
      _socket?.dispose();
    } catch (e) {
      debugPrint('SocketHub.dispose ERROR: $e');
    } finally {
      _socket = null;
    }
  }

  static Future<bool> ensureConnected({Duration? timeout}) async {
    final limit = timeout ?? Duration(seconds: 5);
    final start = DateTime.now();

    // Already has a socket instance? (SocketService reconnects by itself)
    if (_socket == null) {
      debugPrint('[WS ensure] Socket is NULL → calling init()');
      await init(myWebSocketServer);
    }

    // Try to wait until connected (channel is not null)
    while (true) {
      final s = _socket;

      // If the service exists and has a channel: OK
      if (s != null && s.channel != null) {
        debugPrint('[WS ensure] connected');
        return true;
      }

      // Timeout
      if (DateTime.now().difference(start) > limit) {
        debugPrint('[WS ensure] ❌ timeout');
        return false;
      }

      // Wait 200ms then retry
      await Future.delayed(Duration(milliseconds: 200));
    }
  }
}
