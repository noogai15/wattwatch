import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/counter_utils.dart';

class SendFormDialogue extends StatefulWidget {
  String counterNum = '';
  SendFormDialogue(this.counterNum);

  @override
  State<StatefulWidget> createState() => SendFormDialogueState(counterNum);
}

class SendFormDialogueState extends State<SendFormDialogue> {
  late SharedPreferences prefs;
  String counter = '';
  int? formattedCounter;
  SendFormDialogueState(this.counter);

  @override
  void initState() {
    super.initState();
    setState(() {
      formattedCounter = formatCounter(counter);
    });
    initStateAsync();
  }

  void initStateAsync() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        height: 300.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (formattedCounter == null)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  '''Zählerstand nicht erkannt, bitte manuell eingeben oder nochmal versuchen''',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.red[400]),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                    text: formattedCounter == null
                        ? ''
                        : formattedCounter.toString()),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Zahlerstand'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: ElevatedButton(
                onPressed: onSubmit,
                child: Text('Speichern & Abschicken'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSubmit() async {
    saveCounterReading(formattedCounter!);
    // postCounterNum(formattedCounter!);
  }
}
