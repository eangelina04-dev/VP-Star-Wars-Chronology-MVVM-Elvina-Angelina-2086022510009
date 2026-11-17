import '../../domain/models/timeline_entry.dart';
import '../../domain/repositories/timeline_repository.dart';
import '../services/timeline_service.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  TimelineRepositoryImpl(this._service);

  final TimelineService _service;

  @override
  Future<List<TimelineEntry>> getEntries() => _service.fetchEntries();

  @override
  Future<TimelineEntry?> getEntryById(String id) async {
    final entries = await _service.fetchEntries();
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}