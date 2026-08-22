import 'package:flutter/material.dart';

/* 
  INTERVIEW NOTES: ANIMATIONS IN FLUTTER
  
  1. IMPLICIT ANIMATIONS (The "Easy" way):
     - Definition: Widgets that automatically animate when their properties change.
     - Examples: AnimatedContainer, AnimatedOpacity, AnimatedAlign, AnimatedPadding.
     - When to use: Simple transitions, "set-and-forget" logic.
     - Key required property: `duration`.
     
  2. EXPLICIT ANIMATIONS (The "Control" way):
     - Definition: Animations that require an `AnimationController` to start, stop, or repeat.
     - When to use: Repeating animations, coordinated animations (staggered), or when you need a "play/pause" button.
     - Key Components:
        a. AnimationController: Manages the duration and controls the flow (0.0 to 1.0).
        b. TickerProvider (vsync): Tells Flutter to update the animation frame by frame, synced with screen refresh.
        c. Tween: Maps the 0.0-1.0 value to a specific range (e.g., Color A to Color B, or 0 to 360 degrees).
        d. AnimatedBuilder: A performance-optimized widget that rebuilds ONLY the part of the UI that animates.
*/

class AnimationLearning extends StatefulWidget {
  const AnimationLearning({super.key});

  @override
  State<AnimationLearning> createState() => _AnimationLearningState();
}

// Note: `SingleTickerProviderStateMixin` is required for EXPLICIT animations (vsync).
class _AnimationLearningState extends State<AnimationLearning>
    with SingleTickerProviderStateMixin {
  // --- IMPLICIT ANIMATION STATE ---
  bool _isExpanded = false; // Just toggle this to trigger implicit animation

  // --- EXPLICIT ANIMATION STATE ---
  late AnimationController _controller; // The Brain
  late Animation<double>
  _rotationAnimation; // The Value derived from the controller

  @override
  void initState() {
    super.initState();

    // EXPLICIT SETUP:
    // 1. Initialize Controller (0.0 to 1.0)
    _controller = AnimationController(
      vsync: this, // Synchronizes with screen refresh
      duration: const Duration(seconds: 2),
    );

    // 2. Define Tween (Mapping 0.0-1.0 to 0-360 degrees)
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 3. Make it repeat (Explicit control!)
  }

  @override
  void dispose() {
    // ALWAYS dispose explicit controllers to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Implicit vs Explicit')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ==========================================
            // PART 1: IMPLICIT ANIMATION
            // ==========================================
            const Text(
              "1. Implicit Animation (Set & Forget)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "Change a property, Flutter handles the rest. No controller needed.",
              ),
            ),

            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.fastOutSlowIn,
                width: _isExpanded ? 200 : 100,
                height: 100,
                color: _isExpanded ? Colors.green : Colors.blue,
                alignment: Alignment.center,
                child: const Text(
                  "Tap Me",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const Divider(height: 50),

            // ==========================================
            // PART 2: EXPLICIT ANIMATION
            // ==========================================
            const Text(
              "2. Explicit Animation (Full Control)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "Managed by a controller. Can play, pause, or repeat.",
              ),
            ),

            // AnimatedBuilder is the cleanest way to use Explicit Animations
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.deepPurple,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Buttons to control the Explicit animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _controller.repeat(reverse: true);
                  },
                  child: const Text("Start"),
                ),

                ElevatedButton(
                  onPressed: () {
                    _controller.stop();
                  },
                  child: const Text("stop"),
                ),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
