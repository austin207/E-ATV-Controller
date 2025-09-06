## Setup Instructions 

# Setup Instructions

## Arduino IDE Configuration

### ESP32 Setup
1. Install Arduino IDE (1.8.19 or newer)
2. Add ESP32 board support:
   - File → Preferences
   - Additional Board Manager URLs: `https://dl.espressif.com/dl/package_esp32_index.json`
   - Tools → Board → Boards Manager → Search "ESP32" → Install
3. Install required libraries:
   - ESP32 BLE Arduino (by Neil Kolban)

### ESP8266 Setup
1. Add ESP8266 board support:
   - Additional Board Manager URLs: `http://arduino.esp8266.com/stable/package_esp8266com_index.json`
   - Tools → Board → Boards Manager → Search "ESP8266" → Install
2. Select board: "NodeMCU 1.0 (ESP-12E Module)"

## Hardware Assembly

### Basic RC Car Assembly
1. Mount ESP32/ESP8266 on chassis
2. Connect L298N motor driver
3. Wire motors to driver outputs
4. Connect power supply (7-12V for motors)
5. Add optional LED and buzzer
6. Test connections before powering on

### Power Considerations
- Motors: 7-12V (separate power supply)
- ESP32: 5V via USB or VIN pin
- ESP8266: 3.3V (use NodeMCU board for easier 5V input)

## Flutter App Installation

### Prerequisites
- Flutter SDK 3.0+
- Android device (iOS support available)
- Enable Developer Options and USB Debugging

### Installation Steps
```
# Clone repository
git clone https://github.com/yourusername/rc-controller-flutter.git
cd rc-controller-flutter

# Get dependencies
flutter pub get

# Connect device and run
flutter devices
flutter run
```

### Permissions
Grant the following permissions when prompted:
- Bluetooth (for BLE connection)
- Location (required for BLE scanning on Android)
- Nearby Devices (Android 12+)

## Troubleshooting

### Common Issues
1. **BLE not connecting**: Ensure location services are enabled
2. **WiFi not found**: Check ESP8266 is broadcasting AP
3. **Motors not responding**: Verify wiring and power supply
4. **App crashes**: Check Flutter version compatibility

### Debug Tips
- Monitor Serial output in Arduino IDE
- Use Flutter debugger for app issues
- Check battery voltage for motor problems
- Verify pin connections match code definitions
