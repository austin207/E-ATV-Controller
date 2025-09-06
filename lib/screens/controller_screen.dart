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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Arrow Controls and Boost Button
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          // Arrow Controls (Left Side)
                          Expanded(
                            flex: 2,
                            child: Consumer<ControllerProvider>(
                              builder: (context, controller, child) {
                                return ArrowControls(
                                  arrowStates: controller.arrowStates,
                                  onDirectionChanged: controller.setArrowState,
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Boost Button (Right Side)
                          Expanded(
                            flex: 1,
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

                    const SizedBox(height: 20),

                    // Speed Control
                    Consumer<ControllerProvider>(
                      builder: (context, controller, child) {
                        return SpeedSlider(
                          speed: controller.speed,
                          effectiveSpeed: controller.effectiveSpeed,
                          onSpeedChanged: controller.setSpeed,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Consumer2<ControllerProvider, ConnectionProvider>(
                      builder: (context, controller, connection, child) {
                        return ActionButtons(
                          lightsOn: controller.lightsOn,
                          onEmergencyStop: controller.emergencyStop,
                          onLightToggle: controller.toggleLights,
                          onHorn: () => print('Horn!'), // TODO: Implement
                          onDisconnect: connection.disconnect,
                        );
                      },
                    ),
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
