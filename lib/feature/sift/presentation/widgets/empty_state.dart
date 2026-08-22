import 'package:flutter/material.dart';
import 'package:mindly/core/theme/colors.dart';

class AnimatedEmptyState extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onRefresh;

  const AnimatedEmptyState({
    super.key,
    required this.title,
    required this.icon,
    required this.onRefresh,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _scaleController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      upperBound: 1.0,
      lowerBound: 0.9,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    // Haptic-like feedback
    await _scaleController.reverse();
    await _scaleController.forward();

    widget.onRefresh();

    // Reset state after a delay if still mounted (in case loading is very fast)
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleController,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse = _pulseController.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Glow
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15 * (1 - pulse)),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Inner soft ring
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05 + (pulse * 0.05)),
                            width: 2,
                          ),
                        ),
                      ),
                      // Main Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1 * pulse),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRefreshing ? Icons.refresh_rounded : widget.icon,
                          size: 32,
                          color: _isRefreshing
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: Text(
                _isRefreshing ? 'REFRESHING...' : 'TAP TO REFRESH',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
