// lib/providers/connection_provider.dart
import 'package:flutter/material.dart';
import '../models/esp32_device.dart';
import '../services/ble_service.dart';
import '../services/wifi_service.dart';

class ConnectionProvider extends ChangeNotifier {
  bool useBLE = true;
  List<ESP32Device> devices = [];
  ESP32Device? selected;
  bool isLoading = false;
  String statusMessage = '';

  // Add these properties for the status bar
  int batteryLevel = 85;
  int capacitorCharge = 100;

  final _bleService = BLEService();
  final _wifiService = WiFiService();

  void toggleConnectionType(bool bleSelected) {
    useBLE = bleSelected;
    devices.clear();
    selected = null;
    notifyListeners();
  }

  Future<void> scanForDevices() async {
    isLoading = true;
    statusMessage = 'Scanning...';
    notifyListeners();

    List<ESP32Device> found = useBLE
        ? await _bleService.scan()
        : await _wifiService.scan();

    devices = found;
    statusMessage = 'Found ${devices.length} devices';
    isLoading = false;
    notifyListeners();
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
      if (useBLE) {
        _bleService.disconnect(selected!.id);
      }
      selected!.isConnected = false;
      selected = null;
      statusMessage = 'Disconnected';
      notifyListeners();
    }
  }

  Future<void> sendCommand(String command) async {
    if (selected != null && selected!.isConnected) {
      if (useBLE) {
        await _bleService.sendCommand(selected!.id, command);
      }
      // Add WiFi command sending here if needed
    }
  }
}
