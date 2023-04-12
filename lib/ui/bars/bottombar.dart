import 'package:flutter/material.dart';

import '../screens/camera.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomBarWidget(),
    );
  }
}

class BottomBarWidget extends StatelessWidget {
  const BottomBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xff252837),
      child: Ink(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: OutlinedButton(
          onPressed: () => onPressed(context),
          child: Icon(
            Icons.bolt,
            size: 46,
            color: Colors.amber[600],
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(40),
            shape: CircleBorder(),
            side: BorderSide(color: Color(0xff252837), width: 4),
          ),
        ),
      ),
    );
  }

  void onPressed(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CameraWidget()));
  }
}
