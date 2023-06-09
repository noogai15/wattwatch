import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/settings_values_model.dart';
import '../../utils/styles_utils.dart' as styles;
import '../../utils/styles_utils.dart';
import '../bars/appbar.dart';
import '../bars/bottombar.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _counterController;
  late TextEditingController _streetController;
  late TextEditingController _postalCodeController;
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
    _nameController =
        TextEditingController(text: prefs.getString('name') ?? '');
    _counterController =
        TextEditingController(text: prefs.getString('counterNum') ?? '');
    _postalCodeController =
        TextEditingController(text: prefs.getString('postalCode') ?? '');
    _streetController =
        TextEditingController(text: prefs.getString('street') ?? '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appBarHome =
        AppBarWidget(screenName: styles.AppBarTypes.EINSTELLUNGEN);

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
                                style: TextStyle(
                                    fontSize: 16, color: textColorPrim))),
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
    Navigator.popAndPushNamed(context, '/');
  }
}
