import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wattwatch/utils/styles_utils.dart';

import '../../utils/counter_utils.dart';
import '../../utils/geo_utils.dart';
import '../../utils/name_utils.dart';

class DialogueSequence extends StatefulWidget {
  String name;
  String counterNum;
  String street;
  String postal;
  final Function() onClose;
  DialogueSequence(
      this.name, this.counterNum, this.street, this.postal, this.onClose);

  @override
  _DialogueSequenceState createState() => _DialogueSequenceState(
      this.name, this.counterNum, this.street, this.postal);
}

class _DialogueSequenceState extends State<DialogueSequence> {
  int _currentScreenIndex = 0;

  String name;
  String counterNum;
  String street;
  String postal;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _counterNumController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  bool _isNameValid = false;
  bool _isCounterNumValid = false;
  bool _isStreetValid = false;
  bool _isPostalCodeValid = false;

  List<Widget> _screens = [];
  List<TextEditingController> _controllers = [];

  _DialogueSequenceState(this.name, this.counterNum, this.street, this.postal);
  @override
  void initState() {
    super.initState();
    _screens = [
      NameDialog(
        nameController: _nameController,
      ),
      CounterNumDialog(counterNumController: _counterNumController),
      LocationDialog(
        postalCodeController: _postalCodeController,
        streetController: _streetController,
      )
    ];
    _controllers = [
      _nameController,
      _counterNumController,
      _streetController,
      _postalCodeController
    ];

    _nameController.text = name;
    _counterNumController.text = counterNum;
    _streetController.text = street;
    _postalCodeController.text = postal;
  }

  void showToast() {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
            msg: 'Bitte das Feld richtig ausfüllen',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0)
        .then((value) => null);
  }

  void _showNextScreen(BuildContext context) {
    if (_controllers[_currentScreenIndex].value.text.trim().isEmpty) {
      showToast();
      return;
    }
    //Make sure 2nd field on 3rd screen is also filled out
    if (_currentScreenIndex == 2 && _controllers[3].value.text.trim().isEmpty) {
      showToast();
      return;
    }

    if (_currentScreenIndex < _screens.length - 1) {
      setState(() {
        _currentScreenIndex++;
      });
    } else {
      finish();
    }
  }

  void finish() async {
    widget.onClose();
    setName(_nameController.text);
    setCounterNum(_counterNumController.text);
    setPostalCode(_postalCodeController.text);
    setStreet(_streetController.text);
  }

  void showPrevScreen(BuildContext context) {
    setState(() {
      _currentScreenIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _screens[_currentScreenIndex],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('${_currentScreenIndex + 1}/${_screens.length}'),
              ),
              Row(
                children: [
                  if (!(_currentScreenIndex == 0))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ElevatedButton(
                        onPressed: () => showPrevScreen(context),
                        child: Text(
                          'Zurück',
                          style: TextStyle(color: textColorPrim),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () => _showNextScreen(context),
                      child: Text(
                        _currentScreenIndex == _screens.length - 1
                            ? 'Fertig'
                            : 'Weiter',
                        style: TextStyle(color: textColorPrim),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NameDialog extends StatefulWidget {
  final TextEditingController nameController;
  const NameDialog({Key? key, required this.nameController}) : super(key: key);

  @override
  _NameDialogState createState() => _NameDialogState();
}

class _NameDialogState extends State<NameDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vorname & Name'),
          createTextFormField(
              widget.nameController, 'Bitte Vorname & Name angeben')
        ],
      ),
    );
  }
}

class CounterNumDialog extends StatefulWidget {
  final TextEditingController counterNumController;
  const CounterNumDialog({Key? key, required this.counterNumController})
      : super(key: key);

  @override
  _CounterNumDialogState createState() => _CounterNumDialogState();
}

class _CounterNumDialogState extends State<CounterNumDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zählernummer'),
          createTextFormField(
              widget.counterNumController, 'Bitte Ihre Zählernummer angeben')
        ],
      ),
    );
  }
}

class LocationDialog extends StatefulWidget {
  final TextEditingController streetController;
  final TextEditingController postalCodeController;
  const LocationDialog(
      {Key? key,
      required this.streetController,
      required this.postalCodeController})
      : super(key: key);

  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Straße und Hausnummer'),
              SizedBox(
                width: 12,
              ),
              GestureDetector(
                  onTap: onGetLocation,
                  child: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: textColorPrim,
                          ),
                        )
                      : Icon(Icons.location_searching, color: textColorPrim))
            ],
          ),
          createTextFormField(
              widget.streetController, 'Bitte Ihre Adresse angeben'),
          Text('PLZ'),
          createTextFormField(
              widget.postalCodeController, 'Bitte Ihre PLZ angeben')
        ],
      ),
    );
  }

  void onGetLocation() {
    setState(() {
      isLoading = true;
    });
    setGeoPrefs().then((value) => {
          getStreet().then((street) =>
              setState(() => widget.streetController.text = street!)),
          getPostalCode().then((postalCode) =>
              setState(() => widget.postalCodeController.text = postalCode!)),
          setState(
            () => isLoading = false,
          )
        });
  }
}

TextFormField createTextFormField(
    TextEditingController controller, String hint) {
  return TextFormField(
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Bitte Feld ausfüllen';
      }
    },
    controller: controller,
    decoration: InputDecoration(
        hintText: hint,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xff252837)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 3, color: Color(0xff252837)),
        )),
  );
}
