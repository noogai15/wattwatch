import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DialogueSequence extends StatefulWidget {
  String name;
  String counterNum;
  String street;
  String postal;
  DialogueSequence(this.name, this.counterNum, this.street, this.postal);

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
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  bool _isNameValid = false;
  bool _isCounterNumValid = false;
  bool _isAddressValid = false;
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
        addressController: _addressController,
      )
    ];
    _controllers = [
      _nameController,
      _counterNumController,
      _addressController,
      _postalCodeController
    ];

    _nameController.text = name;
    _counterNumController.text = counterNum;
    _addressController.text = street;
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

  void finish() {
    Navigator.of(context).pop();
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
              Text('${_currentScreenIndex + 1}/${_screens.length}'),
              if (!(_currentScreenIndex == 0))
                ElevatedButton(
                  onPressed: () => showPrevScreen(context),
                  child: Text('Back'),
                ),
              ElevatedButton(
                onPressed: () => _showNextScreen(context),
                child: Text(_currentScreenIndex == _screens.length - 1
                    ? 'Finish'
                    : 'Next'),
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
              widget.nameController, 'Bitte Vornamen und Namen angeben')
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
  final TextEditingController addressController;
  final TextEditingController postalCodeController;
  const LocationDialog(
      {Key? key,
      required this.addressController,
      required this.postalCodeController})
      : super(key: key);

  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Straße und Hausnummer'),
          createTextFormField(
              widget.addressController, 'Bitte Ihre Adresse angeben'),
          Text('PLZ'),
          createTextFormField(
              widget.postalCodeController, 'Bitte Ihre PLZ angeben')
        ],
      ),
    );
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
    decoration: InputDecoration(hintText: hint),
  );
}
