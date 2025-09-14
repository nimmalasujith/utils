import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';


Future<void> showMessage(String message) async {
  if (kDebugMode) {
    // Only prints in debug mode
    print("showMessage: $message");
  }

  await Fluttertoast.cancel();
  await Fluttertoast.showToast(
    msg: message,
    fontSize: 18,
    timeInSecForIosWeb: 5,
  );
}