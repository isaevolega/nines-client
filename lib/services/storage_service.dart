export 'storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _playerIdKey = 'player_id';
  static const String _playerNameKey = 'player_name';
  
  Future<String?> getPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_playerIdKey);
  }
  
  Future<void> savePlayerId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerIdKey, id);
  }
  
  Future<String?> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_playerNameKey);
  }
  
  Future<void> savePlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerNameKey, name);
  }
  
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}