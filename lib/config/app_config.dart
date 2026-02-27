class AppConfig {
  // Для Android эмулятора
  static const String websocketUrl = 'ws://10.0.2.2:10000';
  
  // Для физического устройства (раскомментировать и подставить IP)
  // static const String websocketUrl = 'ws://192.168.1.100:10000';
  
  // Для продакшена (позже)
  // static const String websocketUrl = 'wss://devyatka-game-server.onrender.com';
  
  static const int reconnectDelayMs = 3000;
  static const int maxReconnectAttempts = 5;
}