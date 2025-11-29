import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  final WebSocketChannel channel;

  SocketService(String serverUrl)
    : channel = WebSocketChannel.connect(Uri.parse(serverUrl));

  void sendControlCommand(String espId, int pin, String state) {
    final message = {
      "type": "control",
      "espId": 171,
      "pin": pin,
      "state": state,
    };
    channel.sink.add(message.toString().replaceAll("'", '"')); // JSON string
  }

  void dispose() {
    channel.sink.close();
  }
}
