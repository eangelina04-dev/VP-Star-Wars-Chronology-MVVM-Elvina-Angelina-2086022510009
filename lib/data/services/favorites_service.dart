import 'package:shared_preferences/shared_preferences.dart';

abstract interface class FavoritesService {
  Future<Set<String>> readIds();

  Future<void> writeIds(Set<String> ids);
}

class FavoritesSharedPrefsService implements FavoritesService {
  FavoritesSharedPrefsService(this._preferences);

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

class InMemoryFavoritesService implements FavoritesService {
  Set<String> _ids = <String>{};

  @override
  Future<Set<String>> readIds() async => Set<String>.of(_ids);

  @override
  Future<void> writeIds(Set<String> ids) async {
    _ids = Set<String>.of(ids);
  }
}