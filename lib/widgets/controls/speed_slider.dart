import 'package:flutter/material.dart';

class SpeedSlider extends StatelessWidget {
  final double speed;
  final double effectiveSpeed;
  final Function(double speed) onSpeedChanged;

  const SpeedSlider({
    Key? key,
    required this.speed,
    required this.effectiveSpeed,
    required this.onSpeedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isBoosted = effectiveSpeed > speed;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Base Speed: ${speed.toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            if (isBoosted)
              Text(
                'BOOSTED: ${effectiveSpeed.toInt()}%',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: isBoosted ? Colors.orange : Colors.blue,
            inactiveTrackColor: Colors.grey[700],
            thumbColor: isBoosted ? Colors.orange : Colors.blue,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: speed,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: onSpeedChanged,
          ),
        ),
        // Visual speed indicator
        Container(
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[800],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: effectiveSpeed / 100.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: isBoosted
                      ? [Colors.orange, Colors.red]
                      : [Colors.blue, Colors.lightBlue],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
