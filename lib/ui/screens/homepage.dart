import 'package:flutter/material.dart';

import '../../models/counter_reading_model.dart';
import '../../utils/counter_utils.dart';
import '../../utils/geo_utils.dart';
import '../../utils/name_utils.dart';
import '../../utils/styles_utils.dart';
import '../bars/appbar.dart';
import '../bars/bottombar.dart';
import '../dialogues/init_form_dialogue.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<CounterReading>? allReadings;
  String? counterNum;
  String? name;
  String? street;
  String? postal;
  bool showDialog = false;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    await getPrefs();
    shouldShowDialogue();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHome = AppBarWidget(screenName: AppBarTypes.START);

    return Stack(children: [
      AbsorbPointer(
        absorbing: this.showDialog,
        child: Container(
          foregroundDecoration: this.showDialog
              ? BoxDecoration(
                  color: Color.fromARGB(200, 0, 0, 0),
                  backgroundBlendMode: BlendMode.multiply)
              : null,
          child: Scaffold(
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
        ),
      ),
      showDialog
          ? Positioned(
              child: DialogueSequence(
                  name ?? '', counterNum ?? '', street ?? '', postal ?? '', () {
              closeDialog();
            }))
          : Container()
    ]);
  }

  Container createReadingsList() {
    final listChildren = <Text>[];
    if (allReadings == null) return Container();
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

  Future<bool> getPrefs() async {
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
    return true;
  }

  void closeDialog() {
    setState(() {
      this.showDialog = false;
    });
    getPrefs();
  }

  void shouldShowDialogue() {
    if (this.name == null ||
        this.counterNum == null ||
        this.street == null ||
        this.postal == null ||
        this.name!.isEmpty ||
        this.counterNum!.isEmpty ||
        this.street!.isEmpty ||
        this.postal!.isEmpty) {
      setState(() {
        this.showDialog = true;
      });
    } else {
      setState(() {
        this.showDialog = false;
      });
    }
  }
}
