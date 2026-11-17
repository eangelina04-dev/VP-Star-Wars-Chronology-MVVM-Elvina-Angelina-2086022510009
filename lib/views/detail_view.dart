import 'dart:async';

import 'package:flutter/material.dart';

import '../core/dependency_injection/service_locator.dart';
import '../domain/models/timeline_entry.dart';
import '../viewmodels/detail_state.dart';
import '../viewmodels/detail_view_model.dart';
import 'widgets/empty_results_view.dart';

class DetailView extends StatefulWidget {
  const DetailView({super.key, required this.entryId});

  final String entryId;

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  late final DetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<DetailViewModel>(param1: widget.entryId);
    _viewModel.addListener(_showPendingMessage);
    unawaited(_viewModel.load());
  }

  @override
  void dispose() {
    _viewModel.removeListener(_showPendingMessage);
    _viewModel.dispose();
    super.dispose();
  }

  void _showPendingMessage() {
    final message = _viewModel.consumeMessage();
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              switch (state) {
                DetailLoaded(:final entry) => entry.era.label,
                _ => 'Event details',
              },
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (state case DetailLoaded(:final isFavorite))
                IconButton(
                  tooltip: isFavorite ? 'Remove from Saved' : 'Add to Saved',
                  isSelected: isFavorite,
                  icon: const Icon(Icons.star_border),
                  selectedIcon: const Icon(Icons.star),
                  onPressed: _viewModel.toggleFavorite,
                ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(DetailState state) {
    return switch (state) {
      DetailLoading() => const Center(child: CircularProgressIndicator()),
      DetailLoaded(:final entry) => _DetailContent(entry: entry),
      DetailNotFound() => EmptyResultsView(
        title: 'Event not found',
        message: 'This event is no longer available.',
        actionLabel: 'Go back',
        onAction: () => Navigator.of(context).pop(),
      ),
      DetailError(:final message) => EmptyResultsView(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        message: message,
        actionLabel: 'Try again',
        onAction: _viewModel.load,
      ),
    };
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.yearLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(entry.title, style: textTheme.headlineMedium),
              const SizedBox(height: 16),
              Text(entry.summary, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}