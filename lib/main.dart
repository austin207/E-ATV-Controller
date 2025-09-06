import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/connection_provider.dart';
import 'providers/controller_provider.dart';
import 'screens/connection_screen.dart';
import 'screens/controller_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove the orientation lock from here
  // Let each screen handle its own orientation

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => ControllerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RC Controller',
      theme: ThemeData.dark(),
      home: Consumer2<ConnectionProvider, ControllerProvider>(
        builder: (context, connectionProvider, controllerProvider, child) {
          if (connectionProvider.selected?.isConnected == true) {
            connectionProvider.linkControllerProvider(controllerProvider);
            return const ControllerScreen();
          } else {
            return const ConnectionScreen();
          }
        },
      ),
    );
  }
}
