enum DeviceType { ble, wifi }

class ESP32Device {
  final String id;      //BLE MAC or SSID
  final String name;    // Name
  final int rssi;       //signal strength
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
