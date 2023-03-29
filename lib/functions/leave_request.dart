import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import 'package:convert/convert.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class LeaveRequestPage extends StatefulWidget {
  static const routeName = '/leave_request';

  const LeaveRequestPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LeaveRequestPageState createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _account = '0'; // Set account and password to 0 by default
  late String _password = '0';

  @override
  void initState() {
    super.initState();
    List<Map<String, String?>> responseData = [];
    _getlocal_UserData().then((data) {
      _account = data[0];
      _password = data[1];

      setState(() {});
    });

    // _submitForm();
  }

  _getlocal_UserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _account = prefs.getString('account')!;
    _password = prefs.getString('password')!;

    // Call _submitForm() method after retrieving and setting the values
    _submitForm();

    return [_account, _password];
  }

  late List<Map<String, String>> _responseData = [];
  late bool _isLoading = false; // Flag to indicate if API request is being made

  void _showAlertDialog(String text, String href) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          content: Text(href),
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

  Future<List<Map<String, String>>> getAbsent() async {
    List<Map<String, String>> absentEvent = [];

    var session = http.Client();
    // print(_account);
    // print(_password);
    final queryParameters = {
      'stud_no': _account,
      'passwd': _password,
      'b1': '登入Login'
    };
    // print(_account);
    final uri = Uri.https(
        'portal.stust.edu.tw', '/abs_stu/verify.asp', queryParameters);
    //authenticate
    var response = await session.post(uri);
    String cookies = '${response.headers['set-cookie']!}; 3wave=1';

// // Determine the encoding of the response body from the Content-Type header
// // final responseText = utf8.decode(response.bodyBytes);
//     var responseBodyHex = hex.encode(response.bodyBytes);

//     var soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

// // print(utf8.decode(soup));
// // soup = html_parser.parse(utf8.encode(response.body));

    // wrong acc or pwd
    // if (soup.querySelector("body > div > p:nth-child(2) > font") != null) {
    //   throw Exception(soup
    //       .querySelector("body > div > p:nth-child(2) > font")
    //       ?.text
    //       .trim());
    // }

    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
    };
    response = await session.get(
        Uri.parse('https://portal.stust.edu.tw/abs_stu/query/week.asp'),
        headers: {...headers, 'cookie': cookies});
    // print(utf8.decode(response.bodyBytes));
    var responseBodyHex = hex.encode(response.bodyBytes);
    var soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
    // print(utf8.decode(hex.decode(responseBodyHex)));
    // final absent_event = <Map<String, dynamic>>[];

    final res = soup.querySelectorAll("font.c10");
