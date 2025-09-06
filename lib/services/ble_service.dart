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

      // Start scanning - NO FILTERS to catch all devices
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 6),
        androidUsesFineLocation: true,
      );

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 6));

      // Stop scanning
      await FlutterBluePlus.stopScan();

      // Convert ALL devices (not just ESP32)
      List<ESP32Device> devices = [];
      for (ScanResult result in _scanResults) {
        String deviceName = result.device.advName.isNotEmpty
            ? result.device.advName
            : result.device.remoteId.toString();

        // Accept ANY device with a name or strong signal
        if (deviceName.isNotEmpty || result.rssi > -80) {
          devices.add(ESP32Device(
            id: result.device.remoteId.toString(),
            name: deviceName.isEmpty ? 'Unknown Device' : deviceName,
            rssi: result.rssi,
            type: DeviceType.ble,
          ));
        }
      }

      print('Found ${devices.length} BLE devices total');
      return devices;

    } catch (e) {
      print('BLE Scan Error: $e');
      return [];
    } finally {
      _isScanning = false;
      _scanSubscription?.cancel();
    }
  }

  // Rest of your methods stay the same...
  Future<bool> connect(String deviceId) async {
    try {
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

      await targetDevice.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 10),
      );

      bool isConnected = await targetDevice.connectionState
          .where((state) => state == BluetoothConnectionState.connected)
          .timeout(const Duration(seconds: 10))
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
      BluetoothDevice? targetDevice;

      for (ScanResult result in _scanResults) {
        if (result.device.remoteId.toString() == deviceId) {
          targetDevice = result.device;
          break;
        }
      }

      if (targetDevice == null) return false;

      List<BluetoothService> services = await targetDevice.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write) {
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
