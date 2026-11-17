import '../../domain/models/timeline_entry.dart';

abstract interface class TimelineDataSource {
  Future<List<TimelineEntry>> fetchEntries();
}