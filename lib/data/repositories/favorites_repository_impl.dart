import 'dart:async';

import '../../domain/repositories/favorites_repository.dart';
import '../services/favorites_service.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._service);

  final FavoritesService _service;
  final StreamController<Set<String>> _controller =
      StreamController<Set<String>>.broadcast();

  @override
  Future<Set<String>> getFavoriteIds() => _service.readIds();

  @override
  Future<void> toggleFavorite(String id) async {
    final updated = <String>{...await _service.readIds()};
    if (!updated.remove(id)) updated.add(id);
    await _service.writeIds(updated);
    _controller.add(Set<String>.unmodifiable(updated));
  }

  @override
  Stream<Set<String>> watchFavoriteIds() => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}