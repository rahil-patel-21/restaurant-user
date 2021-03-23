import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';

void showToast(message, Color color) {
  print(message);
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0);
}

void VerificationCompletedDialog(context, tlt, msg, btn){
  AwesomeDialog(
    context: context,
    headerAnimationLoop: false,
    dialogType: DialogType.SUCCES,
    title: tlt,
    desc: msg,
    dismissOnTouchOutside: false,
    btnOkText: btn,
    btnOkOnPress: () {
      Navigator.of(context).pushReplacementNamed('/PhoneConfirmed');
    },
    btnOkIcon: Icons.arrow_forward,
  )..show();
}

void errorDialog(context, title, message){
  AwesomeDialog(
    context: context,
    headerAnimationLoop: false,
    dialogType: DialogType.ERROR,
    title: title,
    desc: message,
    btnOkColor: Colors.red,
    btnOkText: "OK",
    btnOkOnPress: () {
    },
  )..show();
}

void warningDialog(context, title, message, btnok, btncancel){
  AwesomeDialog(
    context: context,
    headerAnimationLoop: false,
    dialogType: DialogType.WARNING,
    title: title,
    desc: message,
    dismissOnTouchOutside: false,
    btnCancelOnPress: () {Navigator.of(context).pushReplacementNamed('/SignUp');},
    btnOkText: btnok,
    btnOkOnPress: () {},
    btnCancelText: btncancel,
    btnCancelIcon: Icons.phonelink_setup,
  )..show();
}