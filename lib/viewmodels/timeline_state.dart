import 'package:equatable/equatable.dart';

import '../domain/models/era.dart';
import '../domain/models/timeline_entry.dart';

class TimelineFilters extends Equatable {
  const TimelineFilters({
    this.query = '',
    this.era,
    this.favoritesOnly = false,
  });

  final String query;
  final Era? era;
  final bool favoritesOnly;

  bool get isActive => query.trim().isNotEmpty || era != null || favoritesOnly;

  @override
  List<Object?> get props => [query, era, favoritesOnly];
}

sealed class TimelineState extends Equatable {
  const TimelineState();
}

final class TimelineLoading extends TimelineState {
  const TimelineLoading();

  @override
  List<Object?> get props => const [];
}

final class TimelineLoaded extends TimelineState {
  const TimelineLoaded({
    required this.groups,
    required this.favoriteIds,
    required this.filters,
  });

  final Map<Era, List<TimelineEntry>> groups;
  final Set<String> favoriteIds;
  final TimelineFilters filters;

  @override
  List<Object?> get props => [groups, favoriteIds, filters];
}

final class TimelineEmpty extends TimelineState {
  const TimelineEmpty({required this.filters});

  final TimelineFilters filters;

  @override
  List<Object?> get props => [filters];
}

final class TimelineError extends TimelineState {
  const TimelineError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}