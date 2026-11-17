import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/favorites_local_data_source.dart';
import '../../data/datasources/favorites_shared_prefs_data_source.dart';
import '../../data/datasources/timeline_asset_data_source.dart';
import '../../data/datasources/timeline_data_source.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/timeline_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/timeline_repository.dart';
import '../../viewmodels/detail_view_model.dart';
import '../../viewmodels/timeline_view_model.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  sl.registerLazySingleton<TimelineDataSource>(
    () => TimelineAssetDataSource(),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesSharedPrefsDataSource(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<TimelineRepository>(
    () => TimelineRepositoryImpl(sl<TimelineDataSource>()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl<FavoritesLocalDataSource>()),
    dispose: (repository) => repository.dispose(),
  );

  sl.registerFactory<TimelineViewModel>(
    () => TimelineViewModel(
      timelineRepository: sl<TimelineRepository>(),
      favoritesRepository: sl<FavoritesRepository>(),
    ),
  );
  sl.registerFactoryParam<DetailViewModel, String, void>(
    (entryId, _) => DetailViewModel(
      entryId: entryId,
      timelineRepository: sl<TimelineRepository>(),
      favoritesRepository: sl<FavoritesRepository>(),
    ),
  );
}