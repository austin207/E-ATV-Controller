import 'package:flutter/material.dart';

class SpeedSlider extends StatelessWidget {
  final double speed;
  final Function(double speed) onSpeedChanged;

  SpeedSlider({
    required this.speed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Speed: ${speed.toInt()}%',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Slider(
          value: speed,
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
          onChanged: onSpeedChanged,
        ),
      ],
    );
  }
}
