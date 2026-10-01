import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static const String _recentKey = 'recent_searches';
  static const String _favoriteKey = 'favorite_product_names';
  static SharedPreferences? _prefs;
  //  ensure only one instance of SharedPreferences is used
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  //* Recent Searches Management
  static Future<void> saveRecentSearches(List<String> updated) async {
    await _setStringList(_recentKey, updated);
  }

  static Future<List<String>?> loadRecentSearches() async {
    return await _getStringList(_recentKey);
  }

  static Future<void> clearRecentSearches() async {
    await _remove(_recentKey);
  }

  //* favorites Management
  static Future<void> saveFavorites(List<String> updated) async {
    await _setStringList(_favoriteKey, updated);
  }

  static Future<List<String>?> loadFavorites() async {
    return await _getStringList(_favoriteKey);
  }

  static Future<void> clearFavorites() async {
    await _remove(_favoriteKey);
  }

  // Private helpers — add all future keys through these
  static Future<void> _setStringList(String key, List<String> value) async {
    final prefs = await _instance;
    await prefs.setStringList(key, value);
  }

  static Future<List<String>?> _getStringList(String key) async {
    final prefs = await _instance;
    return prefs.getStringList(key);
  }

  static Future<void> _remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }
}
