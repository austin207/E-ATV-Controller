import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../providers/controller_provider.dart';
import '../widgets/controls/arrow_controls.dart';
import '../widgets/controls/boost_button.dart';
import '../widgets/controls/speed_slider.dart';
import '../widgets/common/status_bar.dart';

class ControllerScreen extends StatelessWidget {
  const ControllerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            const StatusBar(),

            // Speed Control (compact at top)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<ControllerProvider>(
                builder: (context, controller, child) {
                  return SpeedSlider(
                    speed: controller.speed,
                    effectiveSpeed: controller.effectiveSpeed,
                    onSpeedChanged: controller.setSpeed,
                  );
                },
              ),
            ),

            // Main Control Area
            Expanded(
              child: Stack(
                children: [
                  // Action Buttons Column - Left Side
                  // Action Buttons Grid - Left Side (2x2 format)
                  Positioned(
                    left: 20,
                    bottom: 100,
                    child: Consumer2<ControllerProvider, ConnectionProvider>(
                      builder: (context, controller, connection, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top row: STOP and LIGHTS
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionButton(
                                  label: 'STOP',
                                  icon: Icons.stop,
                                  color: Colors.red,
                                  onPressed: controller.emergencyStop,
                                ),
                                const SizedBox(width: 12),
                                _buildActionButton(
                                  label: 'LIGHTS',
                                  icon: controller.lightsOn
                                      ? Icons.lightbulb
                                      : Icons.lightbulb_outline,
                                  color: controller.lightsOn
                                      ? Colors.yellow[700]!
                                      : Colors.grey[700]!,
                                  onPressed: controller.toggleLights,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Bottom row: HORN and EXIT
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionButton(
                                  label: 'HORN',
                                  icon: Icons.campaign,
                                  color: Colors.blue,
                                  onPressed: () {
                                    print('Horn pressed!');
                                    if (connection.selected != null) {
                                      connection.sendCommand('HORN:1');
                                    }
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildActionButton(
                                  label: 'EXIT',
                                  icon: Icons.power_settings_new,
                                  color: Colors.grey[700]!,
                                  onPressed: connection.disconnect,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),


                  // Arrow Controls - Moved down to avoid slider overlap
                  Positioned(
                    bottom: 20, // Decreased from 40 to 20 (moves DOWN)
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 220,
                        child: Consumer<ControllerProvider>(
                          builder: (context, controller, child) {
                            return ArrowControls(
                              arrowStates: controller.arrowStates,
                              onDirectionChanged: controller.setArrowState,
                            );
                          },
                        ),
                      ),
                    ),
                  ),


                  // Boost Button - Right Side
                  Positioned(
                    right: 30,
                    bottom: 100,
                    child: Consumer<ControllerProvider>(
                      builder: (context, controller, child) {
                        return BoostButton(
                          capacitorCharge: controller.capacitorCharge,
                          canBoost: controller.canBoost,
                          isActive: controller.boostActive,
                          onBoostChanged: controller.setBoost,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for compact action buttons
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(65, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
