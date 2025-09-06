import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/connection/connection_type_toggle.dart';
import '../widgets/connection/device_discovery.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to ESP32'),
        backgroundColor: Colors.grey[900],
      ),
      body: Consumer<ConnectionProvider>(
        builder: (_, provider, __) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ConnectionTypeToggle(
                useBLE: provider.useBLE,
                onToggle: provider.toggleConnectionType,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.isLoading ? null : provider.scanForDevices,
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Scan for Devices'),
              ),
              const SizedBox(height: 16),
              Text(
                provider.statusMessage,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
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
