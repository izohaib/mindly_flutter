import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mindly/feature/feed/presentation/widgets/feed_app_bar.dart';
import 'package:mindly/feature/feed/presentation/widgets/filter_chips_panel.dart';
import 'package:mindly/feature/feed/presentation/widgets/link_card.dart';
import 'package:mindly/feature/feed/presentation/widgets/add_link_bottom_sheet.dart';
import '../../../core/theme/colors.dart';
import '../data/link_repository.dart';
import 'bloc/feed_cubit.dart';
import 'bloc/feed_state.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedCubit(LinkRepository.instance),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FeedCubit>().state;
    final cubit = context.read<FeedCubit>();
    final hasActiveFilter =
        state is FeedSuccess && state.selectedFilter != 'All';
    final isSearchingState =
        state is FeedSuccess && state.isSearching;

    return Column(
      children: [
        CustomAppBar(
          onSearchChanged: (query) => cubit.search(query),
          onSearchFocusChanged: (focused) =>
              cubit.isSearching(focused),
          onAddButtonTap: () {
            AddLinkBottomSheet.show(context, (url) => cubit.addLink(url));
          },
          onClearFilter: () => cubit.selectFilter('All'),
          isSearchingState: isSearchingState,
          hasActiveFilter: hasActiveFilter,
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            child: Builder(
              builder: (context) {
                if (state is FeedInitial || state is FeedLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  );
                }

                if (state is FeedError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.onSecondary),
                    ),
                  );
                }

                if (state is FeedSuccess) {
                  if (state.isSearching && state.searchQuery.isEmpty && state.selectedFilter == "All") {
                    return FilterChipsPanel(
                      options: ['All', ...state.availablePlatforms],
                      selected: state.selectedFilter,
                      onSelected: (selectedPlatform) {
                        FocusScope.of(context).unfocus();
                        context.read<FeedCubit>().selectFilter(selectedPlatform);
                      },
                    );
                  }

                  final links = state.filteredPlatformLinks;

                  if (state.selectedFilter != 'All') {
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Chip(
                              label: Text(state.selectedFilter),
                              labelStyle: const TextStyle(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              backgroundColor: AppColors.primary,
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.onPrimary,
                              ),
                              onDeleted: () =>
                                  context.read<FeedCubit>().selectFilter('All'),
                              side: const BorderSide(
                                color: AppColors.outline,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: links.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No videos for this filter',
                                    style: TextStyle(
                                      color: AppColors.onSecondary,
                                    ),
                                  ),
                                )
                              : MasonryGridView.count(
                                  padding: const EdgeInsets.all(12),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  itemCount: links.length,
                                  itemBuilder: (context, index) =>
                                      LinkFeed(link: links[index]),
                                ),
                        ),
                      ],
                    );
                  }

                  return MasonryGridView.count(
                    padding: const EdgeInsets.all(12),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: links.length,
                    itemBuilder: (context, index) =>
                        LinkFeed(link: links[index]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}
