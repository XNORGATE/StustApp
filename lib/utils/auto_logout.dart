import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _timer = Timer(const Duration(minutes: 1), () async {
      userController.username.value = '';
      userController.password.value = '';
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('name');
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }
}
