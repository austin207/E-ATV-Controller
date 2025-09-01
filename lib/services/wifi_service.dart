// lib/services/wifi_service.dart
import 'package:wifi_scan/wifi_scan.dart';
import '../models/esp32_device.dart';

class WiFiService {
  Future<List<ESP32Device>> scan() async {
    List<ESP32Device> found = [];

    // Check scan capability against enum
    var canScan = await WiFiScan.instance.canGetScannedResults();
    if (canScan != CanGetScannedResults.yes) {
      return found;
    }

    await WiFiScan.instance.startScan();
    final results = await WiFiScan.instance.getScannedResults();

    for (var net in results) {
      if (net.ssid.startsWith('ESP32_RC_')) {
        found.add(ESP32Device(
          id: net.ssid,
          name: net.ssid,
          rssi: net.level,
          type: DeviceType.wifi,
        ));
      }
    }
    return found;
  }

  Future<bool> connect(String ssid) async {
    // Simple prototype: assume success
    await Future.delayed(Duration(seconds: 2));
    return true;
  }
}
