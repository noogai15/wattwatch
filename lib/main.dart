import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/appbar.dart';
import 'ui/bottombar.dart';
import 'utils/geo_utils.dart';
import 'utils/styles_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  savePostalCode();
  saveStreet();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WattWatch',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink.shade300),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var labels = 'assets/labels.txt';
  var model = 'model.tflite';

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    final appBarHome = AppBarWidget(screenName: AppBarTypes.HOME);

    return Scaffold(
      backgroundColor: Color(0xff4A6488),
      bottomNavigationBar: Container(child: BottomBarWidget()),
      appBar: PreferredSize(
          preferredSize: appBarHome.preferredSize, child: appBarHome),
      body: Column(children: [
        Flexible(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ihre Zählernummer: ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Avenir')),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Use parameter for widget here',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Avenir'),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      'Letzte Ablesungen:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Avenir'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '- 16/02/2023 - 1483 kWh',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Avenir'),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}

void savePostalCode() async {
  final prefs = await SharedPreferences.getInstance();
  final postalCode = await getPostalCode();
  prefs.setString('postalCode', postalCode);
}

void saveStreet() async {
  final prefs = await SharedPreferences.getInstance();
  final street = await getStreet();
  prefs.setString('street', street);
}
