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
  final TextEditingController _postalCodeController = TextEditingController();
  String counter = '';
  var formattedCounter;
  SendFormDialogueState(this.counter);

  @override
  void initState() {
    super.initState();
    formattedCounter = formatCounter(counter);
    initStateAsync();
  }

  void initStateAsync() async {
    final prefs = await SharedPreferences.getInstance();
    _postalCodeController.text = prefs.getString('postalCode')!;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        height: 300.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: formattedCounter.toString()),
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
}

void onSubmit() {}
