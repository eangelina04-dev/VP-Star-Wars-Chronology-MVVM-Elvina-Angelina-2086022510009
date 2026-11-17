import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/models/era.dart';
import '../domain/models/timeline_entry.dart';
import '../domain/repositories/favorites_repository.dart';
import '../domain/repositories/timeline_repository.dart';
import 'timeline_state.dart';

class TimelineViewModel extends ChangeNotifier {
  TimelineViewModel({
    required this._timelineRepository,
    required this._favoritesRepository,
  });

  static const String loadErrorMessage =
      'We could not load the events. Please try again.';
  static const String saveErrorMessage =
      'We could not save your change. Please try again.';

  final TimelineRepository _timelineRepository;
  final FavoritesRepository _favoritesRepository;

  TimelineState _state = const TimelineLoading();
  List<TimelineEntry> _entries = const [];
  Set<String> _favoriteIds = const {};
  String _query = '';
  Era? _selectedEra;
  bool _favoritesOnly = false;
  String? _pendingMessage;
  StreamSubscription<Set<String>>? _favoritesSubscription;
  bool _disposed = false;

  TimelineState get state => _state;

  bool get _isReady => _state is TimelineLoaded || _state is TimelineEmpty;

  TimelineFilters get _filters => TimelineFilters(
    query: _query,
    era: _selectedEra,
    favoritesOnly: _favoritesOnly,
  );

  Future<void> load() async {
    _setState(const TimelineLoading());
    try {
      final (entries, favoriteIds) = await (
        _timelineRepository.getEntries(),
        _favoritesRepository.getFavoriteIds(),
      ).wait;
      if (_disposed) return;
      _entries = entries;
      _favoriteIds = favoriteIds;
      _favoritesSubscription ??= _favoritesRepository
          .watchFavoriteIds()
          .listen(_onFavoritesChanged);
      _publish();
    } catch (_) {
      if (_disposed) return;
      _setState(const TimelineError(loadErrorMessage));
    }
  }

  void search(String query) {
    _query = query;
    if (_isReady) _publish();
  }

  void selectEra(Era? era) {
    _selectedEra = era;
    if (_isReady) _publish();
  }

  void toggleFavoritesOnly() {
    _favoritesOnly = !_favoritesOnly;
    if (_isReady) _publish();
  }

  void resetFilters() {
    _query = '';
    _selectedEra = null;
    _favoritesOnly = false;
    if (_isReady) _publish();
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _favoritesRepository.toggleFavorite(id);
    } catch (_) {
      if (_disposed) return;
      _pendingMessage = saveErrorMessage;
      notifyListeners();
    }
  }

  String? consumeMessage() {
    final message = _pendingMessage;
    _pendingMessage = null;
    return message;
  }

  void _onFavoritesChanged(Set<String> ids) {
    if (_disposed) return;
    _favoriteIds = ids;
    if (_isReady) _publish();
  }

  List<TimelineEntry> _visibleEntries() {
    final query = _query.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesEra = _selectedEra == null || entry.era == _selectedEra;
      final matchesQuery =
          query.isEmpty ||
          entry.title.toLowerCase().contains(query) ||
          entry.summary.toLowerCase().contains(query);
      final matchesFavorite =
          !_favoritesOnly || _favoriteIds.contains(entry.id);
      return matchesEra && matchesQuery && matchesFavorite;
    }).toList();
  }

  void _publish() {
    final visible = _visibleEntries();
    if (visible.isEmpty) {
      _setState(TimelineEmpty(filters: _filters));
      return;
    }
    final groups = <Era, List<TimelineEntry>>{};
    for (final era in Era.values) {
      final inEra = visible.where((entry) => entry.era == era).toList();
      if (inEra.isNotEmpty) groups[era] = inEra;
    }
    _setState(
      TimelineLoaded(
        groups: groups,
        favoriteIds: Set<String>.unmodifiable(_favoriteIds),
        filters: _filters,
      ),
    );
  }

  void _setState(TimelineState next) {
    if (_disposed || _state == next) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}