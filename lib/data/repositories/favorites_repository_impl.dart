import 'dart:async';

import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._dataSource);

  final FavoritesLocalDataSource _dataSource;
  final StreamController<Set<String>> _controller =
      StreamController<Set<String>>.broadcast();

  @override
  Future<Set<String>> getFavoriteIds() => _dataSource.readIds();

  @override
  Future<void> toggleFavorite(String id) async {
    final updated = <String>{...await _dataSource.readIds()};
    if (!updated.remove(id)) updated.add(id);
    await _dataSource.writeIds(updated);
    _controller.add(Set<String>.unmodifiable(updated));
  }

  @override
  Stream<Set<String>> watchFavoriteIds() => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}