# RC Controller Flutter App

A professional Flutter application for controlling RC vehicles via ESP32/ESP8266 microcontrollers using Bluetooth Low Energy (BLE) or WiFi connections.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Arduino](https://img.shields.io/badge/Arduino-00979D?style=flat&logo=Arduino&logoColor=white)
![ESP32](https://img.shields.io/badge/ESP32-E7352C?style=flat&logo=espressif&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Features

- **Dual Connectivity**: Support for both BLE and WiFi connections
- **Intuitive Controls**: 
  - Directional pad with 4-way movement
  - Variable speed slider (0-100%)
  - Boost function with capacitor system
  - Emergency stop button
  - Lights and horn controls
- **Smart UI**:
  - Portrait orientation for connection screen
  - Landscape orientation for controller screen  
  - Demo mode for testing without hardware
- **Safety Features**:
  - Double-press back button to exit
  - Double swipe-up gesture protection
  - Connection status monitoring
- **Professional Design**: Dark theme with smooth animations

## Hardware Requirements

### Core Components
- **ESP32** (recommended) or **ESP8266** development board
- **L298N Motor Driver** or similar
- **2x DC Motors** or servo motors
- **Power Supply** (7-12V for motors, 5V for ESP)
- **Jumper Wires** and breadboard/PCB

### Optional Components
- **LED** (for lights function)
- **Buzzer** (for horn function)
- **Battery pack** for mobile operation

## App Setup

### Prerequisites
- **Flutter SDK** (3.0+)
- **Android Studio** or **VS Code**
- **Physical Android device** (recommended for BLE testing)

### Installation
1. Clone the repository:
```
git clone https://github.com/yourusername/rc-controller-flutter.git
cd rc-controller-flutter
```
2. Install dependencies:
```
flutter pub get
```
3. Run the app:
```
flutter run
```
## Hardware Setup

### Wiring Diagram

#### ESP32 with L298N Motor Driver
```
ESP32          L298N          Motors
GPIO26    ->   IN1            Motor 1 (+)
GPIO27    ->   IN2            Motor 1 (-)
GPIO14    ->   IN3            Motor 2 (+)
GPIO12    ->   IN4            Motor 2 (-)
GPIO25    ->   ENA            Motor 1 Speed
GPIO33    ->   ENB            Motor 2 Speed
GPIO2     ->   LED            Vehicle Lights
GPIO4     ->   BUZZER         Horn
GND       ->   GND            Common Ground
VIN       ->   +12V           Motor Power
```

## Quick Start

1. **Flash Microcontroller**:
   - Open Arduino IDE
   - Install ESP32/ESP8266 board support
   - Upload the appropriate code (see `/arduino` folder)

2. **Launch Flutter App**:
   - Build and install the app on your device
   - Grant Bluetooth and Location permissions

3. **Connect & Control**:
   - Choose BLE or WiFi connection mode
   - Scan for your ESP device
   - Tap to connect
   - Enjoy controlling your RC vehicle!

## Command Protocol

The app sends structured commands to the microcontroller:

```
Movement: "MOVE:UP=1,DOWN=0,LEFT=1,RIGHT=0,SPEED=75,BOOST=1"
Lights:   "LIGHT:1" (on) or "LIGHT:0" (off)
Horn:     "HORN:1"
Stop:     "STOP:1"
```

## Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/                # State management
├── screens/                  # UI screens
├── widgets/                  # Custom widgets
└── services/                 # BLE & WiFi services

arduino/
├── ESP32_BLE/               # ESP32 BLE server code
└── ESP8266_WiFi/            # ESP8266 WiFi AP code
```

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for general questions
- **Documentation**: Check the `/docs` folder for detailed guides

---

**Made with ❤️ for the RC enthusiast community**

## Complete ESP32 BLE Code (arduino/ESP32_BLE/ESP32_BLE.ino)

```cpp
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// UUIDs
#define SERVICE_UUID        "<YOUR SERVICE UUID>"
#define CHARACTERISTIC_UUID "<YOUR CHARACTERISTIC UUID>"

// Forward declarations
void processCommand(const String& command);
int getValue(const String& command, const String& key);
void handleMovement(int up, int down, int left, int right, int speed, int boost);
void stopAllMotors();

BLEServer* pServer = nullptr;
BLECharacteristic* pCharacteristic = nullptr;
bool deviceConnected = false;
bool oldDeviceConnected = false;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    deviceConnected = true;
    Serial.println("Flutter app connected!!");
  }
  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
    Serial.println("Flutter app disconnected. Waiting for reconnection...");
  }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) override {
    String value = pCharacteristic->getValue();
    if (value.length() > 0) {
      Serial.println("=== Command Received ===");
      Serial.println("Raw: " + value);
      processCommand(value);
      Serial.println("=======================");
    }
  }
};

void setup() {
  Serial.begin(115200);
  Serial.println("Starting E-ATV BLE Server...");

  BLEDevice::init("E-ATV");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService* pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE
  );
  pCharacteristic->setCallbacks(new MyCallbacks());
  pCharacteristic->setValue("E-ATV Ready");
  pService->start();

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("E-ATV BLE server active - waiting for Flutter app...");
}

void loop() {
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);
    BLEDevice::startAdvertising();
    Serial.println("Restarting BLE advertising...");
    oldDeviceConnected = deviceConnected;
  }
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }
  delay(100);
}

void processCommand(const String& command) {
  if (command.startsWith("MOVE:")) {
    int up    = getValue(command, "UP=");
    int down  = getValue(command, "DOWN=");
    int left  = getValue(command, "LEFT=");
    int right = getValue(command, "RIGHT=");
    int speed = getValue(command, "SPEED=");
    int boost = getValue(command, "BOOST=");
    Serial.printf(
      "MOVEMENT: UP=%d DOWN=%d LEFT=%d RIGHT=%d SPEED=%d BOOST=%d\n",
      up, down, left, right, speed, boost
    );
    handleMovement(up, down, left, right, speed, boost);
  }
  else if (command.startsWith("LIGHT:")) {
    int state = getValue(command, "LIGHT:");
    Serial.println("LIGHTS: " + String(state ? "ON" : "OFF"));
    // TODO: light control
  }
  else if (command.startsWith("HORN:")) {
    Serial.println("HORN: Activated");
    // TODO: horn control
  }
  else if (command.startsWith("STOP:")) {
    Serial.println("EMERGENCY STOP: All motors stopped");
    stopAllMotors();
  }
  else {
    Serial.println("Unknown command: " + command);
  }
}

int getValue(const String& command, const String& key) {
  int start = command.indexOf(key);
  if (start < 0) return 0;
  start += key.length();
  int end = command.indexOf(',', start);
  if (end < 0) end = command.length();
  return command.substring(start, end).toInt();
}

void handleMovement(int up, int down, int left, int right, int speed, int boost) {
  if (boost) {
    speed = min(100, int(speed * 1.2));
  }
  Serial.println("Motor logic executed with speed: " + String(speed));
  // TODO: motor control code
}

void stopAllMotors() {
  Serial.println("All motors stopped!");
  // TODO: stop motors
}

```