import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/connection/connection_type_toggle.dart';
import '../widgets/connection/device_discovery.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // Lock to portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Don't reset orientations here - let the controller screen handle it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to ESP32'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Add info screen navigation if you created it
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoScreen()));
            },
          ),
        ],
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

              // Demo Mode Button
              ElevatedButton(
                onPressed: provider.enableDemoMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Demo Mode (Test Controller)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
