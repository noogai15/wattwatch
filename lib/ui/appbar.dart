import 'package:flutter/material.dart';
import 'package:wattwatch/utils/styles_utils.dart' as styles;

import 'settings.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final styles.AppBarTypes screenName;
  const AppBarWidget({super.key, required this.screenName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Color(0xff252837),
        centerTitle: true,
        leading: this.screenName == styles.AppBarTypes.SETTINGS
            ? null
            : IconButton(
                iconSize: 28,
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () {
                  onSettingsPressed(context);
                },
              ),
        title: Column(
          children: [
            Text('WATTWATCH', style: styles.appBarText),
            Text(this.screenName.name, style: styles.appBarText)
          ],
        ));
  }

  void onSettingsPressed(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(70);
}
