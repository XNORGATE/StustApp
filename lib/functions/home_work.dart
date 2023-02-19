import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stust_app/functions/Absent.dart';
import 'package:stust_app/functions/Bulletins.dart';
import 'package:stust_app/functions/leave_request.dart';
import 'package:stust_app/functions/Reflection.dart';
import 'package:stust_app/functions/Send_homework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stust_app/rwd_module/responsive.dart';

import '../main.dart';

class HomeworkPage extends StatefulWidget {
  static const routeName = '/homework';

  const HomeworkPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _HomeworkPageState createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    _account = prefs.getString('account')!;
    _password = prefs.getString('password')!;

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
            'http://api.xnor-development.com:70/homework?account=$_account&password=$_password'),
      )
          .then((response) {
        final responseData = json.decode(response.body) as List;
        //print(responseData);
        setState(() {
          _responseData = responseData;
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                TextButton(
                  onPressed: _submitForm,
                  child: const Text(
                    '查詢',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                if (_responseData != null) // Add this check here
                  Expanded(
                    child: ListView.builder(
                      itemCount: _responseData.length,
                      itemBuilder: (context, index) {
                        final data = _responseData[index];
                        return Column(
                          children: [
                            TextFormField(
                              initialValue: data['date'],
                              decoration: const InputDecoration(
                                labelText: '日期',
                              ),
                            ),
                            TextFormField(
                              initialValue: data['href'],
                              decoration: const InputDecoration(
                                labelText: '作業連結',
                              ),
                            ),
                            TextFormField(
                              initialValue: data['src'],
                              decoration: const InputDecoration(
                                labelText: '課程名稱',
                              ),
                            ),
                            TextFormField(
                              initialValue: data['topic'],
                              decoration: const InputDecoration(
                                labelText: '作業名稱',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        showSelectedLabels: false,
        showUnselectedLabels: isMobile(context)? false:true,
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
        title: const Text('查詢最近作業(flipclass)'),
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
