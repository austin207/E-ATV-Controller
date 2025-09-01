import 'package:flutter/material.dart';

class ArrowControls extends StatefulWidget {
  final Function(String direction, bool isPressed) onDirectionChanged;

  ArrowControls({required this.onDirectionChanged});

  @override
  _ArrowControlsState createState() => _ArrowControlsState();
}

class _ArrowControlsState extends State<ArrowControls> {
  Set<String> pressedDirections = {};

  Widget _buildArrowButton(String direction, IconData icon) {
    bool isPressed = pressedDirections.contains(direction);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressedDirections.add(direction);
        });
        widget.onDirectionChanged(direction, true);
      },
      onTapUp: (_) {
        setState(() {
          pressedDirections.remove(direction);
        });
        widget.onDirectionChanged(direction, false);
      },
      onTapCancel: () {
        setState(() {
          pressedDirections.remove(direction);
        });
        widget.onDirectionChanged(direction, false);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isPressed ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          boxShadow: isPressed ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
            )
          ] : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Up Arrow
        _buildArrowButton('up', Icons.keyboard_arrow_up),

        SizedBox(height: 8),

        // Left and Right Arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildArrowButton('left', Icons.keyboard_arrow_left),
            SizedBox(width: 8),
            _buildArrowButton('right', Icons.keyboard_arrow_right),
          ],
        ),

        SizedBox(height: 8),

        // Down Arrow
        _buildArrowButton('down', Icons.keyboard_arrow_down),
      ],
    );
  }
}
