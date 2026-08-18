import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mindly/core/database/app_database.dart';
import 'package:mindly/core/theme/colors.dart';

class SwipeableCard extends StatefulWidget {
  final Link link;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool isFront;

  const SwipeableCard({
    super.key,
    required this.link,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.isFront = true,
  });

  @override
  State<SwipeableCard> createState() => SwipeableCardState();
}

class SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<Offset>? _flyAnimation;

  Offset _dragOffset = Offset.zero;
  double _angle = 0;

  static const double _swipeThreshold = 140;
  static const double _cardRadius = 32;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
      if (_flyAnimation != null) {
        setState(() {
          _dragOffset = _flyAnimation!.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isFront) return;

    setState(() {
      _dragOffset += details.delta;
      _angle = (_dragOffset.dx / 400).clamp(-0.25, 0.25);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isFront) return;

    final screenWidth = MediaQuery.of(context).size.width;

    if (_dragOffset.dx > _swipeThreshold) {
      _flingCard(screenWidth, isRight: true);
    } else if (_dragOffset.dx < -_swipeThreshold) {
      _flingCard(screenWidth, isRight: false);
    } else {
      _resetCard();
    }
  }

  void swipeLeft() {
    if (!widget.isFront) return;
    _flingCard(MediaQuery.of(context).size.width, isRight: false);
  }

  void swipeRight() {
    if (!widget.isFront) return;
    _flingCard(MediaQuery.of(context).size.width, isRight: true);
  }

  void _flingCard(double screenWidth, {required bool isRight}) {
    final endX = isRight ? screenWidth * 2.0 : -screenWidth * 1.8;

    _flyAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(endX, _dragOffset.dy + 40),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward(from: 0).then((_) {
      isRight ? widget.onSwipeRight() : widget.onSwipeLeft();
    });
  }

  void _resetCard() {
    _flyAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward(from: 0).then((_) {
      if (mounted) setState(() => _angle = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragOffset.dx / _swipeThreshold).clamp(-1.0, 1.0);
    final isKeepSide = progress > 0;
    final strength = progress.abs();

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _angle,
          child: _buildCard(context, isKeepSide: isKeepSide, strength: strength),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required bool isKeepSide, required double strength}) {
    final link = widget.link;
    final actionColor = isKeepSide ? AppColors.secondary : AppColors.error;
    
    // Smooth interpolation for the border glow
    final glowColor = actionColor.withValues(alpha: 0.6 * strength);
    final overlayColor = actionColor.withValues(alpha: 0.25 * strength);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          // Dynamic Glowing Border
          BoxShadow(
            color: glowColor,
            blurRadius: 20 * strength,
            spreadRadius: 2 * strength,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Long Background Image (Full height)
            _buildImage(link),

            // 2. Dark/Glow Overlay
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      overlayColor,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Information Section (Minimalist & Bottom Aligned)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Platform Badge (Ultra-clean)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        link.platform.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title (Bold & Cinematic)
                    Text(
                      link.title ?? 'UNTITLED LINK',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Visual Hint of direction
                    Row(
                      children: [
                        Icon(
                          isKeepSide ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                          color: actionColor.withValues(alpha: 0.8 * strength + 0.2),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isKeepSide ? 'KEEP THIS' : 'DELETE THIS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: actionColor.withValues(alpha: 0.8 * strength + 0.2),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Link link) {
    if (link.imageUrl != null && link.imageUrl!.isNotEmpty) {
      return Image.network(
        link.imageUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: AppColors.surfaceVariant);
        },
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white.withValues(alpha: 0.1), size: 80),
      ),
    );
  }
}
