import 'package:equatable/equatable.dart';

import '../domain/models/timeline_entry.dart';

sealed class DetailState extends Equatable {
  const DetailState();
}

final class DetailLoading extends DetailState {
  const DetailLoading();

  @override
  List<Object?> get props => const [];
}

final class DetailLoaded extends DetailState {
  const DetailLoaded({required this.entry, required this.isFavorite});

  final TimelineEntry entry;
  final bool isFavorite;

  @override
  List<Object?> get props => [entry, isFavorite];
}

final class DetailNotFound extends DetailState {
  const DetailNotFound();

  @override
  List<Object?> get props => const [];
}

final class DetailError extends DetailState {
  const DetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}