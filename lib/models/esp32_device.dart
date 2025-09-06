enum DeviceType { ble, wifi }

class ESP32Device {
  final String id;           // BLE MAC or WiFi SSID
  final String name;         // Display name
  final int rssi;            // Signal strength (BLE) or quality (WiFi)
  final DeviceType type;
  bool isConnected;

  ESP32Device({
    required this.id,
    required this.name,
    required this.rssi,
    required this.type,
    this.isConnected = false,
  });
}
