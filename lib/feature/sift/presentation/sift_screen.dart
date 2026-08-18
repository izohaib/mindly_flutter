import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindly/core/theme/colors.dart';
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

class _SiftViewState extends State<_SiftView> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (state is SiftLoaded) {
                if (state.isFinished) {
                  return _buildEmptyState(context, 'INBOX CLEAR', Icons.auto_awesome_rounded);
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
                      // Cinematic Header
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: 8,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Review your mind',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            _remainingIndicator(state.links.length - state.currentIndex),
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
                              final isBackground = index == 0 && visibleLinks.length > 1;

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
                                  onSwipeLeft: () => context.read<SiftCubit>().deleteCurrent(),
                                  onSwipeRight: () => context.read<SiftCubit>().keepCurrent(),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Footer: Status Dots
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60, top: 20),
                        child: _buildProgressDots(
                          total: state.links.length,
                          current: state.currentIndex,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (state is SiftEmpty) {
                return _buildEmptyState(context, 'EMPTY INBOX', Icons.inbox_outlined);
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _remainingIndicator(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.layers_outlined, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots({required int total, required int current}) {
    final displayCount = total > 10 ? 10 : total;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(displayCount, (index) {
        final isActive = index == (current % displayCount);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white24,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ] : null,
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, size: 64, color: Colors.white24),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: () => context.read<SiftCubit>().loadLinks(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('REFRESH INBOX'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class SiftBgPainter extends CustomPainter {
  final double animationValue;
  SiftBgPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    final phase = animationValue * 2 * math.pi;

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * (0.2 + 0.1 * math.sin(phase))),
      200,
      paint..color = AppColors.primary.withValues(alpha: 0.12),
    );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * (0.8 + 0.1 * math.cos(phase))),
      250,
      paint..color = AppColors.secondary.withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(covariant SiftBgPainter oldDelegate) => true;
}
