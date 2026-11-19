import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String _loginKey = 'isLoggedIn';
  static const String _favoriteKey = 'favoriteRecipes';

  // LOGIN
  static Future<void> setLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
  }

  // FAVOURITE
  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final favorites =
        prefs.getStringList(_favoriteKey) ?? [];

    return favorites.map((id) => int.parse(id)).toList();
  }

  static Future<void> toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> favorites =
        prefs.getStringList(_favoriteKey) ?? [];

    if (favorites.contains(id.toString())) {
      favorites.remove(id.toString());
    } else {
      favorites.add(id.toString());
    }

    await prefs.setStringList(_favoriteKey, favorites);
  }

  static Future<bool> isFavorite(int id) async {
    final favorites = await getFavorites();
    return favorites.contains(id);
  }
}