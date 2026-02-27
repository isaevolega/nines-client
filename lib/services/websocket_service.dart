import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../models/messages.dart';

enum WSStatus { disconnected, connecting, connected, error }

class WebSocketService {
  WebSocketChannel? _channel;
  WSStatus _status = WSStatus.disconnected;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  
  WSStatus get status => _status;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  
  void connect() {
    if (_status == WSStatus.connected) return;
    
    _setStatus(WSStatus.connecting);
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConfig.websocketUrl));
      
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );
      
      _setStatus(WSStatus.connected);
      _reconnectAttempts = 0;
    } catch (e) {
      _handleError(e);
    }
  }
  
  void _handleMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      _messageController.add(json);
    } catch (e) {
      print('Ошибка парсинга сообщения: $e');
    }
  }
  
  void _handleError(dynamic error) {
    print('WebSocket ошибка: $error');
    _setStatus(WSStatus.error);
    _scheduleReconnect();
  }
  
  void _handleDisconnect() {
    print('WebSocket отключён');
    _setStatus(WSStatus.disconnected);
    _scheduleReconnect();
  }
  
  void _scheduleReconnect() {
    if (_reconnectAttempts >= AppConfig.maxReconnectAttempts) {
      print('Превышено количество попыток переподключения');
      return;
    }
    
    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(milliseconds: AppConfig.reconnectDelayMs * _reconnectAttempts),
      () => connect(),
    );
  }
  
  void _setStatus(WSStatus status) {
    _status = status;
    _messageController.add({'type': 'connection_status', 'status': status.name});
  }
  
  void send(WSMessage message) {
    if (_status == WSStatus.connected && _channel != null) {
      _channel!.sink.add(jsonEncode(message.toJson()));
    } else {
      print('Нельзя отправить сообщение: статус = $_status');
    }
  }
  
  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _setStatus(WSStatus.disconnected);
  }
  
  void dispose() {
    disconnect();
    _messageController.close();
  }
}