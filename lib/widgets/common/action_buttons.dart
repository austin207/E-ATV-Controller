import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool lightsOn;
  final VoidCallback onEmergencyStop;
  final VoidCallback onLightToggle;
  final VoidCallback onHorn;
  final VoidCallback onDisconnect;

  const ActionButtons({
    Key? key,
    required this.lightsOn,
    required this.onEmergencyStop,
    required this.onLightToggle,
    required this.onHorn,
    required this.onDisconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Emergency Stop
        _buildActionButton(
          onPressed: onEmergencyStop,
          color: Colors.red,
          icon: Icons.stop,
          label: 'STOP',
        ),

        // Lights
        _buildActionButton(
          onPressed: onLightToggle,
          color: lightsOn ? Colors.yellow[600]! : Colors.grey[600]!,
          icon: lightsOn ? Icons.lightbulb : Icons.lightbulb_outline,
          label: 'LIGHTS',
        ),

        // Horn
        _buildActionButton(
          onPressed: onHorn,
          color: Colors.blue,
          icon: Icons.campaign,
          label: 'HORN',
        ),

        // Disconnect
        _buildActionButton(
          onPressed: onDisconnect,
          color: Colors.grey[700]!,
          icon: Icons.power_settings_new,
          label: 'EXIT',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
