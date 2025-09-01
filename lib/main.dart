import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/connection_provider.dart';
import 'screens/connection_screen.dart';
import 'screens/controller_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ConnectionProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RC Controller',
      theme: ThemeData.dark(),
      home: Consumer<ConnectionProvider>(
        builder: (_, provider, __) {
          return provider.selected == null
              ? ConnectionScreen()
              : ControllerScreen();
        },
      ),
    );
  }
}
