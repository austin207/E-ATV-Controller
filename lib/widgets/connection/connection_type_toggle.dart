import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConnectionTypeToggle extends StatelessWidget {
  final bool useBLE;
  final ValueChanged<bool> onToggle;

  const ConnectionTypeToggle({
    Key? key,
    required this.useBLE,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('WiFi', style: TextStyle(color: Colors.white)),
        const SizedBox(width: 16),
        CupertinoSwitch(
          value: useBLE,
          onChanged: onToggle,
          activeColor: Colors.blue,
        ),
        const SizedBox(width: 16),
        const Text('BLE', style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
