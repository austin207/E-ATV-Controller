import 'package:flutter/material.dart';
import '../../models/esp32_device.dart';

class DeviceListItem extends StatelessWidget {
  final ESP32Device device;
  final VoidCallback onTap;

  const DeviceListItem({
    Key? key,
    required this.device,
    required this.onTap,
  }) : super(key: key);

  Widget _signalBars(int rssi) {
    int bars = ((rssi + 100) / 25).clamp(0, 4).toInt();
    return Row(
      mainAxisSize: MainAxisSize.min,
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
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        leading: Icon(
          device.type == DeviceType.ble
              ? Icons.bluetooth
              : Icons.wifi,
          color: Colors.blue,
        ),
        title: Text(
          device.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Row(
          children: [
            _signalBars(device.rssi),
            const SizedBox(width: 8),
            Text(
              '${device.rssi} dBm',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        trailing: device.isConnected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }
}
