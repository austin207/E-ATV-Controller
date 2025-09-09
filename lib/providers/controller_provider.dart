import 'package:flutter/material.dart';
import 'dart:async';
import '../services/ble_service.dart';

class ControllerProvider extends ChangeNotifier {
  // Arrow button states
  Map<String, bool> _arrowStates = {
    'up': false,
    'down': false,
    'left': false,
    'right': false,
  };

  // Speed and boost controls
  double _speed = 50.0;
  bool _boostActive = false;
  double _capacitorCharge = 100.0;
  bool _capacitorCharging = true;
  bool _lightsOn = false;

  // Capacitor system constants
  static const double _maxCapacitorCharge = 100.0;
  static const double _minBoostThreshold = 20.0;
  static const double _chargeRate = 15.0;
  static const double _dischargeRate = 25.0;
  static const double _boostMultiplier = 1.5;

  Timer? _capacitorTimer;

  // BLE service instance
  final BLEService _bleService = BLEService();
  String? _connectedDeviceId;

  // Getters
  Map<String, bool> get arrowStates => Map.from(_arrowStates);
  double get speed => _speed;
  bool get boostActive => _boostActive;
  double get capacitorCharge => _capacitorCharge;
  bool get canBoost => _capacitorCharge >= _minBoostThreshold;
  bool get lightsOn => _lightsOn;
  double get effectiveSpeed => _boostActive ? _speed * _boostMultiplier : _speed;

  ControllerProvider() {
    _startCapacitorSystem();
  }

  // FIXED: Properly set connected device
  void setConnectedDevice(String deviceId) {
    _connectedDeviceId = deviceId;
    print('ControllerProvider: Connected device set to $deviceId');
  }

  // Clear connected device on disconnect
  void clearConnectedDevice() {
    _connectedDeviceId = null;
    print('ControllerProvider: Connected device cleared');
  }

  // Arrow control methods
  void setArrowState(String direction, bool isPressed) {
    if (_arrowStates.containsKey(direction)) {
      _arrowStates[direction] = isPressed;
      print('Arrow $direction: ${isPressed ? "PRESSED" : "RELEASED"}');
      notifyListeners();
      _sendMovementCommand();
    }
  }

  // Speed control
  void setSpeed(double newSpeed) {
    _speed = newSpeed.clamp(0.0, 100.0);
    print('Speed changed to: $_speed');
    notifyListeners();
    _sendMovementCommand();
  }

  // Boost control
  void setBoost(bool active) {
    if (active && canBoost) {
      _boostActive = true;
      _capacitorCharging = false;
      print('BOOST ACTIVATED');
    } else {
      _boostActive = false;
      _capacitorCharging = true;
      print('BOOST DEACTIVATED');
    }
    notifyListeners();
    _sendMovementCommand();
  }

  // Light control
  void toggleLights() {
    _lightsOn = !_lightsOn;
    print('Lights ${_lightsOn ? "ON" : "OFF"}');
    notifyListeners();
    _sendLightCommand();
  }

  // Emergency stop
  void emergencyStop() {
    _arrowStates.forEach((key, value) => _arrowStates[key] = false);
    _boostActive = false;
    _capacitorCharging = true;
    print('EMERGENCY STOP ACTIVATED');
    notifyListeners();
    _sendEmergencyStopCommand();
  }

  // Capacitor system
  void _startCapacitorSystem() {
    _capacitorTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_boostActive && _capacitorCharge > 0) {
        _capacitorCharge = (_capacitorCharge - (_dischargeRate * 0.1)).clamp(0.0, _maxCapacitorCharge);
        if (_capacitorCharge <= 0) {
          _boostActive = false;
          _capacitorCharging = true;
        }
      } else if (_capacitorCharging && _capacitorCharge < _maxCapacitorCharge) {
        _capacitorCharge = (_capacitorCharge + (_chargeRate * 0.1)).clamp(0.0, _maxCapacitorCharge);
      }
      notifyListeners();
    });
  }

  // FIXED: Better command sending with error handling
  void _sendMovementCommand() {
    String command = _buildMovementCommand();
    print('🚀 SENDING MOVEMENT: $command');

    if (_connectedDeviceId != null) {
      _bleService.sendCommand(_connectedDeviceId!, command);
    } else {
      print('❌ ERROR: No connected device ID!');
    }
  }

  void _sendLightCommand() {
    String command = 'LIGHT:${_lightsOn ? 1 : 0}';
    print('💡 SENDING LIGHT: $command');

    if (_connectedDeviceId != null) {
      _bleService.sendCommand(_connectedDeviceId!, command);
    } else {
      print('❌ ERROR: No connected device ID!');
    }
  }

  void _sendEmergencyStopCommand() {
    String command = 'STOP:1';
    print('🛑 SENDING STOP: $command');

    if (_connectedDeviceId != null) {
      _bleService.sendCommand(_connectedDeviceId!, command);
    } else {
      print('❌ ERROR: No connected device ID!');
    }
  }

  String _buildMovementCommand() {
    return 'MOVE:UP=${_arrowStates['up']! ? 1 : 0},'
        'DOWN=${_arrowStates['down']! ? 1 : 0},'
        'LEFT=${_arrowStates['left']! ? 1 : 0},'
        'RIGHT=${_arrowStates['right']! ? 1 : 0},'
        'SPEED=${effectiveSpeed.toInt()},'
        'BOOST=${_boostActive ? 1 : 0}';
  }

  @override
  void dispose() {
    _capacitorTimer?.cancel();
    super.dispose();
  }
}
