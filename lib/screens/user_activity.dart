///Build a screen to display user activity
/// have a back button allow back to TabsScreen
import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: const Center(
        child: Text('Go back!'),
      ),
    );
  }
}
