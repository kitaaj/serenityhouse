import 'package:flutter/material.dart';
import 'package:mental_health_support/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content: 'We have sent you a apassword reset link.',
    optionsBuilder: ()=>{
      'OK': null,
    },
  );
}
