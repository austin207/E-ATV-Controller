import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArrowControls extends StatelessWidget {
  final Map<String, bool> arrowStates;
  final Function(String direction, bool isPressed) onDirectionChanged;

  const ArrowControls({
    Key? key,
    required this.arrowStates,
    required this.onDirectionChanged,
  }) : super(key: key);

  Widget _buildArrowButton(String direction, IconData icon) {
    bool isPressed = arrowStates[direction] ?? false;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        onDirectionChanged(direction, true);
      },
      onTapUp: (_) {
        onDirectionChanged(direction, false);
      },
      onTapCancel: () {
        onDirectionChanged(direction, false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPressed
                ? [Colors.blue[400]!, Colors.blue[600]!]
                : [Colors.grey[700]!, Colors.grey[900]!],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPressed ? [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.6),
              spreadRadius: 2,
              blurRadius: 8,
            )
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0), // Moved down more
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Up Arrow
          _buildArrowButton('up', Icons.keyboard_arrow_up),

          const SizedBox(height: 5),

          // Left and Right Arrows Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildArrowButton('left', Icons.keyboard_arrow_left),
              const SizedBox(width: 70),
              _buildArrowButton('right', Icons.keyboard_arrow_right),
            ],
          ),

          const SizedBox(height: 5),

          // Down Arrow
          _buildArrowButton('down', Icons.keyboard_arrow_down),

          // REMOVED: Direction indicator text and container
        ],
      ),
    );
  }

// Removed _getDirectionText() method since it's no longer needed
}
