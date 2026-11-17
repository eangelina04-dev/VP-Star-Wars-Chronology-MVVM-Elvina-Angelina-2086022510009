import '../../domain/models/timeline_entry.dart';
import '../../domain/repositories/timeline_repository.dart';
import '../datasources/timeline_data_source.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  TimelineRepositoryImpl(this._dataSource);

  final TimelineDataSource _dataSource;

  @override
  Future<List<TimelineEntry>> getEntries() => _dataSource.fetchEntries();

  @override
  Future<TimelineEntry?> getEntryById(String id) async {
    final entries = await _dataSource.fetchEntries();
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}