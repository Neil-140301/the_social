import 'package:flutter/material.dart';

void displayMessage(BuildContext ctx, String message) {
  showDialog(
    context: ctx,
    builder: ((context) => AlertDialog(
          title: Text(message),
        )),
  );
}
