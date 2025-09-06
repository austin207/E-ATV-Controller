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
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speed labels row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Speed: ${speed.toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            if (isBoosted)
              Text(
                'BOOSTED: ${effectiveSpeed.toInt()}%',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),

        // Simple Slider with track only
        SizedBox(
          height: 10,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: isBoosted ? Colors.orange : Colors.blue,
              inactiveTrackColor: Colors.grey[700],
              thumbColor: isBoosted ? Colors.orange : Colors.blue,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: speed,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onSpeedChanged,
            ),
          ),
        ),

        // REMOVED: Progress bar Container
      ],
    );
  }
}
