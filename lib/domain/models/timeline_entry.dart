import 'package:equatable/equatable.dart';

import 'era.dart';

String formatYear(int year) => year < 0 ? '${-year} BBY' : '$year ABY';

class TimelineEntry extends Equatable {
  const TimelineEntry({
    required this.id,
    required this.title,
    required this.era,
    required this.year,
    required this.summary,
  });

  final String id;
  final String title;
  final Era era;
  final int year;
  final String summary;

  String get yearLabel => formatYear(year);

  @override
  List<Object?> get props => [id, title, era, year, summary];
}