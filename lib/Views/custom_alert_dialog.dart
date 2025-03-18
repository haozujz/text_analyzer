import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final Color textColor;
  final Color bgColor;
  final VoidCallback? onButtonPressed;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.textColor,
    required this.bgColor,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: TextStyle(color: textColor)),
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Text(message, style: TextStyle(color: textColor)),
      actions: [
        TextButton(
          onPressed: () {
            if (onButtonPressed != null) {
              onButtonPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
          style: TextButton.styleFrom(foregroundColor: textColor),
          child: Text(buttonText),
        ),
      ],
    );
  }
}

Future<void> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String buttonText,
  required Color textColor,
  required Color bgColor,
  VoidCallback? onButtonPressed,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        textColor: textColor,
        bgColor: bgColor,
      );
    },
  );
}
