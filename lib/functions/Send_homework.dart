import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:stust_app/functions/home_work.dart';
import 'package:stust_app/functions/Absent.dart';
import 'package:stust_app/functions/Bulletins.dart';
import 'package:stust_app/functions/leave_request.dart';
import 'package:stust_app/functions/Reflection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class SendHomeworkPage extends StatefulWidget {
  static const routeName = '/send_homework';

  const SendHomeworkPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SendHomeworkPageState createState() => _SendHomeworkPageState();
}

class _SendHomeworkPageState extends State<SendHomeworkPage> {
  final _formKey = GlobalKey<FormState>();
  late String _content;
  late String _homeworkCode;
  late String _account = '0'; // Set account and password to 0 by default
  late String _password = '0';
  @override
  void initState() {
    super.initState();
    _responseData = [];
    _getlocal_UserData().then((data) {
      _account = data[0];
      _password = data[1];
      //print(_account);
      //print(_password);

      setState(() {});
    });
  }

  _getlocal_UserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('account') != null) {
      _account = prefs.getString('account')!;
    }
    if (prefs.getString('password') != null) {
      _password = prefs.getString('password')!;
    }

    return [_account, _password];
  }

  late List _responseData;
  late bool _isLoading = false; // Flag to indicate if API request is being made

  void _submitForm() {

      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        setState(() => _isLoading = true);

        // Make POST request to the API
        http
            .get(
          Uri.parse(
              'http://api.xnor-development.com:70/send_homework?account=$_account&password=$_password&content=$_content&homework_code=$_homeworkCode'),
        )
            .then((response) {
          final responseData = json.decode(response.body) as List;
          //print(responseData);
          setState(() {
            _responseData = responseData;
            _isLoading = false;
          });
          // Get the first item in the list (there should only be one item)
          final data = responseData[0];
          // Display alert dialog with response data
          _showAlertDialog(data['text'], data['href']);
        });
      
    }
  }

  void _showAlertDialog(String text, String href) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          content: Html(
            data: '<a href="$href">查看作業</a>',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Content input
                TextFormField(
                  onSaved: (value) {
                      _content = value!;
                  },
                  decoration: const InputDecoration(labelText: '作業內容'),
                  validator: (value) => value!.isEmpty ? '作業內容' : null,
                ),
                // Homework code input
                TextFormField(
                  onSaved: (value) {
                      _homeworkCode = value!;
                  },
                  decoration: const InputDecoration(labelText: '作業代碼，可於作業查詢中查到'),
                  validator: (value) =>
                      value!.isEmpty ? '作業代碼，可於作業查詢中查到' : null,
                ),
                const SizedBox(
                  height: 50,
                ),
                TextButton(
                  onPressed: _submitForm,
                  child: const Text(
                    '送出',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            child: _isLoading ? const CircularProgressIndicator() : Container(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: '最新作業',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: '最新公告',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '曠課與遲到',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          BottomNavigationBarItem(
              icon: Icon(Icons.question_answer),
              label: '未繳心得',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: '請假',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          BottomNavigationBarItem(
              icon: Icon(Icons.send),
              label: '快速繳交作業',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushNamed(HomeworkPage.routeName);
              break;
            case 1:
              Navigator.of(context).pushNamed(BulletinsPage.routeName);
              break;
            case 2:
              Navigator.of(context).pushNamed(AbsentPage.routeName);
              break;
            case 3:
              Navigator.of(context).pushNamed(ReflectionPage.routeName);
              break;
            case 4:
              Navigator.of(context).pushNamed(LeaveRequestPage.routeName);
              break;
            case 5:
              Navigator.of(context).pushNamed(SendHomeworkPage.routeName);
              break;
          }
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('快速繳交作業(flipclass)'),
        actions: [
          IconButton(
              iconSize: 35,
              padding: const EdgeInsets.only(right: 20),
              onPressed: () async {
                Navigator.pushNamedAndRemoveUntil(
                    context, MyHomePage.routeName, (route) => false);
              },
              icon: const Icon(IconData(0xe328, fontFamily: 'MaterialIcons')))
          // NeumorphicButton(
          //   child: Icon(Icons.exit_to_app_outlined),
          //   style: NeumorphicStyle(
          //       shape: NeumorphicShape.concave,
          //       boxShape:
          //           NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
          //       depth: 3,
          //       color: Color.fromARGB(255, 212, 69, 76)),
          //   drawSurfaceAboveChild: false,
          //   margin: EdgeInsets.fromLTRB(0.0, 10.0, 15.0, 10.0),
          //   //padding: EdgeInsets.only(bottom: 1),

          // ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
