import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final IconData icon;
  final IconData trailingIcon;
  final String label;
  final VoidCallback onPressed;

  const ButtonWidget(
      {required this.icon,
      required this.trailingIcon,
      required this.label,
      required this.onPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 60.0,
          color: Theme.of(context).colorScheme.background,
          margin: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon),
                    const SizedBox(width: 8.0),
                    Text(
                      label,
                      style: const TextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Icon(trailingIcon),
            ],
          ),
        ),
      ),
    );
  }
}
