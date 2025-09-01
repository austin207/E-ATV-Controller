import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConnectionTypeToggle extends StatelessWidget {
  final bool useBLE;
  final ValueChanged<bool> onToggle;

  ConnectionTypeToggle({
    required this.useBLE,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('BLE'),
        CupertinoSwitch(
          value: useBLE,
          onChanged: onToggle,
        ),
        Text('WiFi'),
      ],
    );
  }
}
