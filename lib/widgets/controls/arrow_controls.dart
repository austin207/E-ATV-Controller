import 'package:flutter/material.dart';

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
        _hapticFeedback();
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPressed
                ? [Colors.blue[400]!, Colors.blue[600]!]
                : [Colors.grey[700]!, Colors.grey[900]!],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPressed ? [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 8,
            )
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 4,
            )
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  void _hapticFeedback() async {
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Up Arrow
        _buildArrowButton('up', Icons.keyboard_arrow_up),

        const SizedBox(height: 12),

        // Left and Right Arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildArrowButton('left', Icons.keyboard_arrow_left),
            const SizedBox(width: 12),
            _buildArrowButton('right', Icons.keyboard_arrow_right),
          ],
        ),

        const SizedBox(height: 12),

        // Down Arrow
        _buildArrowButton('down', Icons.keyboard_arrow_down),

        // Direction Indicator
        const SizedBox(height: 16),
        Text(
          _getDirectionText(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
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
