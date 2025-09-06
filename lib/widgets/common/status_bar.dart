import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connection_provider.dart';
import '../../providers/controller_provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[900],
      child: Consumer2<ConnectionProvider, ControllerProvider>(
        builder: (context, connectionProvider, controllerProvider, child) {
          return Row(
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
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    connectionProvider.selected?.name ?? 'Not Connected',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),

              // Signal Strength
              Row(
                children: [
                  const Icon(Icons.signal_cellular_4_bar, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${connectionProvider.selected?.rssi ?? 0} dBm',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),

              // Capacitor Charge
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    color: controllerProvider.capacitorCharge > 20
                        ? Colors.yellow
                        : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${controllerProvider.capacitorCharge.toInt()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),

              // Battery Level
              Row(
                children: [
                  const Icon(Icons.battery_full, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${connectionProvider.batteryLevel}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
