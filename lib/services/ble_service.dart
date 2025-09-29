import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/esp32_device.dart';
import 'dart:async';
import 'dart:convert';

class BLEService {
  static List<ScanResult> _scanResults = [];
  static StreamSubscription<List<ScanResult>>? _scanSubscription;
  static bool _isScanning = false;

  Future<List<ESP32Device>> scan() async {
    if (_isScanning) return [];

    try {
      _isScanning = true;
      _scanResults.clear();

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 6),
        androidUsesFineLocation: true,
      );

      await Future.delayed(const Duration(seconds: 6));
      await FlutterBluePlus.stopScan();

      List<ESP32Device> devices = [];
      for (ScanResult result in _scanResults) {
        String deviceName = result.device.advName.isNotEmpty
            ? result.device.advName
            : result.device.remoteId.toString();

        if (deviceName.isNotEmpty || result.rssi > -80) {
          devices.add(
            ESP32Device(
              id: result.device.remoteId.toString(),
              name: deviceName.isEmpty ? 'Unknown Device' : deviceName,
              rssi: result.rssi,
              type: DeviceType.ble,
            ),
          );
        }
      }

      //print('Found ${devices.length} BLE devices total');
      return devices;
    } catch (e) {
      //print('BLE Scan Error: $e');
      return [];
    } finally {
      _isScanning = false;
      _scanSubscription?.cancel();
    }
  }

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
        print('❌ Device not found: $deviceId');
        return false;
      }

      print('📱 Connecting to: ${targetDevice.advName}');

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

      if (isConnected) {
        print('✅ Connected successfully to: ${targetDevice.advName}');
      }

      return isConnected;
    } catch (e) {
      print('❌ BLE Connect Error: $e');
      return false;
    }
  }

  Future<void> disconnect(String deviceId) async {
    try {
      for (ScanResult result in _scanResults) {
        if (result.device.remoteId.toString() == deviceId) {
          await result.device.disconnect();
          print('📱 Disconnected from device');
          break;
        }
      }
    } catch (e) {
      print('❌ BLE Disconnect Error: $e');
    }
  }

  // FIXED: Proper string encoding and better error handling
  Future<bool> sendCommand(String deviceId, String command) async {
    try {
      print('🚀 Attempting to send command: $command to device: $deviceId');

      BluetoothDevice? targetDevice;
      for (ScanResult result in _scanResults) {
        if (result.device.remoteId.toString() == deviceId) {
          targetDevice = result.device;
          break;
        }
      }

      if (targetDevice == null) {
        print('❌ Target device not found');
        return false;
      }

      // Check if connected
      var connectionState = await targetDevice.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        print('❌ Device not connected');
        return false;
      }

      // Discover services
      List<BluetoothService> services = await targetDevice.discoverServices();
      print('🔍 Discovered ${services.length} services');

      // Look for your exact UUIDs
      final serviceUuid = Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
      final charUuid = Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8");

      for (BluetoothService service in services) {
        if (service.uuid == serviceUuid) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid == charUuid &&
                characteristic.properties.write) {
              List<int> bytes = utf8.encode(command + "\n"); // add terminator
              await characteristic.write(bytes, withoutResponse: false);
              print('✅ Command sent successfully: $command');
              return true;
            }
          }
        }
      }

      print('❌ Target characteristic not found');
      return false;
    } catch (e) {
      print('❌ BLE Send Command Error: $e');
      return false;
    }
  }
}
