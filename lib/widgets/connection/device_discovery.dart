import 'package:flutter/material.dart';
import '../../models/esp32_device.dart';
import 'device_list_item.dart';

class DeviceDiscovery extends StatelessWidget {
  final List<ESP32Device> devices;
  final bool isLoading;
  final Future<void> Function(ESP32Device) onConnect;

  DeviceDiscovery({
    required this.devices,
    required this.onConnect,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (devices.isEmpty) {
      return Center(child: Text('No devices found'));
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
