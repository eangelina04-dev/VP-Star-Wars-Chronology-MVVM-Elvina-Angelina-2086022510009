import 'package:shared_preferences/shared_preferences.dart';

import 'favorites_local_data_source.dart';

class FavoritesSharedPrefsDataSource implements FavoritesLocalDataSource {
  FavoritesSharedPrefsDataSource(this._preferences);

  static const String _key = 'favorite_ids';

  final SharedPreferences _preferences;

  @override
  Future<Set<String>> readIds() async {
    return (_preferences.getStringList(_key) ?? const <String>[]).toSet();
  }

  @override
  Future<void> writeIds(Set<String> ids) async {
    final saved = await _preferences.setStringList(_key, ids.toList());
    if (!saved) {
      throw StateError('Favorites could not be written to storage.');
    }
  }
}