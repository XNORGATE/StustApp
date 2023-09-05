import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stust_app/login/login_page.dart';

import '../main.dart';

mixin AutoLogoutMixin<T extends StatefulWidget> on State<T> {
  final userController = Get.find<UserController>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (userController.username.value.isNotEmpty &&
        userController.password.value.isNotEmpty) {
      startTimer();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 10), () async {
      userController.username.value = '';
      userController.password.value = '';

      final prefs = await SharedPreferences.getInstance();
      prefs.remove('name');
      if (!mounted) return;
      // showDialogBox(context, 'app已閒置超過5分鐘，請重新登入');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('app已閒置超過10分鐘/暫存記憶已丟失，為保護您的資料安全，請重新登入'),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigator.of(context).pop();

                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //     '/login', (Route<dynamic> route) => false);
                  Get.offAll(const LoginPage());
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      // Navigator.of(context).pop();

      // Navigator.of(context)
      //     .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }
}
