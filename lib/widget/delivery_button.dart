import 'package:flutter/material.dart';

class DeliveryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count; // Add this parameter
  final VoidCallback onPressed;

  const DeliveryButton({
    super.key,
    required this.icon,
    required this.label,
    required this.count, // Add this parameter
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              onPressed: onPressed,
              icon: Icon(icon),
            ),
            if (count > 0)
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        Text(label),
      ],
    );
  }
}
