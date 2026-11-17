import '../../domain/models/era.dart';
import '../../domain/models/timeline_entry.dart';

TimelineEntry timelineEntryFromJson(Map<String, dynamic> json) {
  try {
    return TimelineEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      era: Era.values.byName(json['era'] as String),
      year: json['year'] as int,
      summary: json['summary'] as String,
    );
  } on TypeError {
    throw FormatException('Invalid timeline entry: $json');
  } on ArgumentError {
    throw FormatException('Unknown era in timeline entry: $json');
  }
}