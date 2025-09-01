import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/connection/connection_type_toggle.dart';
import '../widgets/connection/device_discovery.dart';

class ConnectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect to ESP32')),
      body: Consumer<ConnectionProvider>(
        builder: (_, provider, __) => Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ConnectionTypeToggle(
                useBLE: provider.useBLE,
                onToggle: provider.toggleConnectionType,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.scanForDevices,
                child: provider.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Scan for Devices'),
              ),
              SizedBox(height: 16),
              Text(provider.statusMessage),
              Expanded(
                child: DeviceDiscovery(
                  devices: provider.devices,
                  onConnect: provider.connectToDevice,
                  isLoading: provider.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
