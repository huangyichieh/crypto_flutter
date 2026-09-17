import 'package:shared_preferences/shared_preferences.dart';

class FavoriteListService {
  const FavoriteListService();

  static const instance = FavoriteListService();
  static const _storageKey = 'favorite_markets';

  Future<void> writeFavoriteList({
    required String userId,
    required List<String> favorites,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_storageKey, favorites);
  }

  Future<List<String>> getFavoriteList({required String userId}) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_storageKey) ?? <String>[];
  }
}
