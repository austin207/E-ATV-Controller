import 'package:flutter/material.dart';
import '../models/esp32_device.dart';
import '../services/ble_service.dart';
import '../services/wifi_service.dart';
import 'controller_provider.dart';

class ConnectionProvider extends ChangeNotifier {
  bool useBLE = true;
  List<ESP32Device> devices = [];
  ESP32Device? selected;
  bool isLoading = false;
  String statusMessage = '';
  bool isDemoMode = false;  // Add this line

  int batteryLevel = 85;
  int capacitorCharge = 100;

  final BLEService _bleService = BLEService();
  final WiFiService _wifiService = WiFiService();

  void toggleConnectionType(bool bleSelected) {
    useBLE = bleSelected;
    devices.clear();
    selected = null;
    notifyListeners();
  }

  // Add Demo Mode method
  void enableDemoMode() {
    isDemoMode = true;
    selected = ESP32Device(
      id: 'demo_device_123',
      name: 'Demo ESP32 RC',
      rssi: -45,
      type: DeviceType.ble,
      isConnected: true,
    );
    statusMessage = 'Demo Mode Active';
    notifyListeners();
  }

  Future<void> scanForDevices() async {
    isLoading = true;
    statusMessage = useBLE ? 'Scanning for BLE devices...' : 'Scanning for WiFi networks...';
    notifyListeners();

    try {
      List<ESP32Device> found = useBLE
          ? await _bleService.scan()
          : await _wifiService.scan();

      devices = found;
      statusMessage = found.isEmpty
          ? 'No ${useBLE ? 'BLE devices' : 'WiFi networks'} found'
          : 'Found ${devices.length} ${useBLE ? 'BLE devices' : 'WiFi networks'}';
    } catch (e) {
      statusMessage = 'Scan failed: $e';
      devices = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> connectToDevice(ESP32Device device) async {
    isLoading = true;
    statusMessage = 'Connecting to ${device.name}...';
    notifyListeners();

    bool success = useBLE
        ? await _bleService.connect(device.id)
        : await _wifiService.connect(device.id);

    if (success) {
      device.isConnected = true;
      selected = device;
      statusMessage = 'Connected to ${device.name}';
    } else {
      statusMessage = 'Failed to connect';
    }

    isLoading = false;
    notifyListeners();
  }

  void disconnect() {
    if (selected != null) {
      if (!isDemoMode && useBLE) {
        _bleService.disconnect(selected!.id);
      }
      selected!.isConnected = false;
      selected = null;
      isDemoMode = false;  // Reset demo mode
      statusMessage = 'Disconnected';
      notifyListeners();
    }
  }

  Future<void> sendCommand(String command) async {
    if (selected != null && selected!.isConnected) {
      if (!isDemoMode && useBLE) {
        await _bleService.sendCommand(selected!.id, command);
      } else {
        print('Demo Mode Command: $command');
      }
    }
  }

  void linkControllerProvider(ControllerProvider controllerProvider) {
    if (selected != null && selected!.isConnected) {
      controllerProvider.setConnectedDevice(selected!.id);
    }
  }
}
