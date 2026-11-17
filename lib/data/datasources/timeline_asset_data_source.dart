import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/timeline_entry.dart';
import '../mappers/timeline_entry_mapper.dart';
import 'timeline_data_source.dart';

class TimelineAssetDataSource implements TimelineDataSource {
  TimelineAssetDataSource({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/timeline.json',
    this.latency = const Duration(milliseconds: 800),
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  final Duration latency;

  @override
  Future<List<TimelineEntry>> fetchEntries() async {
    await Future<void>.delayed(latency);
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in decoded)
        timelineEntryFromJson(item as Map<String, dynamic>),
    ];
  }
}