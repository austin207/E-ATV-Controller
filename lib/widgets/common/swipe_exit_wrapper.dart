import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeExitWrapper extends StatefulWidget {
  final Widget child;

  const SwipeExitWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<SwipeExitWrapper> createState() => _SwipeExitWrapperState();
}

class _SwipeExitWrapperState extends State<SwipeExitWrapper> {
  int _swipeUpCount = 0;
  DateTime? _lastSwipeTime;

  void _handleSwipe(DragUpdateDetails details) {
    // Detect upward swipe (negative dy means upward)
    if (details.delta.dy < -15) { // Sensitivity: swipe up at least 15 pixels
      DateTime now = DateTime.now();

      // Reset count if more than 2 seconds have passed since last swipe
      if (_lastSwipeTime == null ||
          now.difference(_lastSwipeTime!) > const Duration(seconds: 2)) {
        _swipeUpCount = 1;
      } else {
        _swipeUpCount += 1;
      }

      _lastSwipeTime = now;

      if (_swipeUpCount >= 2) {
        // Double swipe detected - show confirmation dialog
        _showExitConfirmation();
      } else {
        // First swipe - show warning
        _showSwipeWarning();
      }
    }
  }

  void _showSwipeWarning() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.swipe_up, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Swipe up again to exit RC Controller',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Exit RC Controller',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to close the RC Controller app?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset swipe count
                _swipeUpCount = 0;
                _lastSwipeTime = null;
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop(); // Close the app
              },
              child: const Text(
                'Exit',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _handleSwipe,
      behavior: HitTestBehavior.translucent, // Detect gestures even on transparent areas
      child: widget.child,
    );
  }
}
