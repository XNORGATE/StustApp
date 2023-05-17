import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';

Future<bool> checkNetwork() async {
  bool isConnected = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      isConnected = true;
    }
  } on SocketException catch (_) {
    isConnected = false;
  }
  return isConnected;
}

// void ensureConnection(context) async {
//   if (await checkNetwork() == false) {
//     print(await checkNetwork());

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text('偵測不到網路連線，請檢查網路連線後再試一次'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 // Navigator.of(context).pop();
//                 // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//                 FlutterExitApp.exitApp();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );

//     // showDialogBox(context, '偵測不到網路連線，請檢查網路連線後再試一次');
//   }
// }
