// lib/widgets/common/status_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connection_provider.dart';

class StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConnectionProvider>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Connection icon + name
          Row(
            children: [
              Icon(
                provider.selected?.isConnected == true
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: provider.selected?.isConnected == true
                    ? Colors.green
                    : Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                provider.selected?.name ?? 'Not Connected',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          // Battery and capacitor charge
          Row(
            children: [
              Icon(Icons.battery_full, color: Colors.white),
              SizedBox(width: 4),
              Text('${provider.batteryLevel}%', style: TextStyle(color: Colors.white)),
              SizedBox(width: 16),
              Icon(Icons.flash_on, color: Colors.white),
              SizedBox(width: 4),
              Text('${provider.capacitorCharge}%', style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
