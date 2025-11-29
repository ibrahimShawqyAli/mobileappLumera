import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  final String url;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  bool _manuallyClosed = false;
  bool _isConnecting = false;
  int _retryAttempt = 0;

  SocketService(this.url) {
    _connect();
  }

  /// Getter قديم عشان ما يبوظش الكود اللي بيستخدم channel.sink.add
  WebSocketChannel get channel {
    final ch = _channel;
    if (ch == null) {
      throw StateError('WebSocket not connected yet');
    }
    return ch;
  }

  // لو حابب تبعت عن طريق دالة:
  void send(String text) {
    try {
      channel.sink.add(text);
    } catch (e) {
      debugPrint('[WS] send error: $e');
    }
  }

  void _connect() {
    if (_isConnecting || _manuallyClosed) return;

    _isConnecting = true;

    // حساب الـ backoff
    final int seconds = min(30, pow(2, _retryAttempt).toInt());
    final delay = Duration(seconds: seconds);

    if (_retryAttempt > 0) {
      debugPrint('[WS] reconnect in ${delay.inSeconds}s...');
      Future.delayed(delay, _doConnect);
    } else {
      _doConnect();
    }
  }

  void _doConnect() {
    if (_manuallyClosed) return;

    try {
      debugPrint('[WS] connecting → $url');
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _isConnecting = false;
      _retryAttempt = 0;
      debugPrint('[WS] connected ✅');

      _sub?.cancel();
      _sub = _channel!.stream.listen(
        (event) {
          // لو عندك handling للـ messages حطه هنا
          debugPrint('[WS] ← $event');
        },
        onError: (error, stack) {
          debugPrint('[WS] error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('[WS] done / closed');
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (e, st) {
      debugPrint('[WS] connect error: $e');
      debugPrintStack(stackTrace: st);
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (_manuallyClosed) return;

    _sub?.cancel();
    _sub = null;

    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;

    _retryAttempt++;
    _isConnecting = false;

    _connect(); // اعمل reconnect
  }

  Future<void> dispose() async {
    _manuallyClosed = true;
    try {
      await _sub?.cancel();
      await _channel?.sink.close();
    } catch (e) {
      debugPrint('[WS] dispose error: $e');
    } finally {
      _sub = null;
      _channel = null;
    }
  }
}
