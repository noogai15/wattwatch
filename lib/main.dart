import 'dart:ui';

import 'package:flutter/material.dart';

import 'ui/appbar.dart';
import 'ui/bottombar.dart';
import 'ui/init_form_dialogue.dart';
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
  String? counterNum;
  String? name;
  String? street;
  String? postal;
  bool initDialogue = false;

  @override
  void initState() {
    super.initState();
    getPrefs();
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
        home: Stack(children: [
          Scaffold(
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
                            counterNum ?? 'Kein Zählerstand gesetzt!',
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
          if (shouldShowDialogue())
            Positioned(
                top: 200,
                child: DialogueSequence(
                    name ?? '', counterNum ?? '', street ?? '', postal ?? ''))
        ]));
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

  void getPrefs() async {
    final allReadings = await getAllCounterReadings();
    final name = await getName();
    final counterNum = await getCounterNum();
    final street = await getStreet();
    final postal = await getPostalCode();

    setState(() {
      this.allReadings = allReadings;
      this.name = name;
      this.counterNum = counterNum;
      this.street = street;
      this.postal = postal;
    });
  }

  bool shouldShowDialogue() {
    if (this.name == null ||
        this.counterNum == null ||
        this.street == null ||
        this.postal == null) return true;
    return false;
  }
}
