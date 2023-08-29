import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../utils/check_connecion.dart';
import './my_button.dart';
import './my_textfield.dart';
import '../utils/dialog_utils.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    WidgetsBinding.instance.addObserver(this);
    checkNetwork().then((isConnected) {
      if (isConnected == false) {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text('偵測不到網路連線，請檢查網路連線後再試一次'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Navigator.of(context).pop();
                    // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    FlutterExitApp.exitApp();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    usernameController.dispose(); // 釋放控制器
    passwordController.dispose(); // 釋放控制器
    super.dispose();
  }

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.resumed) {
  //     // Check if there's an account and password in SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     if (!prefs.containsKey('account') || !prefs.containsKey('password')) {
  //       // If not, show the login page
  //       if (!mounted) return;
  //       Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
  //     }
  //   }
  // }

  // final formKey = GlobalKey<FormState>();
  late String _account;
  late String _password;
  String _name = '';
  Future<dynamic> authenticate(String account, String password) async {
    if (password == null) {
      return false;
    }

    try {
      final acc = account;
      final pwd = password;

      // Create an HTTP session
      final session = http.Client();

      // Send a GET request to the login page
      final r = await session
          .get(Uri.parse('https://flipclass.stust.edu.tw/index/login'));

      // Parse the response HTML
      final soup = parse(r.body);

      // Find the value of the csrf-t hidden input
      final hiddenInput =
          soup.querySelector('input[name="csrf-t"]')?.attributes['value'];

      // Set up the payload for the login POST request
      Map<String, String> payload = {
        '_fmSubmit': 'yes',
        'formVer': '3.0',
        'formId': 'login_form',
        'next': '/',
        'act': 'keep',
        'account': acc,
        'password': pwd,
        'rememberMe': '',
        'csrf-t': hiddenInput ?? "error"
      };

      var headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
      };

      // Send the login POST request
      final res = await session.post(
          Uri.parse('https://flipclass.stust.edu.tw/index/login'),
          body: payload);

      String cookies = res.headers['set-cookie']!;

      final nameRequest = await session.get(
          Uri.parse('https://flipclass.stust.edu.tw/dashboard'),
          headers: {...headers, 'cookie': cookies});

      // Parse the response HTML
      final nameSoup = parse(nameRequest.body);

      // Find the value of the csrf-t hidden input
      final name =
          nameSoup.querySelector('div.fs-text-center > span')?.text.trim();
      // print(name);
      Map<String, dynamic> responseMap = jsonDecode(res.body);
      String status = responseMap['ret']['status'];

      if (status == "true") {
        _name = name!;
        return name;
      }
    } catch (e) {}
    return false; // do something else
  }

  void _showAlertDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text(text),
              content: const Text('Authenticate error(帳號或密碼錯誤)'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('了解'),
                ),
              ],
            ));
      },
    );
  }

  Future<bool> checkBan(name) async {
    try {
      final session = http.Client();

      final response = await session.post(
        Uri.parse('http://api.xnor-development.com:70/stust_checkban'),
        headers: {'Content-Type': 'application/json'},
        body: {
          'name': name,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        final bool isBanned = responseMap['banned'];
        if (isBanned) {
          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      if (e is SocketException) {
        return false;
      }
    }
    return false;
  }

  @override

//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Scaffold(
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             centerTitle: true,
//             title: const Text('南台通Beta v1.0'),
//           ),
//           body: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 TextFormField(
//                   decoration: const InputDecoration(labelText: '帳號'),
//                   onSaved: (value) => _account = value!,
//                   validator: (value) => value!.isEmpty ? '請填入帳號' : null,
//                 ),
//                 TextFormField(
//                   decoration: const InputDecoration(labelText: '密碼'),
//                   onSaved: (value) => _password = value!,
//                   validator: (value) => value!.isEmpty ? '請填入密碼' : null,
//                   obscureText: true,
//                 ),
//                 const SizedBox(
//                   height: 45,
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     if (_formKey.currentState!.validate()) {
//                       _formKey.currentState!.save();
//                       setState(() => _isLoading = true);
//                       bool isAuthenticated =
//                           await authenticate(_account, _password);
//                       if (isAuthenticated) {
//                         await SharedPreferences.getInstance().then((prefs) {
//                           prefs.setString('account', _account);
//                           prefs.setString('password', _password);
//                         });
//                         Navigator.of(context).pushNamed('/');
// // Save account and password in shared preferences
// // Go to main page
//                       } else {
//                         _showAlertDialog('錯誤提示');
//                         setState(() {
//                           _isLoading = false;
//                         });
//                       }
//                     }
//                   },
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 24,
//                           width: 24,
//                           child: CircularProgressIndicator(),
//                         )
//                       : const Text(
//                           '登入',
//                           style: TextStyle(fontSize: 30),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
  // ScrollController ListViewController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(181, 65, 218, 190),
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: const Text('南台通Beta v1.0'),
              ),
              backgroundColor: Colors.grey[300],
              body: SafeArea(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: SingleChildScrollView(
                            // controller: ListViewController,
                            child: AutofillGroup(
                              onDisposeAction :AutofillContextAction.commit,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 5),

                              // logo
                              const Icon(
                                Icons.lock,
                                size: 100,
                              ),

                              const SizedBox(height: 20),

                              // welcome back, you've been missed!
                              Text(
                                '南臺通登入系統',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 20,
                                ),
                              ),

                              const SizedBox(height: 25),
                              MyTextField(
                                controller: usernameController,
                                hintText: '學號(大小寫皆可)',
                                obscureText: false,
                                autofillHints: const [
                                  AutofillHints.username,],
                              ),

                              const SizedBox(height: 10),

                              MyTextField(
                                controller: passwordController,
                                hintText: '密碼',
                                obscureText: true,
                                autofillHints: const [
                                  AutofillHints.password,],
                              ),

                              const SizedBox(height: 10),

                              const SizedBox(height: 25),

                              // sign in button

                              MyButton(
                                onTap: () async {
                                  _account = usernameController.text;
                                  _password = passwordController.text;
                                  // if (_formKey.currentState!.validate()) {
                                  //   _formKey.currentState!.save();
                                  var isAuthenticated =
                                      await authenticate(_account, _password);

                                  // print(isAuthenticated);
                                  if (isAuthenticated != false) {
                                    if (!mounted) return;
                                    try {
                                      final userController =
                                          Get.find<UserController>();

                                      await checkBan(isAuthenticated)
                                          ? showDialogBox(
                                              context, '您已被開發者停權，請聯絡開發者')
                                          : userController.username.value =
                                              _account;
                                      userController.password.value = _password;

                                      await SharedPreferences.getInstance()
                                          .then((prefs) {
                                        // prefs.setString(
                                        //     'account', _account);
                                        // prefs.setString(
                                        //     'password', _password);
                                        prefs.setString(
                                            'name', isAuthenticated);
                                      });

                                      // TextInput.finishAutofillContext();
                                      if (!mounted) return;
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil('/',
                                              (Route<dynamic> route) => false);
                                      showDialogBox(
                                          context, '歡迎回來，$isAuthenticated同學');
                                    } catch (e) {}

// Save account and password in shared preferences
// Go to main page
                                  } else {
                                    _showAlertDialog('錯誤提示');
                                  }
                                  // }
                                },
                              ),

                              const SizedBox(height: 50),

                              // not a member? register now
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '是新生?',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () => showDialogBox(context,
                                            '新生請前往南臺校網註冊\n可登入FlipClass及選課系統之帳號'),
                                        child: const Text(
                                          '前往校網註冊',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '擔心帳號安全?',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () => showDialogBox(context,
                                            '此App基於所有南台校網開發，\n不會將您的密碼以任何方式/形式儲存在您手機以外的地方\n請放心使用，本APP也樂意接受任何第三方形式的檢測 (如: 網路封包檢測 / 程式碼檢測) \n在正常使用下是完全安全的 如您仍有疑慮，請勿使用本APP，在操作中若因任何原因造成您的損失，本APP概不負責'),
                                        child: const Text(
                                          '原理及責任說明',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                      ),
              ),
            )));
  }
}
