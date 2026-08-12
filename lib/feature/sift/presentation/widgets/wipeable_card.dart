import 'package:flutter/material.dart';
import 'package:mindly/core/database/app_database.dart';

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

  static const double _swipeThreshold = 120;
  static const double _cardRadius = 24;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
      _angle = (_dragOffset.dx / 300).clamp(-0.4, 0.4);
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

    final screenWidth = MediaQuery.of(context).size.width;
    _flingCard(screenWidth, isRight: false);
  }

  void swipeRight() {
    if (!widget.isFront) return;

    final screenWidth = MediaQuery.of(context).size.width;
    _flingCard(screenWidth, isRight: true);
  }

  void _flingCard(
      double screenWidth, {
        required bool isRight,
      }) {
    final endX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;

    _flyAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(endX, _dragOffset.dy),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
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
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _angle = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress =
    (_dragOffset.dx / _swipeThreshold).clamp(-1.0, 1.0);

    final isKeepSide = progress > 0;
    final strength = progress.abs();

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _angle,
          child: _buildCard(
            context,
            isKeepSide: isKeepSide,
            strength: strength,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required bool isKeepSide,
        required double strength,
      }) {
    final link = widget.link;
    final feedbackColor = isKeepSide ? Colors.green : Colors.red;
    final showFeedback = widget.isFront && strength > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: showFeedback
              ? feedbackColor
              : Colors.transparent,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Card content
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        link.imageUrl != null
                            ? Image.network(
                          link.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (context, child, progress) {
                            return progress == null
                                ? child
                                : Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child:
                                CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder:
                              (context, error, stack) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.link,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        )
                            : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.link,
                              size: 48,
                            ),
                          ),
                        ),

                        if (showFeedback)
                          Container(
                            color: feedbackColor.withOpacity(
                              0.18 * strength,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Text(
                            link.platform,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          link.title ?? link.url,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Keep/Delete indicator
            if (showFeedback)
              Positioned(
                top: 20,
                right: 20,
                child: Transform.rotate(
                  angle: isKeepSide ? 0.15 : -0.15,
                  child: _actionIndicator(
                    icon: isKeepSide
                        ? Icons.bookmark_rounded
                        : Icons.delete_rounded,
                    color: feedbackColor,
                    strength: strength,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionIndicator({
    required IconData icon,
    required Color color,
    required double strength,
  }) {
    final scale = (0.7 + (0.3 * strength)).clamp(0.7, 1.0);

    return Opacity(
      opacity: strength.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}