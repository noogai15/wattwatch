import 'dart:ui';

import 'package:flutter/material.dart';

import 'ui/appbar.dart';
import 'ui/bottombar.dart';
import 'utils/counter_utils.dart';
import 'utils/geo_utils.dart';
import 'utils/styles_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  saveGeoPrefs();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<CounterReading>? allReadings;
  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    final allReadings = await getAllCounterReadings();
    setState(() {
      this.allReadings = allReadings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarHome = AppBarWidget(screenName: AppBarTypes.HOME);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WattWatch',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink.shade300),
      ),
      home: Scaffold(
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
                        child: createReadingsList(),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }

  Container? createReadingsList() {
    final listChildren = <Text>[];
    if (allReadings == null) return null;
    for (final reading in allReadings!) {
      final counterState = reading.counterState;
      final date = formatDate(reading.date);
      listChildren.add(Text(
        '- $date - $counterState kWh',
        style:
            TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Avenir'),
      ));
    }

    return Container(
      height: 400,
      child: ListView(
        children: listChildren,
      ),
    );
  }
}
