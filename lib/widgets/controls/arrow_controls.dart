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

    return _MultiTouchArrowButton(
      direction: direction,
      icon: icon,
      isPressed: isPressed,
      onDirectionChanged: onDirectionChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 0,
      ), // Remove extra top padding since it's centered
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Up Arrow
          _buildArrowButton('up', Icons.keyboard_arrow_up),

          const SizedBox(height: 5),

          // Left and Right Arrows Row
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center, // Ensure center alignment
            children: [
              _buildArrowButton('left', Icons.keyboard_arrow_left),
              const SizedBox(width: 70),
              _buildArrowButton('right', Icons.keyboard_arrow_right),
            ],
          ),

          const SizedBox(height: 5),

          // Down Arrow
          _buildArrowButton('down', Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

class _MultiTouchArrowButton extends StatefulWidget {
  final String direction;
  final IconData icon;
  final bool isPressed;
  final Function(String direction, bool isPressed) onDirectionChanged;

  const _MultiTouchArrowButton({
    Key? key,
    required this.direction,
    required this.icon,
    required this.isPressed,
    required this.onDirectionChanged,
  }) : super(key: key);

  @override
  State<_MultiTouchArrowButton> createState() => _MultiTouchArrowButtonState();
}

class _MultiTouchArrowButtonState extends State<_MultiTouchArrowButton> {
  // Track all active fingers pressing this button
  final Set<int> _activePointers = <int>{};

  void _onPointerDown(PointerDownEvent event) {
    _activePointers.add(event.pointer);

    // First finger pressed this button -> trigger haptic and set state
    if (_activePointers.length == 1) {
      HapticFeedback.lightImpact();
      widget.onDirectionChanged(widget.direction, true);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);

    // Last finger lifted from this button -> release state
    if (_activePointers.isEmpty) {
      widget.onDirectionChanged(widget.direction, false);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);

    // Last finger cancelled from this button -> release state
    if (_activePointers.isEmpty) {
      widget.onDirectionChanged(widget.direction, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isPressed
                ? [Colors.blue[400]!, Colors.blue[600]!]
                : [Colors.grey[700]!, Colors.grey[900]!],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: widget.isPressed
              ? [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.6),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(widget.icon, color: Colors.white, size: 28),
      ),
    );
  }
}
