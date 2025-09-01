// lib/services/ble_service.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/esp32_device.dart';
import 'dart:async';

class BLEService {
  static List<ScanResult> _scanResults = [];
  static StreamSubscription<List<ScanResult>>? _scanSubscription;
  static bool _isScanning = false;

  Future<List<ESP32Device>> scan() async {
    if (_isScanning) return [];

    try {
      _isScanning = true;
      _scanResults.clear();

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
      });

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: 4),
        androidUsesFineLocation: true,
      );

      // Wait for scan to complete
      await Future.delayed(Duration(seconds: 4));

      // Stop scanning
      await FlutterBluePlus.stopScan();

      // Filter and convert to ESP32Device
      List<ESP32Device> devices = [];
      for (ScanResult result in _scanResults) {
        // Check if device name contains ESP32 or if it's not empty
        String deviceName = result.device.advName.isNotEmpty
            ? result.device.advName
            : result.device.remoteId.toString();

        if (deviceName.contains('ESP32') || deviceName.contains('RC')) {
          devices.add(ESP32Device(
            id: result.device.remoteId.toString(),
            name: deviceName,
            rssi: result.rssi,
            type: DeviceType.ble,
          ));
        }
      }

      return devices;

    } catch (e) {
      print('BLE Scan Error: $e');
      return [];
    } finally {
      _isScanning = false;
      _scanSubscription?.cancel();
    }
  }

  Future<bool> connect(String deviceId) async {
    try {
      // Find the device from scan results
      BluetoothDevice? targetDevice;

      for (ScanResult result in _scanResults) {
        if (result.device.remoteId.toString() == deviceId) {
          targetDevice = result.device;
          break;
        }
      }

      if (targetDevice == null) {
        print('Device not found: $deviceId');
        return false;
      }

      // Connect to device
      await targetDevice.connect(
        autoConnect: false,
        timeout: Duration(seconds: 10),
      );

      // Check connection state
      bool isConnected = await targetDevice.connectionState
          .where((state) => state == BluetoothConnectionState.connected)
          .timeout(Duration(seconds: 10))
          .first
          .then((_) => true)
          .catchError((_) => false);

      return isConnected;

    } catch (e) {
      print('BLE Connect Error: $e');
      return false;
    }
  }

  Future<void> disconnect(String deviceId) async {
    try {
      // Find connected device
      for (ScanResult result in _scanResults) {
        if (result.device.remoteId.toString() == deviceId) {
          await result.device.disconnect();
          break;
        }
      }
    } catch (e) {
      print('BLE Disconnect Error: $e');
    }
  }

  Future<bool> sendCommand(String deviceId, String command) async {
    try {
      // Find the connected device
      BluetoothDevice? targetDevice;

      for (ScanResult result in _scanResults) {
        if (result.device.remoteId.toString() == deviceId) {
          targetDevice = result.device;
          break;
        }
      }

      if (targetDevice == null) return false;

      // Discover services
      List<BluetoothService> services = await targetDevice.discoverServices();

      // Find the characteristic to write to (you'll need to know your ESP32's service/characteristic UUIDs)
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            // Write command as bytes
            await characteristic.write(command.codeUnits);
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('BLE Send Command Error: $e');
      return false;
    }
  }
}
