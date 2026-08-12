import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindly/feature/sift/presentation/sift_cubit/sift_cubit.dart';
import 'package:mindly/feature/sift/presentation/sift_cubit/sift_state.dart';
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

class _SiftViewState extends State<_SiftView> {
  final GlobalKey<SwipeableCardState> _frontCardKey =
  GlobalKey<SwipeableCardState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocBuilder<SiftCubit, SiftState>(
        builder: (context, state) {
          if (state is SiftLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SiftError) {
            return Center(child: Text(state.message));
          }
          if (state is SiftEmpty) {
            return const Center(child: Text('No links to sift through'));
          }
          if (state is SiftLoaded) {
            if (state.isFinished) {
              return const Center(child: Text('All done!'));
            }
            final visible = state.links
                .skip(state.currentIndex)
                .take(2)
                .toList()
                .reversed
                .toList();

            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: visible.map((link) {
                          final isFront = link == state.currentLink;
                          return SwipeableCard(
                            key: ValueKey(link.id),                           link: link,
                            isFront: isFront,
                            onSwipeLeft: () =>
                                context.read<SiftCubit>().deleteCurrent(),
                            onSwipeRight: () =>
                                context.read<SiftCubit>().keepCurrent(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _glassButton(
                          icon: Icons.close_rounded,
                          color: Colors.red,
                          onTap: () => _frontCardKey.currentState?.swipeLeft(),
                        ),
                        const SizedBox(width: 40),
                        _glassButton(
                          icon: Icons.bookmark_rounded,
                          color: Colors.green,
                          onTap: () => _frontCardKey.currentState?.swipeRight(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.15),
          shape: CircleBorder(
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}