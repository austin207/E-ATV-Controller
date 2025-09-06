import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/esp32_device.dart';

class WiFiService {
  Future<List<ESP32Device>> scan() async {
    List<ESP32Device> found = [];

    try {
      // Request multiple permissions that WiFi scanning needs
      Map<Permission, PermissionStatus> permissions = await [
        Permission.location,
        Permission.locationWhenInUse,
        Permission.nearbyWifiDevices, // Android 13+
      ].request();

      // Check if location permission granted
      if (permissions[Permission.location] != PermissionStatus.granted &&
          permissions[Permission.locationWhenInUse] != PermissionStatus.granted) {
        print('Location permission required for WiFi scanning');
        return found;
      }

      // Check WiFi scanning capability
      final canStart = await WiFiScan.instance.canStartScan();
      print('Can start WiFi scan: $canStart');

      if (canStart != CanStartScan.yes) {
        print('Cannot start WiFi scan: $canStart');
        return found;
      }

      // Start scan
      final startResult = await WiFiScan.instance.startScan();
      print('WiFi scan result: $startResult');

      // Wait for scan completion
      await Future.delayed(const Duration(seconds: 5));

      // Check if we can get results
      final canGetResults = await WiFiScan.instance.canGetScannedResults();
      print('Can get results: $canGetResults');

      if (canGetResults != CanGetScannedResults.yes) {
        print('Cannot get scan results: $canGetResults');
        return found;
      }

      // Get results
      final results = await WiFiScan.instance.getScannedResults();
      print('WiFi networks found: ${results.length}');

      // Add ALL networks (not just ESP32) for testing
      for (var network in results) {
        if (network.ssid.isNotEmpty && network.ssid.length > 1) {
          found.add(ESP32Device(
            id: network.ssid,
            name: network.ssid,
            rssi: network.level,
            type: DeviceType.wifi,
          ));
        }
      }

      return found;

    } catch (e) {
      print('WiFi scan exception: $e');
      return found;
    }
  }

  Future<bool> connect(String ssid) async {
    print('Demo connecting to: $ssid');
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
