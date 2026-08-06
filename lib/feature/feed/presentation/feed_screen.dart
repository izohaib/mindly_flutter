import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mindly/core/database/app_database.dart';
import 'package:mindly/feature/feed/presentation/widgets/feed_app_bar.dart';
import 'package:mindly/feature/feed/presentation/widgets/filter_chips_panel.dart';
import 'package:mindly/feature/feed/presentation/widgets/link_card.dart';
import '../../../core/theme/colors.dart';
import 'bloc/feed_bloc.dart';
import 'bloc/feed_state.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedCubit(appDatabase: AppDatabase.instance),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          onSearchChanged: (query) {
            context.read<FeedCubit>().search(query);
          },
          onSearchFocusChanged: (focused) {
            print("focused: ${focused}");
            context.read<FeedCubit>().setSearching(focused);
          },

          onAddButtonTap: () {
            // TODO: navigate to create-link/note screen
          },
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            child: BlocBuilder<FeedCubit, FeedState>(
              builder: (context, state) {
                if (state is FeedInitial || state is FeedLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                  if (state.isSearching) {
                    return FilterChipsPanel(
                      options: const [
                        'All',
                        'Recently Added',
                        'Favorites',
                        'Unsorted',
                      ],
                      selected: state.selectedFilter,
                      onSelected: (value) {
                        context.read<FeedCubit>().selectFilter(value);
                      },
                    );
                  }

                  final links = state.filteredLinks;

                  if (links.isEmpty) {
                    return Center(
                      child: Text(
                        state.searchQuery.isEmpty
                            ? 'No links saved yet'
                            : 'No results for "${state.searchQuery}"',
                        style: const TextStyle(color: AppColors.onSecondary),
                      ),
                    );
                  }

                  return MasonryGridView.count(
                    padding: const EdgeInsets.all(12),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      return LinkFeed(link: links[index]);
                    },
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
