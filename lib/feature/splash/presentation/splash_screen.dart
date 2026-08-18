import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ---- background (unchanged) ----
  late AnimationController _growController;
  late AnimationController _driftController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _growAnimation;

  static const Duration _growDuration = Duration(milliseconds: 3000);
  static const Color _bgColor = Color(0xFFF6C9D3);

  // ---- orb ----
  late AnimationController _orbDriftController;
  late AnimationController _orbSequenceController;
  late Animation<double> _orbFadeAnimation;
  late Animation<double> _orbScaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<double> _iconScaleAnimation;

  static const Duration _orbAppear = Duration(milliseconds: 350);
  static const Duration _orbHold = Duration(milliseconds: 1000);
  static const Duration _orbGrow = Duration(milliseconds: 2500);
  static const Duration _postAnimationDelay = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();

    // ---- background setup (unchanged) ----
    _growController = AnimationController(vsync: this, duration: _growDuration);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _growController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _growAnimation = Tween<double>(begin: 0.15, end: 1.0).animate(
      CurvedAnimation(parent: _growController, curve: Curves.easeInOut),
    );

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // ---- orb setup ----
    _orbDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    final totalOrbMs =
        _orbAppear.inMilliseconds +
        _orbHold.inMilliseconds +
        _orbGrow.inMilliseconds;

    _orbSequenceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalOrbMs),
    );

    _orbFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _orbSequenceController,
        curve: Interval(
          0.0,
          _orbAppear.inMilliseconds / totalOrbMs,
          curve: Curves.easeOut,
        ),
      ),
    );

    // orb starts at reference size, holds, then grows bigger
    _orbScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.78,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: _orbAppear.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.85),
        weight: _orbHold.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: _orbGrow.inMilliseconds.toDouble(),
      ),
    ]).animate(_orbSequenceController);

    final growStart =
        (_orbAppear.inMilliseconds + _orbHold.inMilliseconds) / totalOrbMs;

    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _orbSequenceController,
        curve: Interval(growStart, 1.0, curve: Curves.easeIn),
      ),
    );

    // icon now grows together with the orb instead of staying fixed
    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: _orbAppear.inMilliseconds + _orbHold.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.55,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: _orbGrow.inMilliseconds.toDouble(),
      ),
    ]).animate(_orbSequenceController);

    _growController.forward();
    _orbSequenceController.forward().whenComplete(() async {
      await Future.delayed(_postAnimationDelay);
      if (mounted) {
        context.go(RouteConstants.feed);
      }
    });
  }

  @override
  void dispose() {
    _growController.dispose();
    _driftController.dispose();
    _orbDriftController.dispose();
    _orbSequenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orbBaseDiameter = size.width * 0.85;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
          children: [
            // ---- background glow (unchanged) ----
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _growController,
                  _driftController,
                ]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: CustomPaint(
                      painter: MergedGlowPainter(
                        growValue: _growAnimation.value,
                        driftValue: _driftController.value,
                      ),
                      size: size,
                    ),
                  );
                },
              ),
            ),

            // ---- colorful moving orb, soft irregular border ----
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _orbSequenceController,
                  _orbDriftController,
                ]),
                builder: (context, child) {
                  final diameter = orbBaseDiameter * _orbScaleAnimation.value;
                  return Opacity(
                    opacity: _orbFadeAnimation.value,
                    child: SizedBox(
                      width: diameter,
                      height: diameter,
                      child: CustomPaint(
                        size: Size(diameter, diameter),
                        painter: OrbPainter(
                          driftValue: _orbDriftController.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ---- icon, fades in and grows once orb starts growing ----
            Center(
              child: AnimatedBuilder(
                animation: _orbSequenceController,
                builder: (context, child) {
                  final iconSize =
                      orbBaseDiameter * 0.42 * _iconScaleAnimation.value;
                  return Opacity(
                    opacity: _iconFadeAnimation.value,
                    child: SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/icon/splash_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const IgnorePointer(child: _ParticlesOverlay()),
          ],
        ),
      ),
    );
  }
}

/// Colorful orb with a soft, uneven (not perfectly round) glowing edge,
/// same idea as your reference: lavender top, purple lower-left, orange
/// right, pink base, all blended and slowly drifting.
class OrbPainter extends CustomPainter {
  final double driftValue;

  OrbPainter({required this.driftValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // outer soft glow, blends with background behind it
    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFB98BFF).withValues(alpha: 0.35),
          const Color(0xFFB98BFF).withValues(alpha: 0.0),
        ],
        stops: const [0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 1.15));
    canvas.drawCircle(center, r * 1.15, outerGlowPaint);

    // base fill: slightly lower opacity so background color underneath
    // still shows through and mixes with these tones, not a flat solid
    final basePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE9C9FF).withValues(alpha: 0.80),
          const Color(0xFFFFC2A8).withValues(alpha: 0.75),
          const Color(0xFFFFC2A8).withValues(alpha: 0.40),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, basePaint);

    // uneven glow border
    final borderColors = [
      const Color(0xFF8F6FFF),
      const Color(0xFF6F9CFF),
      const Color(0xFFFFA35C),
    ];
    for (var i = 0; i < borderColors.length; i++) {
      final angle =
          driftValue * 2 * math.pi + i * (2 * math.pi / borderColors.length);
      final pos = Offset(
        center.dx + math.cos(angle) * r * 0.55,
        center.dy + math.sin(angle) * r * 0.55,
      );
      final ringPaint = Paint()
        ..color = borderColors[i].withValues(alpha: 0.60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.45
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.30);
      canvas.drawCircle(pos, r * 0.70, ringPaint);
    }

    // moving inner color blobs, more variety, overlapping alphas so
    // the hues actively mix into new in-between colors
    final blobs = <_OrbBlob>[
      _OrbBlob(
        color: const Color(0xFFC9B8FF),
        offset: const Offset(-0.05, -0.32),
        alpha: 0.85,
      ),
      _OrbBlob(
        color: const Color(0xFF7A5FE0),
        offset: const Offset(-0.32, 0.12),
        alpha: 0.70,
      ),
      _OrbBlob(
        color: const Color(0xFFFFC9A8),
        offset: const Offset(-0.18, 0.24),
        alpha: 0.85,
      ),
      _OrbBlob(
        color: const Color(0xFFFF7C97),
        offset: const Offset(0.08, 0.30),
        alpha: 0.80,
      ),
      _OrbBlob(
        color: const Color(0xFFFF9E42),
        offset: const Offset(0.32, 0.06),
        alpha: 0.85,
      ),
      _OrbBlob(
        color: const Color(0xFFFFE1A8),
        offset: const Offset(0.18, -0.22),
        alpha: 0.60,
      ),
      _OrbBlob(
        color: const Color(0xFF6FC9FF),
        offset: const Offset(-0.34, -0.22),
        alpha: 0.55,
      ),
      _OrbBlob(
        color: const Color(0xFFFF6FA8),
        offset: const Offset(0.30, -0.10),
        alpha: 0.55,
      ),
    ];

    for (var i = 0; i < blobs.length; i++) {
      final blob = blobs[i];
      final angle = driftValue * 2 * math.pi + i * 0.9;
      final driftAmount = r * 0.09;

      final pos = Offset(
        center.dx + blob.offset.dx * size.width + math.cos(angle) * driftAmount,
        center.dy +
            blob.offset.dy * size.height +
            math.sin(angle) * driftAmount,
      );

      final paint = Paint()
        ..color = blob.color.withValues(alpha: blob.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.36);

      canvas.drawCircle(pos, r * 0.50, paint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) =>
      oldDelegate.driftValue != driftValue;
}

class _OrbBlob {
  final Color color;
  final Offset offset;
  final double alpha;

  _OrbBlob({required this.color, required this.offset, required this.alpha});
}

/// Background glow (unchanged).
class MergedGlowPainter extends CustomPainter {
  final double growValue;
  final double driftValue;

  MergedGlowPainter({required this.growValue, required this.driftValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final baseRadius = size.width * 0.62 * growValue;

    final blobs = <_Blob>[
      _Blob(
        color: const Color(0xFF6F9CFF),
        offset: const Offset(-0.10, -0.30),
        radiusFactor: 0.70,
        blur: 110,
        alpha: 0.55,
      ),
      _Blob(
        color: const Color(0xFFB98BFF),
        offset: const Offset(-0.32, 0.05),
        radiusFactor: 0.60,
        blur: 100,
        alpha: 0.45,
      ),
      _Blob(
        color: const Color(0xFFFF9E57),
        offset: const Offset(0.30, 0.28),
        radiusFactor: 0.65,
        blur: 110,
        alpha: 0.55,
      ),
      _Blob(
        color: const Color(0xFFFF9EC4),
        offset: const Offset(0.05, 0.32),
        radiusFactor: 0.75,
        blur: 130,
        alpha: 0.40,
      ),
    ];

    for (var i = 0; i < blobs.length; i++) {
      final blob = blobs[i];
      final angle = driftValue * 2 * math.pi + i * 1.4;
      final driftAmount = size.width * 0.03;

      final pos = Offset(
        center.dx + blob.offset.dx * size.width + math.cos(angle) * driftAmount,
        center.dy +
            blob.offset.dy * size.height +
            math.sin(angle * 1.3) * driftAmount,
      );

      final paint = Paint()
        ..color = blob.color.withValues(alpha: blob.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blob.blur);

      canvas.drawCircle(pos, baseRadius * blob.radiusFactor, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MergedGlowPainter oldDelegate) =>
      oldDelegate.growValue != growValue ||
      oldDelegate.driftValue != driftValue;
}

class _Blob {
  final Color color;
  final Offset offset;
  final double radiusFactor;
  final double blur;
  final double alpha;

  _Blob({
    required this.color,
    required this.offset,
    required this.radiusFactor,
    required this.blur,
    required this.alpha,
  });
}

class _ParticlesOverlay extends StatefulWidget {
  const _ParticlesOverlay();

  @override
  State<_ParticlesOverlay> createState() => _ParticlesOverlayState();
}

class _ParticlesOverlayState extends State<_ParticlesOverlay>
    with SingleTickerProviderStateMixin {
  late List<math.Point<double>> points;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    points = List.generate(
      20,
      (_) => math.Point(math.Random().nextDouble(), math.Random().nextDouble()),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(points, _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<math.Point<double>> points;
  final double progress;

  _ParticlesPainter(this.points, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.2);

    for (var point in points) {
      final y = (point.y - progress) % 1.0;
      canvas.drawCircle(
        Offset(point.x * size.width, y * size.height),
        1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
