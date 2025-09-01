import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/controls/arrow_controls.dart';
import '../widgets/controls/boost_button.dart';
import '../widgets/controls/speed_slider.dart';
import '../widgets/common/status_bar.dart';
import '../widgets/common/action_buttons.dart';

class ControllerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            return Column(
              children: [
                // Status Bar
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Connection Status
                      Row(
                        children: [
                          Icon(
                            connectionProvider.selected?.isConnected == true
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: connectionProvider.selected?.isConnected == true
                                ? Colors.green
                                : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            connectionProvider.selected?.name ?? 'Not Connected',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      // Disconnect Button
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          connectionProvider.disconnect();
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Main Control Area
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              // Arrow Controls (Left Side)
                              Expanded(
                                flex: 2,
                                child: ArrowControls(
                                  onDirectionChanged: (direction, isPressed) {
                                    // Handle arrow button press/release
                                    print('$direction: $isPressed');
                                    // TODO: Send command to ESP32
                                  },
                                ),
                              ),

                              SizedBox(width: 20),

                              // Boost Button (Right Side)
                              Expanded(
                                flex: 1,
                                child: BoostButton(
                                  onBoostChanged: (isBoosting) {
                                    // Handle boost activation
                                    print('Boost: $isBoosting');
                                    // TODO: Send boost command to ESP32
                                  },
                                  capacitorCharge: 100.0, // TODO: Get from provider
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Speed Control
                        SpeedSlider(
                          speed: 50, // TODO: Get from provider
                          onSpeedChanged: (speed) {
                            print('Speed: $speed');
                            // TODO: Update speed in provider
                          },
                        ),

                        SizedBox(height: 20),

                        // Action Buttons
                        ActionButtons(
                          onEmergencyStop: () {
                            print('Emergency Stop!');
                            // TODO: Send emergency stop command
                          },
                          onLightToggle: () {
                            print('Toggle Lights');
                            // TODO: Send light toggle command
                          },
                          onHorn: () {
                            print('Horn!');
                            // TODO: Send horn command
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
