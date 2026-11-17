abstract interface class FavoritesRepository {
  Future<Set<String>> getFavoriteIds();

  Future<void> toggleFavorite(String id);

  Stream<Set<String>> watchFavoriteIds();

  void dispose();
}