import 'package:flutter/material.dart';

class DeliveryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed; // Define the onPressed callback here

  const DeliveryButton({
    required this.icon,
    required this.label,
    required this.onPressed, // Pass the callback to the constructor
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
      ),
      margin: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: onPressed, // Use the onPressed callback here
          ),
          Flexible(
            // Wrap the Text widget with GestureDetector
            child: GestureDetector(
              onTap: onPressed, // Use the onPressed callback here
              child: Text(
                label,
                style: const TextStyle(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
