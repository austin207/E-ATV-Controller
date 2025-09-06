import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Setup Guide'),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Overview',
              'This RC Controller app works with ESP32 microcontrollers via Bluetooth Low Energy (BLE) or WiFi. Follow this guide to configure your ESP32.',
            ),

            _buildSection(
              'Hardware Requirements',
              '• ESP32 Development Board\n'
                  '• Motor Driver (L298N recommended)\n'
                  '• DC Motors or Servo Motors\n'
                  '• Power Supply (7-12V)\n'
                  '• Jumper Wires\n'
                  '• Breadboard or PCB',
            ),

            _buildCodeSection(
              'Option 1: BLE Configuration',
              _getBLECode(),
              'Upload this code for Bluetooth Low Energy communication.',
            ),

            _buildCodeSection(
              'Option 2: WiFi AP Configuration',
              _getWiFiCode(),
              'Upload this code to create a WiFi access point.',
            ),

            _buildSection(
              'Pin Connections',
              'Motor Driver (L298N) Connections:\n'
                  '• IN1 → GPIO 26\n'
                  '• IN2 → GPIO 27\n'
                  '• IN3 → GPIO 14\n'
                  '• IN4 → GPIO 12\n'
                  '• ENA → GPIO 25\n'
                  '• ENB → GPIO 33\n\n'
                  'Optional Components:\n'
                  '• LED (Lights) → GPIO 2\n'
                  '• Buzzer (Horn) → GPIO 4',
            ),

            _buildSection(
              'Command Format',
              'The app sends these commands to ESP32:\n\n'
                  '• Movement: "MOVE:UP=1,DOWN=0,LEFT=1,RIGHT=0,SPEED=75,BOOST=1"\n'
                  '• Lights: "LIGHT:1" (on) or "LIGHT:0" (off)\n'
                  '• Horn: "HORN:1"\n'
                  '• Emergency Stop: "STOP:1"',
            ),

            _buildSection(
              'Setup Steps',
              '1. Install Arduino IDE\n'
                  '2. Add ESP32 board support\n'
                  '3. Connect ESP32 via USB\n'
                  '4. Copy and upload the code\n'
                  '5. Wire your motors and components\n'
                  '6. Power on and test with the app',
            ),

            _buildSection(
              'Troubleshooting',
              '• Ensure ESP32 is powered and code is running\n'
                  '• Check that Bluetooth/WiFi is enabled on your phone\n'
                  '• For BLE: Look for "ESP32_RC_Car" in device list\n'
                  '• For WiFi: Connect to "ESP32_RC_Car" network\n'
                  '• Verify pin connections match the code\n'
                  '• Check serial monitor for debug messages',
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeSection(String title, String code, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    // Show snackbar
                  },
                  icon: const Icon(Icons.copy, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBLECode() {
    return '''#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Motor pins
#define MOTOR1_PIN1 26
#define MOTOR1_PIN2 27
#define MOTOR2_PIN1 14
#define MOTOR2_PIN2 12
#define MOTOR1_PWM 25
#define MOTOR2_PWM 33

// Accessory pins
#define LED_PIN 2
#define BUZZER_PIN 4

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };
    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      String command = pCharacteristic->getValue().c_str();
      processCommand(command);
    }
};

void setup() {
  Serial.begin(115200);
  
  // Initialize pins
  pinMode(MOTOR1_PIN1, OUTPUT);
  pinMode(MOTOR1_PIN2, OUTPUT);
  pinMode(MOTOR2_PIN1, OUTPUT);
  pinMode(MOTOR2_PIN2, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Setup BLE
  BLEDevice::init("ESP32_RC_Car");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  
  BLEService *pService = pServer->createService("12345678-1234-1234-1234-1234567890ab");
  pCharacteristic = pService->createCharacteristic(
    "87654321-4321-4321-4321-ba0987654321",
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE
  );
  
  pCharacteristic->setCallbacks(new MyCallbacks());
  pService->start();
  
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID("12345678-1234-1234-1234-1234567890ab");
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);
  BLEDevice::startAdvertising();
  
  Serial.println("ESP32 RC Car Ready!");
}

void loop() {
  if (!deviceConnected) {
    delay(500);
    BLEDevice::startAdvertising();
  }
  delay(20);
}

void processCommand(String command) {
  Serial.println("Received: " + command);
  
  if (command.startsWith("MOVE:")) {
    handleMovement(command);
  } else if (command.startsWith("LIGHT:")) {
    int state = command.substring(6).toInt();
    digitalWrite(LED_PIN, state);
  } else if (command.startsWith("HORN:")) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
  } else if (command.startsWith("STOP:")) {
    stopAllMotors();
  }
}

void handleMovement(String command) {
  int up = getValue(command, "UP=");
  int down = getValue(command, "DOWN=");
  int left = getValue(command, "LEFT=");
  int right = getValue(command, "RIGHT=");
  int speed = getValue(command, "SPEED=");
  
  speed = constrain(speed, 0, 255);
  
  // Forward/Backward
  if (up && !down) {
    digitalWrite(MOTOR1_PIN1, HIGH);
    digitalWrite(MOTOR1_PIN2, LOW);
    digitalWrite(MOTOR2_PIN1, HIGH);
    digitalWrite(MOTOR2_PIN2, LOW);
  } else if (down && !up) {
    digitalWrite(MOTOR1_PIN1, LOW);
    digitalWrite(MOTOR1_PIN2, HIGH);
    digitalWrite(MOTOR2_PIN1, LOW);
    digitalWrite(MOTOR2_PIN2, HIGH);
  } else if (left && !right) {
    digitalWrite(MOTOR1_PIN1, LOW);
    digitalWrite(MOTOR1_PIN2, HIGH);
    digitalWrite(MOTOR2_PIN1, HIGH);
    digitalWrite(MOTOR2_PIN2, LOW);
  } else if (right && !left) {
    digitalWrite(MOTOR1_PIN1, HIGH);
    digitalWrite(MOTOR1_PIN2, LOW);
    digitalWrite(MOTOR2_PIN1, LOW);
    digitalWrite(MOTOR2_PIN2, HIGH);
  } else {
    stopAllMotors();
    return;
  }
  
  analogWrite(MOTOR1_PWM, speed);
  analogWrite(MOTOR2_PWM, speed);
}

void stopAllMotors() {
  digitalWrite(MOTOR1_PIN1, LOW);
  digitalWrite(MOTOR1_PIN2, LOW);
  digitalWrite(MOTOR2_PIN1, LOW);
  digitalWrite(MOTOR2_PIN2, LOW);
  analogWrite(MOTOR1_PWM, 0);
  analogWrite(MOTOR2_PWM, 0);
}

int getValue(String command, String key) {
  int startIndex = command.indexOf(key);
  if (startIndex == -1) return 0;
  startIndex += key.length();
  int endIndex = command.indexOf(',', startIndex);
  if (endIndex == -1) endIndex = command.length();
  return command.substring(startIndex, endIndex).toInt();
}''';
  }

  String _getWiFiCode() {
    return '''#include <WiFi.h>
#include <WebServer.h>

// WiFi credentials
const char* ssid = "ESP32_RC_Car";
const char* password = "12345678";

// Motor pins (same as BLE version)
#define MOTOR1_PIN1 26
#define MOTOR1_PIN2 27
#define MOTOR2_PIN1 14
#define MOTOR2_PIN2 12
#define MOTOR1_PWM 25
#define MOTOR2_PWM 33
#define LED_PIN 2
#define BUZZER_PIN 4

WebServer server(80);

void setup() {
  Serial.begin(115200);
  
  // Initialize pins
  pinMode(MOTOR1_PIN1, OUTPUT);
  pinMode(MOTOR1_PIN2, OUTPUT);
  pinMode(MOTOR2_PIN1, OUTPUT);
  pinMode(MOTOR2_PIN2, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Setup WiFi AP
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);
  
  Serial.println("WiFi AP Started");
  Serial.print("IP Address: ");
  Serial.println(WiFi.softAPIP());
  
  // Setup web server endpoints
  server.on("/command", HTTP_POST, handleCommand);
  server.begin();
  
  Serial.println("ESP32 RC Car Ready!");
}

void loop() {
  server.handleClient();
}

void handleCommand() {
  if (server.hasArg("cmd")) {
    String command = server.arg("cmd");
    Serial.println("Received: " + command);
    processCommand(command);
    server.send(200, "text/plain", "OK");
  } else {
    server.send(400, "text/plain", "Missing command");
  }
}

// Same processCommand, handleMovement, stopAllMotors, and getValue functions as BLE version''';
  }
}
