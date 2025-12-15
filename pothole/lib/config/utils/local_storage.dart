import 'package:shared_preferences/shared_preferences.dart';

class TokenHandler {
  static Future<void> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<String> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  static Future<int> getInt(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> remove(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }
}
