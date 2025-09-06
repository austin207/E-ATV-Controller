import 'package:flutter/material.dart';
import '../../models/esp32_device.dart';
import 'device_list_item.dart';

class DeviceDiscovery extends StatelessWidget {
  final List<ESP32Device> devices;
  final bool isLoading;
  final Future<void> Function(ESP32Device) onConnect;

  const DeviceDiscovery({
    Key? key,
    required this.devices,
    required this.onConnect,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (devices.isEmpty) {
      return const Center(
        child: Text(
          'No devices found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, i) {
        return DeviceListItem(
          device: devices[i],
          onTap: () => onConnect(devices[i]),
        );
      },
    );
  }
}
