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

            // Combined Speed Control + Action Buttons
            // Combined Speed Control + Action Buttons (Optimized)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speed Slider
                  Consumer<ControllerProvider>(
                    builder: (context, controller, child) {
                      return SpeedSlider(
                        speed: controller.speed,
                        effectiveSpeed: controller.effectiveSpeed,
                        onSpeedChanged: controller.setSpeed,
                      );
                    },
                  ),

                  // Action Buttons Row (No SizedBox - direct placement)
                  Consumer2<ControllerProvider, ConnectionProvider>(
                    builder: (context, controller, connection, child) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4), // Minimal spacing
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // STOP Button
                            _buildCompactButton(
                              onPressed: controller.emergencyStop,
                              color: Colors.red,
                              label: 'STOP',
                              icon: Icons.stop,
                            ),

                            // LIGHTS Button
                            _buildCompactButton(
                              onPressed: controller.toggleLights,
                              color: controller.lightsOn
                                  ? Colors.yellow[700]!
                                  : Colors.grey[700]!,
                              label: 'LIGHTS',
                              icon: controller.lightsOn
                                  ? Icons.lightbulb
                                  : Icons.lightbulb_outline,
                            ),

                            // HORN Button
                            _buildCompactButton(
                              onPressed: () {
                                print('Horn pressed!');
                                if (connection.selected != null) {
                                  connection.sendCommand('HORN:1');
                                }
                              },
                              color: Colors.blue,
                              label: 'HORN',
                              icon: Icons.campaign,
                            ),

                            // EXIT Button
                            _buildCompactButton(
                              onPressed: connection.disconnect,
                              color: Colors.grey[700]!,
                              label: 'EXIT',
                              icon: Icons.power_settings_new,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),


            // Main Control Area - Arrows at bottom left, Boost on right
            Expanded(
              child: Stack(
                children: [
                  // Arrow Controls - Positioned at bottom left
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Consumer<ControllerProvider>(
                      builder: (context, controller, child) {
                        return ArrowControls(
                          arrowStates: controller.arrowStates,
                          onDirectionChanged: controller.setArrowState,
                        );
                      },
                    ),
                  ),

                  // Boost Button - Positioned at center right
                  Positioned(
                    right: 30,
                    top: 50,
                    bottom: 50,
                    child: Consumer<ControllerProvider>(
                      builder: (context, controller, child) {
                        return Center(
                          child: BoostButton(
                            capacitorCharge: controller.capacitorCharge,
                            canBoost: controller.canBoost,
                            isActive: controller.boostActive,
                            onBoostChanged: controller.setBoost,
                          ),
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

  // Helper method for compact buttons
  Widget _buildCompactButton({
    required VoidCallback onPressed,
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: const Size(70, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 2),
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
