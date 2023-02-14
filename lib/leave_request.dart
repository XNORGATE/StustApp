import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stust_app/home_work.dart';
import 'package:stust_app/Absent.dart';
import 'package:stust_app/Bulletins.dart';
import 'package:stust_app/Reflection.dart';
import 'package:stust_app/Send_homework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'main.dart';

class LeaveRequestPage extends StatefulWidget {
  static const routeName = '/leave_request';

  @override
  _LeaveRequestPageState createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  late String _week;
  late String _section;
  late String _reason;
  late String _day;
  late String _type;
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

      setState(() {
        _isLoading = true;
      });

      // Make POST request to the API
      http
          .get(
        Uri.parse(
            'http://api.xnor-development.com:70/leave_request?account=$_account&password=$_password&week=$_week&section=$_section&reason=$_reason&day=$_day&_type=$_type'),
      )
          .then((response) {
        if (_responseData != null) {
          // Access _responseData here

          // Parse response body into a list of maps
          final responseData = json.decode(response.body) as List;
          //print(responseData);
          setState(() {
            _responseData = responseData;
            _isLoading = false;
          });
          // Display alert dialog with response data
          _showAlertDialog();
          // Handle response from the API here
          // Display alert dialog to the user
        }
      });
    }
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('成功送出'),
          content: Text('你的請求已送出'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Content input
              TextFormField(
                onSaved: (value) => _day = value!,
                decoration: InputDecoration(labelText: '週數'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '請填入週數';
                  }
                  return null;
                },
              ),
              TextFormField(
                onSaved: (value) => _section = value!,
                decoration: InputDecoration(labelText: '節數'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '請填入節數';
                  }
                  return null;
                },
              ),
              // Reason input
              TextFormField(
                onSaved: (value) => _reason = value!,
                decoration: InputDecoration(labelText: '請假理由'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '請填入理由';
                  }
                  return null;
                },
              ),
              // Day input
              TextFormField(
                onSaved: (value) => _day = value!,
                decoration: InputDecoration(labelText: '周幾(禮拜幾)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '請填入周幾(禮拜幾)';
                  }
                  return null;
                },
              ),
              // Type input

              TextFormField(
                onSaved: (value) => _type = value!,
                decoration: InputDecoration(labelText: '假別 (4為事假，3為病假)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '請填入假別';
                  }
                  return null;
                },
              ),
              SizedBox(
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
        )
      ]),
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
        title: const Text('請假(e網通)'),
        actions: [
          IconButton(
              iconSize: 35,
              padding: EdgeInsets.only(right: 20),
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
