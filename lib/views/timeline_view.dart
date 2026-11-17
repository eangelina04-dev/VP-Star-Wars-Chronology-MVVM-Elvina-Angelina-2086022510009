import 'dart:async';

import 'package:flutter/material.dart';

import '../core/dependency_injection/service_locator.dart';
import '../core/widgets/brand_app_bar.dart';
import '../domain/models/era.dart';
import '../domain/models/timeline_entry.dart';
import '../viewmodels/timeline_state.dart';
import '../viewmodels/timeline_view_model.dart';
import 'detail_view.dart';
import 'widgets/empty_results_view.dart';
import 'widgets/era_filter_chips.dart';
import 'widgets/era_header.dart';
import 'widgets/timeline_entry_card.dart';
import 'widgets/timeline_search_field.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  static const double _maxContentWidth = 720;

  late final TimelineViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = sl<TimelineViewModel>();
    _viewModel.addListener(_showPendingMessage);
    unawaited(_viewModel.load());
  }

  @override
  void dispose() {
    _viewModel.removeListener(_showPendingMessage);
    _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showPendingMessage() {
    final message = _viewModel.consumeMessage();
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetFilters() {
    _searchController.clear();
    _viewModel.resetFilters();
  }

  void _openDetail(String entryId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailView(entryId: entryId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar.adaptive(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => switch (_viewModel.state) {
              TimelineLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              TimelineError(:final message) => EmptyResultsView(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                message: message,
                actionLabel: 'Try again',
                onAction: _viewModel.load,
              ),
              TimelineLoaded(
                :final filters,
                :final groups,
                :final favoriteIds,
              ) =>
                _buildContent(filters, _buildEntries(groups, favoriteIds)),
              TimelineEmpty(:final filters) => _buildContent(
                filters,
                _buildEmpty(filters),
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TimelineFilters filters, Widget results) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TimelineSearchField(
              controller: _searchController,
              onChanged: _viewModel.search,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: EraFilterChips(
            selectedEra: filters.era,
            favoritesOnly: filters.favoritesOnly,
            onEraSelected: _viewModel.selectEra,
            onFavoritesOnlyToggled: _viewModel.toggleFavoritesOnly,
          ),
        ),
        results,
      ],
    );
  }

  Widget _buildEntries(
    Map<Era, List<TimelineEntry>> groups,
    Set<String> favoriteIds,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 16),
      sliver: SliverList.list(
        children: [
          for (final MapEntry(:key, :value) in groups.entries) ...[
            EraHeader(era: key),
            for (final entry in value)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TimelineEntryCard(
                  entry: entry,
                  isFavorite: favoriteIds.contains(entry.id),
                  onTap: () => _openDetail(entry.id),
                  onFavoriteToggled: _viewModel.toggleFavorite,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(TimelineFilters filters) {
    final onlySaved =
        filters.favoritesOnly &&
        filters.query.trim().isEmpty &&
        filters.era == null;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: onlySaved
          ? EmptyResultsView(
              icon: Icons.star_border,
              title: 'No saved events yet',
              message: 'Tap the star on an event to save it.',
              actionLabel: 'Show all events',
              onAction: _viewModel.toggleFavoritesOnly,
            )
          : EmptyResultsView(
              actionLabel: 'Reset search & filters',
              onAction: _resetFilters,
            ),
    );
  }
}