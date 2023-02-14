import 'package:flutter/material.dart';
import 'package:stust_app/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Check if there's an account and password in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('account') || !prefs.containsKey('password')) {
        // If not, show the login page
        Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  late String _account;
  late String _password;
  bool _isLoading = false;

  Future<bool> authenticate(String account, String password) async {
    if (account == null || password == null) {
      return false;
    }

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
      'csrf-t': hiddenInput != null ? hiddenInput : "error"
    };

    // Send the login POST request
    final res = await session.post(
        Uri.parse('https://flipclass.stust.edu.tw/index/login'),
        body: payload);

    Map<String, dynamic> responseMap = jsonDecode(res.body);
    String status = responseMap['ret']['status'];
    if (status == "true") {
      return true;
    }
    return false; // do something else
  }

  void _showAlertDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AlertDialog(
              title: Text(text),
              content: Text('Authenticate error(帳號密碼錯誤)'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('了解'),
                ),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('南台通Beta v1.0'),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: '帳號'),
                  onSaved: (value) => _account = value!,
                  validator: (value) => value!.isEmpty ? '請填入帳號' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '密碼'),
                  onSaved: (value) => _password = value!,
                  validator: (value) => value!.isEmpty ? '請填入密碼' : null,
                  obscureText: true,
                ),
                SizedBox(
                  height: 45,
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() => _isLoading = true);
                      bool isAuthenticated =
                          await authenticate(_account, _password);
                      if (isAuthenticated) {
                        await SharedPreferences.getInstance().then((prefs) {
                          prefs.setString('account', _account);
                          prefs.setString('password', _password);
                        });
                        Navigator.of(context).pushNamed('/');
// Save account and password in shared preferences
// Go to main page
                      } else {
                        _showAlertDialog('錯誤提示');
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          '登入',
                          style: TextStyle(fontSize: 30),
                        ),
                ),
              ],
            ),
          ),
        ));
  }
}
