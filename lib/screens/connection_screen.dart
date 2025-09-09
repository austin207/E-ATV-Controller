import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../providers/connection_provider.dart';
import '../widgets/connection/device_discovery.dart';
import '../widgets/connection/connection_type_toggle.dart';
import '../screens/info_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.4.1');
  final TextEditingController _portController = TextEditingController(text: '81');

  WebSocketChannel? _channel;

  bool _isConnecting = false;
  String _connectionStatus = 'Not connected';

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  void _connectWebSocket(String ip, int port) {
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IP Address cannot be empty')),
      );
      return;
    }

    final url = 'ws://$ip:$port/';

    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Connecting to $url ...';
    });

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
            (message) {
          setState(() {
            _connectionStatus = 'Received: $message';
          });
        },
        onDone: () {
          setState(() {
            _connectionStatus = 'Disconnected';
            _isConnecting = false;
          });
        },
        onError: (error) {
          setState(() {
            _connectionStatus = 'Connection error: $error';
            _isConnecting = false;
          });
        },
      );

      setState(() {
        _connectionStatus = 'Connected to $url';
        _isConnecting = false;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Failed to connect: $e';
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConnectionProvider>();
    final isWiFi = !provider.useBLE;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to ESP32'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InfoScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ConnectionTypeToggle(
                useBLE: provider.useBLE,
                onToggle: provider.toggleConnectionType,
              ),
              const SizedBox(height: 16),

              if (isWiFi) ...[
                // IP Input only for WiFi
                TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'ESP IP Address',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),

                // Port Input for WiFi
                TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // WiFi Connect Button
                ElevatedButton(
                  onPressed: _isConnecting
                      ? null
                      : () {
                    final ip = _ipController.text.trim();
                    final port = int.tryParse(_portController.text.trim()) ?? 81;
                    _connectWebSocket(ip, port);
                  },
                  child: _isConnecting
                      ? const CircularProgressIndicator()
                      : const Text('Connect via WebSocket'),
                ),
                const SizedBox(height: 12),

                Text(
                  _connectionStatus,
                  style: const TextStyle(color: Colors.white70),
                ),

                const Divider(height: 30, thickness: 1),
              ],

              ElevatedButton(
                onPressed: provider.scanForDevices,
                child: const Text('Scan for Devices'),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: provider.enableDemoMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Demo Mode (Test Controller)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                provider.statusMessage,
                style: const TextStyle(color: Colors.white70),
              ),

              Expanded(
                child: DeviceDiscovery(
                  devices: provider.devices,
                  onConnect: (device) async {
                    if (isWiFi) {
                      final ip = _ipController.text.trim();
                      final port = int.tryParse(_portController.text.trim()) ?? 81;
                      _connectWebSocket(ip, port);
                    } else {
                      provider.connectToDevice(device);
                    }
                    return;
                  },
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
