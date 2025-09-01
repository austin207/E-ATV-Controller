import 'package:flutter/material.dart';
import '../../models/esp32_device.dart';

class DeviceListItem extends StatelessWidget {
  final ESP32Device device;
  final VoidCallback onTap;

  DeviceListItem({
    required this.device,
    required this.onTap,
  });

  Widget _signalBars(int rssi) {
    int bars = ((rssi + 100) / 25).clamp(0, 4).toInt();
    return Row(
      children: List.generate(4, (i) {
        return Icon(
          Icons.signal_cellular_4_bar,
          color: i < bars ? Colors.green : Colors.grey,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.name),
      subtitle: _signalBars(device.rssi),
      trailing: device.isConnected ? Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
