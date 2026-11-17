import '../models/timeline_entry.dart';

abstract interface class TimelineRepository {
  Future<List<TimelineEntry>> getEntries();

  Future<TimelineEntry?> getEntryById(String id);
}