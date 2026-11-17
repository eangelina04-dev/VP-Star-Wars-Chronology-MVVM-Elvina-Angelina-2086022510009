import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/models/timeline_entry.dart';
import '../domain/repositories/favorites_repository.dart';
import '../domain/repositories/timeline_repository.dart';
import 'detail_state.dart';

class DetailViewModel extends ChangeNotifier {
  DetailViewModel({
    required this.entryId,
    required this._timelineRepository,
    required this._favoritesRepository,
  });

  static const String loadErrorMessage =
      'We could not load this event. Please try again.';
  static const String saveErrorMessage =
      'We could not save your change. Please try again.';

  final String entryId;
  final TimelineRepository _timelineRepository;
  final FavoritesRepository _favoritesRepository;

  DetailState _state = const DetailLoading();
  TimelineEntry? _entry;
  bool _isFavorite = false;
  String? _pendingMessage;
  StreamSubscription<Set<String>>? _favoritesSubscription;
  bool _disposed = false;

  DetailState get state => _state;

  Future<void> load() async {
    _setState(const DetailLoading());
    try {
      final (entry, favoriteIds) = await (
        _timelineRepository.getEntryById(entryId),
        _favoritesRepository.getFavoriteIds(),
      ).wait;
      if (_disposed) return;
      if (entry == null) {
        _setState(const DetailNotFound());
        return;
      }
      _entry = entry;
      _isFavorite = favoriteIds.contains(entryId);
      _favoritesSubscription ??= _favoritesRepository
          .watchFavoriteIds()
          .listen(_onFavoritesChanged);
      _publish();
    } catch (_) {
      if (_disposed) return;
      _setState(const DetailError(loadErrorMessage));
    }
  }

  Future<void> toggleFavorite() async {
    if (_state is! DetailLoaded) return;
    try {
      await _favoritesRepository.toggleFavorite(entryId);
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
    _isFavorite = ids.contains(entryId);
    _publish();
  }

  void _publish() {
    final entry = _entry;
    if (entry == null) return;
    _setState(DetailLoaded(entry: entry, isFavorite: _isFavorite));
  }

  void _setState(DetailState next) {
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