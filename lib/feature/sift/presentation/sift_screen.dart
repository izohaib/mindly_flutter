import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindly/core/theme/colors.dart';
import 'package:mindly/feature/sift/presentation/sift_cubit/sift_cubit.dart';
import 'package:mindly/feature/sift/presentation/sift_cubit/sift_state.dart';
import 'package:mindly/feature/sift/presentation/widgets/bg_painter.dart';
import 'package:mindly/feature/sift/presentation/widgets/build_progress_dots.dart';
import 'package:mindly/feature/sift/presentation/widgets/empty_state.dart';
import 'package:mindly/feature/sift/presentation/widgets/remaining_indicator.dart';
import 'package:mindly/feature/sift/presentation/widgets/wipeable_card.dart';

class SiftScreen extends StatelessWidget {
  const SiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SiftCubit()..loadLinks(),
      child: const _SiftView(),
    );
  }
}

class _SiftView extends StatefulWidget {
  const _SiftView();

  @override
  State<_SiftView> createState() => _SiftViewState();
}

class _SiftViewState extends State<_SiftView>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Stack(
        children: [
          // 1. Background Aura
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return CustomPaint(
                painter: SiftBgPainter(animationValue: _bgController.value),
                child: Container(),
              );
            },
          ),
          Container(color: Colors.black.withValues(alpha: 0.5)),

          // 2. Main Sift View
          BlocBuilder<SiftCubit, SiftState>(
            builder: (context, state) {
              if (state is SiftLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SYNCING MIND...',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is SiftLoaded) {
                if (state.isFinished) {
                  return AnimatedEmptyState(
                    title: 'INBOX CLEAR',
                    icon: Icons.auto_awesome_rounded,
                    onRefresh: () => context.read<SiftCubit>().loadLinks(),
                  );
                }

                final visibleLinks = state.links
                    .skip(state.currentIndex)
                    .take(2)
                    .toList()
                    .reversed
                    .toList();

                return SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SIFT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: 4,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Filter the noise',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                              ],
                            ),
                            remainingIndicator(
                              state.links.length - state.currentIndex,
                            ),
                          ],
                        ),
                      ),

                      // Card Stack
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Stack(
                            alignment: Alignment.center,
                            children: visibleLinks.asMap().entries.map((entry) {
                              final index = entry.key;
                              final link = entry.value;
                              final isFront = link == state.currentLink;
                              final isBackground =
                                  index == 0 && visibleLinks.length > 1;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutBack,
                                transform: Matrix4.identity()
                                  ..translate(0.0, isBackground ? 25.0 : 0.0)
                                  ..scale(isBackground ? 0.90 : 1.0),
                                child: SwipeableCard(
                                  key: ValueKey(link.id),
                                  link: link,
                                  isFront: isFront,
                                  onSwipeLeft: () =>
                                      context.read<SiftCubit>().deleteCurrent(),
                                  onSwipeRight: () =>
                                      context.read<SiftCubit>().keepCurrent(),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Footer: Status Dots
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60, top: 20),
                        child: buildProgressDots(
                          total: state.links.length,
                          current: state.currentIndex,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is SiftEmpty) {
                return AnimatedEmptyState(
                  title: 'EMPTY INBOX',
                  icon: Icons.inbox_outlined,
                  onRefresh: () => context.read<SiftCubit>().loadLinks(),
                );
              }

              if (state is SiftError) {
                return AnimatedEmptyState(
                  title: 'ERROR LOAD',
                  icon: Icons.error_outline_rounded,
                  onRefresh: () => context.read<SiftCubit>().loadLinks(),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

