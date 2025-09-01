import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onEmergencyStop;
  final VoidCallback onLightToggle;
  final VoidCallback onHorn;

  ActionButtons({
    required this.onEmergencyStop,
    required this.onLightToggle,
    required this.onHorn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Emergency Stop
        ElevatedButton(
          onPressed: onEmergencyStop,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text('STOP', style: TextStyle(color: Colors.white)),
        ),

        // Lights
        ElevatedButton(
          onPressed: onLightToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[800],
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text('LIGHTS', style: TextStyle(color: Colors.white)),
        ),

        // Horn
        ElevatedButton(
          onPressed: onHorn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text('HORN', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
