import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendFormDialogue extends StatefulWidget {
  String counterNum = '';
  SendFormDialogue(this.counterNum);

  @override
  State<StatefulWidget> createState() => SendFormDialogueState(counterNum);
}

class SendFormDialogueState extends State<SendFormDialogue> {
  final TextEditingController _postalCodeController = TextEditingController();

  String counterNum = '';
  SendFormDialogueState(this.counterNum);

  @override
  void initState() {
    super.initState();

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
                controller: TextEditingController(text: counterNum),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Zahlerstand'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _postalCodeController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'PLZ'),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(15.0),
            //   child: TextField(
            //     readOnly: true,
            //     keyboardType: TextInputType.number,
            //     controller: TextEditingController(text: getToday()),
            //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            //     decoration: InputDecoration(
            //         border: OutlineInputBorder(), labelText: 'Datum'),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: ElevatedButton(
                onPressed: onSubmit,
                child: Text('Abschicken'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// String getToday() {
//   DateTime now = new DateTime.now();
//   DateTime date = new DateTime(now.year, now.month, now.day);
//   return date.toString();
// }

void onSubmit() {
  //TODO
}
