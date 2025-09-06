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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Up Arrow
        _buildArrowButton('up', Icons.keyboard_arrow_up),

        const SizedBox(height: 10),

        // Left and Right Arrows
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildArrowButton('left', Icons.keyboard_arrow_left),
            const SizedBox(width: 10),
            _buildArrowButton('right', Icons.keyboard_arrow_right),
          ],
        ),

        const SizedBox(height: 10),

        // Down Arrow
        _buildArrowButton('down', Icons.keyboard_arrow_down),

        // Direction Indicator
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _getDirectionText(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getDirectionText() {
    List<String> activeDirections = [];
    arrowStates.forEach((direction, isActive) {
      if (isActive) {
        activeDirections.add(direction.toUpperCase());
      }
    });

    if (activeDirections.isEmpty) {
      return 'STOP';
    } else if (activeDirections.length == 1) {
      return activeDirections.first;
    } else {
      return activeDirections.join(' + ');
    }
  }
}
