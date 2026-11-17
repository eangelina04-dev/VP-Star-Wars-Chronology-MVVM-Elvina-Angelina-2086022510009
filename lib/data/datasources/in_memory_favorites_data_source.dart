import 'favorites_local_data_source.dart';

class InMemoryFavoritesDataSource implements FavoritesLocalDataSource {
  Set<String> _ids = <String>{};

  @override
  Future<Set<String>> readIds() async => Set<String>.of(_ids);

  @override
  Future<void> writeIds(Set<String> ids) async {
    _ids = Set<String>.of(ids);
  }
}