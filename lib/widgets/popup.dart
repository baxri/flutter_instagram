import 'package:flutter/material.dart';

class Alert {
  static alert(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'))
              ],
            ));
  }
}
