import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'views/homepage.dart';
import 'views/settings.dart';
import 'controller/geo_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  setGeoPrefs();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WattWatch',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => SettingsPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink.shade300),
      ),
    );
  }
}
