import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/shared_preferences_notifier.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConfirmationButton(),
        ),
      )
    );
  }
}

class ConfirmationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showConfirmationDialog(context),
      child: Text('Reset User Data', style: TextStyle(color: Colors.black)),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('All user data will be lost. This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog but do nothing else
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                _resetData(); // Perform your action here
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetData() async {
    SharedPreferencesNotifier().resetAllData();
  }
}