//  print(res);
    for (final font in res) {
      if (font.text.trim() == '遲到Late' || font.text.trim() == '缺課Absence') {
        final reason = font.text.trim();

        final td = font.parent;
        final lesson = td?.previousElementSibling;
        final lessonText = lesson!.querySelector('font')!.text.trim();
        final section = lesson.previousElementSibling;
        final sectionText = section!.querySelector('font')!.text.trim();
        final date = section.previousElementSibling;
        final dateText = date!.querySelector('font')!.text.trim();
        final week = date.previousElementSibling;
        final weekText = week!.querySelector('font')!.text.trim();

        absentEvent.add({
          'week': weekText,
          'date': dateText,
          'section': sectionText,
          'lesson': lessonText,
          'reason': reason
        });
      }
    }

    return absentEvent;
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final responseData = await getAbsent();
      setState(() {
        Map<String, String> newItem = {
          'week': '周次',
          'date': '日期',
          'section': '節數',
          'lesson': '課程',
          'reason': '曠課/遲到'
        };
        responseData.insert(0, newItem);
        _responseData = responseData;
        print(responseData);

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showAlertDialog(e.toString(), e.toString());
      });
    }
    // }
  }
  
  ///

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
                // TextButton(
                //   onPressed: _submitForm,
                //   child: const Text(
                //     '查詢',
                //     style: TextStyle(fontSize: 30),
                //   ),
                // ),
                if (_responseData != null)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        children: _responseData.map((data) {
                          return TableRow(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 3,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['date']!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['week'].toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['section'].toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: GestureDetector(
                                  onTap: () {
                                    // Do something when the row is clicked
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['lesson']!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              if (_responseData.indexOf(data) == 0)
                                TableCell(
                                  child: IconButton(
                                    icon: const Icon(  Icons.minimize,color: Colors.black,
                                        size: 30),
                                    onPressed: () {
                                      // ...
                                    },
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      // final _formKey = GlobalKey<FormState>();
      // late String _week;
      // late String _section;
      // late String _reason;
      // late String _day;
      // late String _type;
      // late String _account = '0'; // Set account and password to 0 by default
      // late String _password = '0';

      // @override
      // void initState() {
      //   super.initState();
      //   _responseData = [];
      //   _getlocal_UserData().then((data) {
      //     _account = data[0];
      //     _password = data[1];
      //     //print(_account);
      //     //print(_password);

      //     setState(() {});
      //   });
      // }

      // _getlocal_UserData() async {
      //   SharedPreferences prefs = await SharedPreferences.getInstance();
      //   if (prefs.getString('account') != null) {
      //     _account = prefs.getString('account')!;
      //   }
      //   if (prefs.getString('password') != null) {
      //     _password = prefs.getString('password')!;
      //   }

      //   return [_account, _password];
      // }

      // late List _responseData;
      // late bool _isLoading = false; // Flag to indicate if API request is being made

      // void _submitForm() {
      //   if (_formKey.currentState!.validate()) {
      //     _formKey.currentState!.save();

      //     setState(() {
      //       _isLoading = true;
      //     });

      //     // Make POST request to the API
      //     http
      //         .get(
      //       Uri.parse(
      //           'http://api.xnor-development.com:70/leave_request?account=$_account&password=$_password&week=$_week&section=$_section&reason=$_reason&day=$_day&_type=$_type'),
      //     )
      //         .then((response) {
      //       final responseData = json.decode(response.body) as List;
      //       //print(responseData);
      //       setState(() {
      //         _responseData = responseData;
      //         _isLoading = false;
      //       });
      //       // Display alert dialog with response data
      //       _showAlertDialog();
      //     });
      //   }
      // }

      // void _showAlertDialog() {
      //   showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: const Text('成功送出'),
      //         content: const Text('你的請求已送出'),
      //         actions: [
      //           TextButton(
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //             child: const Text('OK'),
      //           ),
      //         ],
      //       );
      //     },
      //   );
      // }

      // @override
      // Widget build(BuildContext context) {
      //   return Scaffold(
      //     body: Stack(children: [
      //       Form(
      //         key: _formKey,
      //         child: Column(
      //           children: [
      //             // Content input
      //             TextFormField(
      //               onSaved: (value) => _day = value!,
      //               decoration: const InputDecoration(labelText: '週數'),
      //               validator: (value) {
      //                 if (value!.isEmpty) {
      //                   return '請填入週數';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             TextFormField(
      //               onSaved: (value) => _section = value!,
      //               decoration: const InputDecoration(labelText: '節數'),
      //               validator: (value) {
      //                 if (value!.isEmpty) {
      //                   return '請填入節數';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             // Reason input
      //             TextFormField(
      //               onSaved: (value) => _reason = value!,
      //               decoration: const InputDecoration(labelText: '請假理由'),
      //               validator: (value) {
      //                 if (value!.isEmpty) {
      //                   return '請填入理由';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             // Day input
      //             TextFormField(
      //               onSaved: (value) => _day = value!,
      //               decoration: const InputDecoration(labelText: '周幾(禮拜幾)'),
      //               validator: (value) {
      //                 if (value!.isEmpty) {
      //                   return '請填入周幾(禮拜幾)';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             // Type input

      //             TextFormField(
      //               onSaved: (value) => _type = value!,
      //               decoration: const InputDecoration(labelText: '假別 (4為事假，3為病假)'),
      //               validator: (value) {
      //                 if (value!.isEmpty) {
      //                   return '請填入假別';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             const SizedBox(
      //               height: 50,
      //             ),
      //             TextButton(
      //               onPressed: _submitForm,
      //               child: const Text(
      //                 '送出',
      //                 style: TextStyle(fontSize: 30),
      //               ),
      //             ),
      //           ],
      //         ),
      //       )
      //     ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: '缺曠紀錄',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: '請假',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushNamed('/absent');
              break;
            case 1:
              Navigator.of(context).pushNamed('/leave_request');
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
