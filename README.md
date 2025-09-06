# 🚗 RC Controller Flutter App

A professional Flutter application for controlling RC vehicles via ESP32/ESP8266 microcontrollers using Bluetooth Low Energy (BLE) or WiFi connections.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Arduino](https://img.shields.io/badge/Arduino-00979D?style=flat&logo=Arduino&logoColor=white)
![ESP32](https://img.shields.io/badge/ESP32-E7352C?style=flat&logo=espressif&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

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

## 🛠️ Hardware Requirements

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

## 📱 App Setup

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
## 🔌 Hardware Setup

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

## 🚀 Quick Start

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

## 📡 Command Protocol

The app sends structured commands to the microcontroller:

```
Movement: "MOVE:UP=1,DOWN=0,LEFT=1,RIGHT=0,SPEED=75,BOOST=1"
Lights:   "LIGHT:1" (on) or "LIGHT:0" (off)
Horn:     "HORN:1"
Stop:     "STOP:1"
```

## 🔧 Development

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

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for general questions
- **Documentation**: Check the `/docs` folder for detailed guides

---

**Made with ❤️ for the RC enthusiast community**

## Complete ESP32 BLE Code (arduino/ESP32_BLE/ESP32_BLE.ino)

```cpp
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Motor Control Pins
#define MOTOR1_PIN1 26
#define MOTOR1_PIN2 27
#define MOTOR2_PIN1 14
#define MOTOR2_PIN2 12
#define MOTOR1_PWM 25
#define MOTOR2_PWM 33

// Accessory Pins
#define LED_PIN 2
#define BUZZER_PIN 4

// BLE Configuration
#define SERVICE_UUID        "12345678-1234-1234-1234-1234567890ab"
#define CHARACTERISTIC_UUID "87654321-4321-4321-4321-ba0987654321"

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("Device Connected");
    }

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      stopAllMotors();
      Serial.println("Device Disconnected");
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      if (value.length() > 0) {
        String command = String(value.c_str());
        Serial.println("Received: " + command);
        processCommand(command);
      }
    }
};

void setup() {
  Serial.begin(115200);
  
  // Initialize motor pins
  pinMode(MOTOR1_PIN1, OUTPUT);
  pinMode(MOTOR1_PIN2, OUTPUT);
  pinMode(MOTOR2_PIN1, OUTPUT);
  pinMode(MOTOR2_PIN2, OUTPUT);
  pinMode(MOTOR1_PWM, OUTPUT);
  pinMode(MOTOR2_PWM, OUTPUT);
  
  // Initialize accessory pins
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Stop all motors initially
  stopAllMotors();
  
  // Initialize BLE
  BLEDevice::init("ESP32_RC_Car");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_WRITE
                    );

  pCharacteristic->setCallbacks(new MyCallbacks());

  pService->start();
  
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);
  BLEDevice::startAdvertising();
  
  Serial.println("ESP32 RC Car BLE Server Ready!");
}

void loop() {
  // Restart advertising if disconnected
  if (!deviceConnected) {
    delay(500);
    BLEDevice::startAdvertising();
  }
  delay(20);
}

void processCommand(String command) {
  if (command.startsWith("MOVE:")) {
    handleMovement(command);
  } else if (command.startsWith("LIGHT:")) {
    int state = command.substring(6).toInt();
    digitalWrite(LED_PIN, state);
    Serial.println("Light: " + String(state ? "ON" : "OFF"));
  } else if (command.startsWith("HORN:")) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
    Serial.println("Horn activated");
  } else if (command.startsWith("STOP:")) {
    stopAllMotors();
    Serial.println("Emergency stop");
  }
}

void handleMovement(String command) {
  int up = getValue(command, "UP=");
  int down = getValue(command, "DOWN=");
  int left = getValue(command, "LEFT=");
  int right = getValue(command, "RIGHT=");
  int speed = getValue(command, "SPEED=");
  int boost = getValue(command, "BOOST=");
  
  // Apply boost multiplier
  if (boost) {
    speed = min(255, (int)(speed * 1.5));
  }
  
  speed = constrain(speed, 0, 255);
  
  Serial.printf("Movement - UP:%d DOWN:%d LEFT:%d RIGHT:%d SPEED:%d BOOST:%d\n", 
                up, down, left, right, speed, boost);

  // Handle movement combinations
  if (up && !down) {
    if (left && !right) {
      // Forward Left
      setMotorSpeed(1, speed * 0.7); // Reduce left motor for turning
      setMotorSpeed(2, speed);
    } else if (right && !left) {
      // Forward Right  
      setMotorSpeed(1, speed);
      setMotorSpeed(2, speed * 0.7); // Reduce right motor for turning
    } else {
      // Forward
      setMotorSpeed(1, speed);
      setMotorSpeed(2, speed);
    }
  } else if (down && !up) {
    if (left && !right) {
      // Backward Left
      setMotorSpeed(1, -speed * 0.7);
      setMotorSpeed(2, -speed);
    } else if (right && !left) {
      // Backward Right
      setMotorSpeed(1, -speed);
      setMotorSpeed(2, -speed * 0.7);
    } else {
      // Backward
      setMotorSpeed(1, -speed);
      setMotorSpeed(2, -speed);
    }
  } else if (left && !right && !up && !down) {
    // Turn Left (tank turn)
    setMotorSpeed(1, -speed * 0.8);
    setMotorSpeed(2, speed * 0.8);
  } else if (right && !left && !up && !down) {
    // Turn Right (tank turn)
    setMotorSpeed(1, speed * 0.8);
    setMotorSpeed(2, -speed * 0.8);
  } else {
    // Stop
    stopAllMotors();
  }
}

void setMotorSpeed(int motor, int speed) {
  if (motor == 1) {
    if (speed > 0) {
      digitalWrite(MOTOR1_PIN1, HIGH);
      digitalWrite(MOTOR1_PIN2, LOW);
      analogWrite(MOTOR1_PWM, speed);
    } else if (speed < 0) {
      digitalWrite(MOTOR1_PIN1, LOW);
      digitalWrite(MOTOR1_PIN2, HIGH);
      analogWrite(MOTOR1_PWM, -speed);
    } else {
      digitalWrite(MOTOR1_PIN1, LOW);
      digitalWrite(MOTOR1_PIN2, LOW);
      analogWrite(MOTOR1_PWM, 0);
    }
  } else if (motor == 2) {
    if (speed > 0) {
      digitalWrite(MOTOR2_PIN1, HIGH);
      digitalWrite(MOTOR2_PIN2, LOW);
      analogWrite(MOTOR2_PWM, speed);
    } else if (speed < 0) {
      digitalWrite(MOTOR2_PIN1, LOW);
      digitalWrite(MOTOR2_PIN2, HIGH);
      analogWrite(MOTOR2_PWM, -speed);
    } else {
      digitalWrite(MOTOR2_PIN1, LOW);
      digitalWrite(MOTOR2_PIN2, LOW);
      analogWrite(MOTOR2_PWM, 0);
    }
  }
}

void stopAllMotors() {
  setMotorSpeed(1, 0);
  setMotorSpeed(2, 0);
}

int getValue(String command, String key) {
  int startIndex = command.indexOf(key);
  if (startIndex == -1) return 0;
  
  startIndex += key.length();
  int endIndex = command.indexOf(',', startIndex);
  if (endIndex == -1) endIndex = command.length();
  
  return command.substring(startIndex, endIndex).toInt();
}
```

## Complete ESP8266 WiFi Code (arduino/ESP8266_WiFi/ESP8266_WiFi.ino)

```cpp
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

// Network Configuration
const char* ssid = "ESP8266_RC_Car";
const char* password = "12345678";

// Motor Control Pins (NodeMCU Pin Labels)
#define MOTOR1_PIN1 D5  // GPIO14
#define MOTOR1_PIN2 D6  // GPIO12
#define MOTOR2_PIN1 D7  // GPIO13
#define MOTOR2_PIN2 D8  // GPIO15
#define MOTOR1_PWM  D1  // GPIO5
#define MOTOR2_PWM  D2  // GPIO4

// Accessory Pins
#define LED_PIN     D4  // GPIO2 (built-in LED)
#define BUZZER_PIN  D3  // GPIO0

ESP8266WebServer server(80);

void setup() {
  Serial.begin(115200);
  
  // Initialize motor pins
  pinMode(MOTOR1_PIN1, OUTPUT);
  pinMode(MOTOR1_PIN2, OUTPUT);
  pinMode(MOTOR2_PIN1, OUTPUT);
  pinMode(MOTOR2_PIN2, OUTPUT);
  pinMode(MOTOR1_PWM, OUTPUT);
  pinMode(MOTOR2_PWM, OUTPUT);
  
  // Initialize accessory pins
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Stop all motors initially
  stopAllMotors();
  
  // Setup WiFi Access Point
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);
  
  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP);
  
  // Setup HTTP server routes
  server.on("/", handleRoot);
  server.on("/command", HTTP_POST, handleCommand);
  server.on("/status", HTTP_GET, handleStatus);
  server.onNotFound(handleNotFound);
  
  server.begin();
  Serial.println("HTTP server started");
  Serial.println("ESP8266 RC Car WiFi Ready!");
}

void loop() {
  server.handleClient();
}

void handleRoot() {
  String html = "<html><body>";
  html += "<h1>ESP8266 RC Car</h1>";
  html += "<p>RC Car is ready for commands</p>";
  html += "<p>Send POST requests to /command</p>";
  html += "</body></html>";
  server.send(200, "text/html", html);
}

void handleCommand() {
  if (server.hasArg("cmd")) {
    String command = server.arg("cmd");
    Serial.println("Received: " + command);
    processCommand(command);
    server.send(200, "text/plain", "OK");
  } else {
    server.send(400, "text/plain", "Missing 'cmd' parameter");
  }
}

void handleStatus() {
  String json = "{";
  json += "\"connected\": " + String(WiFi.softAPgetStationNum()) + ",";
  json += "\"ip\": \"" + WiFi.softAPIP().toString() + "\",";
  json += "\"ssid\": \"" + String(ssid) + "\"";
  json += "}";
  server.send(200, "application/json", json);
}

void handleNotFound() {
  server.send(404, "text/plain", "Not found");
}

void processCommand(String command) {
  if (command.startsWith("MOVE:")) {
    handleMovement(command);
  } else if (command.startsWith("LIGHT:")) {
    int state = command.substring(6).toInt();
    digitalWrite(LED_PIN, !state); // Built-in LED is inverted
    Serial.println("Light: " + String(state ? "ON" : "OFF"));
  } else if (command.startsWith("HORN:")) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
    Serial.println("Horn activated");
  } else if (command.startsWith("STOP:")) {
    stopAllMotors();
    Serial.println("Emergency stop");
  }
}

void handleMovement(String command) {
  int up = getValue(command, "UP=");
  int down = getValue(command, "DOWN=");
  int left = getValue(command, "LEFT=");
  int right = getValue(command, "RIGHT=");
  int speed = getValue(command, "SPEED=");
  int boost = getValue(command, "BOOST=");
  
  // Convert speed from 0-100 to 0-1023 (ESP8266 PWM range)
  speed = map(speed, 0, 100, 0, 1023);
  
  // Apply boost multiplier
  if (boost) {
    speed = min(1023, (int)(speed * 1.5));
  }
  
  Serial.printf("Movement - UP:%d DOWN:%d LEFT:%d RIGHT:%d SPEED:%d BOOST:%d\n", 
                up, down, left, right, speed, boost);

  // Handle movement combinations (same logic as ESP32)
  if (up && !down) {
    if (left && !right) {
      setMotorSpeed(1, speed * 0.7);
      setMotorSpeed(2, speed);
    } else if (right && !left) {
      setMotorSpeed(1, speed);
      setMotorSpeed(2, speed * 0.7);
    } else {
      setMotorSpeed(1, speed);
      setMotorSpeed(2, speed);
    }
  } else if (down && !up) {
    if (left && !right) {
      setMotorSpeed(1, -speed * 0.7);
      setMotorSpeed(2, -speed);
    } else if (right && !left) {
      setMotorSpeed(1, -speed);
      setMotorSpeed(2, -speed * 0.7);
    } else {
      setMotorSpeed(1, -speed);
      setMotorSpeed(2, -speed);
    }
  } else if (left && !right && !up && !down) {
    setMotorSpeed(1, -speed * 0.8);
    setMotorSpeed(2, speed * 0.8);
  } else if (right && !left && !up && !down) {
    setMotorSpeed(1, speed * 0.8);
    setMotorSpeed(2, -speed * 0.8);
  } else {
    stopAllMotors();
  }
}

void setMotorSpeed(int motor, int speed) {
  if (motor == 1) {
    if (speed > 0) {
      digitalWrite(MOTOR1_PIN1, HIGH);
      digitalWrite(MOTOR1_PIN2, LOW);
      analogWrite(MOTOR1_PWM, speed);
    } else if (speed < 0) {
      digitalWrite(MOTOR1_PIN1, LOW);
      digitalWrite(MOTOR1_PIN2, HIGH);
      analogWrite(MOTOR1_PWM, -speed);
    } else {
      digitalWrite(MOTOR1_PIN1, LOW);
      digitalWrite(MOTOR1_PIN2, LOW);
      analogWrite(MOTOR1_PWM, 0);
    }
  } else if (motor == 2) {
    if (speed > 0) {
      digitalWrite(MOTOR2_PIN1, HIGH);
      digitalWrite(MOTOR2_PIN2, LOW);
      analogWrite(MOTOR2_PWM, speed);
    } else if (speed < 0) {
      digitalWrite(MOTOR2_PIN1, LOW);
      digitalWrite(MOTOR2_PIN2, HIGH);
      analogWrite(MOTOR2_PWM, -speed);
    } else {
      digitalWrite(MOTOR2_PIN1, LOW);
      digitalWrite(MOTOR2_PIN2, LOW);
      analogWrite(MOTOR2_PWM, 0);
    }
  }
}

void stopAllMotors() {
  setMotorSpeed(1, 0);
  setMotorSpeed(2, 0);
}

int getValue(String command, String key) {
  int startIndex = command.indexOf(key);
  if (startIndex == -1) return 0;
  
  startIndex += key.length();
  int endIndex = command.indexOf(',', startIndex);
  if (endIndex == -1) endIndex = command.length();
  
  return command.substring(startIndex, endIndex).toInt();
}
```