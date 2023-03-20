import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/counter_utils.dart';

class SendFormDialogue extends StatefulWidget {
  int? counterNum;
  SendFormDialogue(this.counterNum);

  @override
  State<StatefulWidget> createState() => SendFormDialogueState(counterNum);
}

class SendFormDialogueState extends State<SendFormDialogue> {
  late SharedPreferences prefs;
  int? counter;
  SendFormDialogueState(this.counter);

  @override
  void initState() {
    super.initState();
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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                '''Bitte Zählerstand nochmal sorgfältig überprüfen!''',
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                    text: counter == null ? '' : counter.toString()),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Zahlerstand'),
              ),
            ),
            if (counter == null)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  '''Zählerstand nicht erkannt, bitte manuell eingeben oder nochmal versuchen''',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.red[400]),
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
    saveCounterReading(counter!);
    // postCounterNum(formattedCounter!);
  }
}
