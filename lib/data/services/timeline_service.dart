import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/era.dart';
import '../../domain/models/timeline_entry.dart';

class TimelineService {
  TimelineService({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/timeline.json',
    this.latency = const Duration(milliseconds: 800),
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  final Duration latency;

  Future<List<TimelineEntry>> fetchEntries() async {
    await Future<void>.delayed(latency);
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in decoded) _entryFromJson(item as Map<String, dynamic>),
    ];
  }
}

TimelineEntry _entryFromJson(Map<String, dynamic> json) {
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