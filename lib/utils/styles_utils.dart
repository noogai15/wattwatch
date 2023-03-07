import 'package:flutter/material.dart';

const appBarText = TextStyle(
    color: Colors.white, fontSize: 20, fontFamily: 'Avenir', letterSpacing: 4);

TextField settingsTextField(String label, TextEditingController controller) {
  return TextField(
    style: TextStyle(color: Colors.white),
    controller: controller,
    decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 3)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 3)),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70)),
  );
}

enum AppBarTypes { HOME, SETTINGS }
