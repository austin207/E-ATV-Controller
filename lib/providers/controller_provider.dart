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
  static const double _chargeRate = 15.0; // charge per second
  static const double _dischargeRate = 25.0; // discharge per second during boost
  static const double _boostMultiplier = 1.5;

  Timer? _capacitorTimer;

  // Add BLE service instance
  final BLEService _bleService = BLEService();

  // Add connected device ID
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

  // Add setter for device ID
  void setConnectedDevice(String deviceId) {
    _connectedDeviceId = deviceId;
  }

  // Arrow control methods
  void setArrowState(String direction, bool isPressed) {
    if (_arrowStates.containsKey(direction)) {
      _arrowStates[direction] = isPressed;
      notifyListeners();
      _sendMovementCommand();
    }
  }

  // Speed control
  void setSpeed(double newSpeed) {
    _speed = newSpeed.clamp(0.0, 100.0);
    notifyListeners();
    _sendMovementCommand();
  }

  // Boost control
  void setBoost(bool active) {
    if (active && canBoost) {
      _boostActive = true;
      _capacitorCharging = false;
    } else {
      _boostActive = false;
      _capacitorCharging = true;
    }
    notifyListeners();
    _sendMovementCommand();
  }

  // Light control
  void toggleLights() {
    _lightsOn = !_lightsOn;
    notifyListeners();
    _sendLightCommand();
  }

  // Emergency stop
  void emergencyStop() {
    _arrowStates.forEach((key, value) => _arrowStates[key] = false);
    _boostActive = false;
    _capacitorCharging = true;
    notifyListeners();
    _sendEmergencyStopCommand();
  }

  // Capacitor system
  void _startCapacitorSystem() {
    _capacitorTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_boostActive && _capacitorCharge > 0) {
        // Discharge during boost
        _capacitorCharge = (_capacitorCharge - (_dischargeRate * 0.1)).clamp(0.0, _maxCapacitorCharge);
        if (_capacitorCharge <= 0) {
          _boostActive = false;
          _capacitorCharging = true;
        }
      } else if (_capacitorCharging && _capacitorCharge < _maxCapacitorCharge) {
        // Charge when not boosting
        _capacitorCharge = (_capacitorCharge + (_chargeRate * 0.1)).clamp(0.0, _maxCapacitorCharge);
      }
      notifyListeners();
    });
  }

  // Command sending methods (to be connected to BLE service)
  void _sendMovementCommand() {
    String command = _buildMovementCommand();
    print('Sending: $command'); // Debug print

    // Send via BLE if connected
    if (_connectedDeviceId != null) {
      _bleService.sendCommand(_connectedDeviceId!, command);
    }
  }

  void _sendLightCommand() {
    String command = 'LIGHT:${_lightsOn ? 1 : 0}';
    print('Sending: $command');

    if (_connectedDeviceId != null) {
      _bleService.sendCommand(_connectedDeviceId!, command);
    }
  }

  void _sendEmergencyStopCommand() {
    String command = 'STOP:1';
    print('Sending: $command');

    if (_connectedDeviceId != null) {
      _bleService.sendCommand(_connectedDeviceId!, command);
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
