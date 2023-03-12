import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/styles_utils.dart' as styles;
import 'appbar.dart';
import 'bottombar.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _counterController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  late SharedPreferences prefs;

  var name;
  var counterNum;
  var street;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _counterController.text = prefs.getString('counterNum') ?? '';
      _postalCodeController.text = prefs.getString('postalCode') ?? '';
      _streetController.text = prefs.getString('street') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarHome = AppBarWidget(screenName: styles.AppBarTypes.SETTINGS);

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        styles.settingsTextField('Name', _nameController),
                        SizedBox(height: 12),
                        styles.settingsTextField(
                            'Zählernummer', _counterController),
                        SizedBox(height: 12),
                        styles.settingsTextField('Adresse', _streetController),
                        SizedBox(height: 12),
                        styles.settingsTextField('PLZ', _postalCodeController),
                        SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: () => onSave(SettingsValues(
                                name: _nameController.text,
                                counterNum: _counterController.text,
                                street: _streetController.text,
                                postalCode: _postalCodeController.text)),
                            child: Text('Speichern',
                                style: TextStyle(fontSize: 16))),
                      ],
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

  void onSave(SettingsValues values) async {
    prefs.setString('name', values.name);
    prefs.setString('counterNum', values.counterNum);
    prefs.setString('street', values.street);
    prefs.setString('postalCode', values.postalCode);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Information gespeichert'),
    ));
  }
}

class SettingsValues {
  final String name;
  final String counterNum;
  final String street;
  final String postalCode;

  const SettingsValues(
      {required this.name,
      required this.counterNum,
      required this.street,
      required this.postalCode});
}
