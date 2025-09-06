import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../providers/controller_provider.dart';
import '../widgets/controls/arrow_controls.dart';
import '../widgets/controls/boost_button.dart';
import '../widgets/controls/speed_slider.dart';
import '../widgets/common/status_bar.dart';
import '../widgets/common/action_buttons.dart';

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

            // Main Control Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Arrow Controls and Boost Button Row
                    Expanded(
                      flex: 4, // Give more space to controls
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Arrow Controls (Left Side)
                          Expanded(
                            flex: 3,
                            child: Consumer<ControllerProvider>(
                              builder: (context, controller, child) {
                                return Center(
                                  child: ArrowControls(
                                    arrowStates: controller.arrowStates,
                                    onDirectionChanged: controller.setArrowState,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Boost Button (Right Side)
                          Expanded(
                            flex: 2,
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

                    const SizedBox(height: 24),

                    // Speed Control Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                    const SizedBox(height: 20),

                    // Action Buttons
                    Consumer2<ControllerProvider, ConnectionProvider>(
                      builder: (context, controller, connection, child) {
                        return ActionButtons(
                          lightsOn: controller.lightsOn,
                          onEmergencyStop: controller.emergencyStop,
                          onLightToggle: controller.toggleLights,
                          onHorn: () {
                            print('Horn pressed!');
                            // Add horn command here
                            if (connection.selected != null) {
                              connection.sendCommand('HORN:1');
                            }
                          },
                          onDisconnect: connection.disconnect,
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
