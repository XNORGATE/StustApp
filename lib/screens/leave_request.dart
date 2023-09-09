import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../utils/auto_logout.dart';
import '../utils/check_connecion.dart';

class AbsentPage extends StatefulWidget {
  static const routeName = '/absent';

  const AbsentPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AbsentPageState createState() => _AbsentPageState();
}

class _AbsentPageState extends State<AbsentPage>
    with AutoLogoutMixin<AbsentPage> {
  // final _formKey = GlobalKey<FormState>();
  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _account = '0'; // Set account and password to 0 by default
  late String _password = '0';
  late List _responseData = [];

  @override
  void initState() {
    super.initState();
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
                  onPressed: () async {
                    // Navigator.of(context).pop();
                    // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    final prefs = await SharedPreferences.getInstance();
                    userController.username.value = '';
                    userController.password.value = '';
                    prefs.remove('name');
                    FlutterExitApp.exitApp();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      _responseData = [];
      _getlocal_UserData().then((data) {
        //print(_account);
        //print(_password);

        setState(() {
          _account = data[0];
          _password = data[1];
        });
      });
    });
  }

  @override
  void dispose() {
    http.Client().close();
    super.dispose();
  }

  void _showAlertDialog(dynamic soup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: HtmlWidget(soup.outerHtml),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('關閉'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // void _showDialog(String text) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(text),
  //         // content: Text(href),
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

  _getlocal_UserData() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    final userController = Get.find<UserController>();

    _account = userController.username.value;
    _password = userController.password.value;

    // Call _submitForm() method after retrieving and setting the values
    _submitForm();

    return [_account, _password];
  }

  // late List _responseData;
  late bool _isLoading = false; // Flag to indicate if API request is being made

  Future<List<Map<String, String?>>> getLeaveRequest() async {
    // List<Map<String, String>> absentEvent = [];
    List<Map<String, String?>> LeaveRequest = [];

    // var session = http.Client();
    Dio dio = Dio();
    // print(_account);
    // print(_password);
    final queryParameters = {
      'stud_no': _account,
      'passwd': _password,
      'b1': '登入Login'
    };
    // print(_account);
    // final uri = Uri.https(
    //     'portal.stust.edu.tw', '/abs_stu/verify.asp', queryParameters);
    //authenticate
    try {
      var response = await dio.post(
          'https://portal.stust.edu.tw/abs_stu/verify.asp',
          queryParameters: queryParameters);
      String cookies = '${response.headers['set-cookie']!}; 3wave=1';

      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
      };

      response = await dio.get(
          ('https://portal.stust.edu.tw/abs_stu/query/query.asp'),
          options: Options(
              headers: {...headers, 'cookie': cookies},
              responseType: ResponseType.bytes));
      var responseBodyHex = hex.encode(response.data);
      var soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

      var trElement = soup.querySelectorAll(
          'tr[align="center"][bgcolor="#FFFF99"]'); // every row
      for (var i = 0; i < trElement.length; i++) {
        var tdElement = trElement[i].querySelectorAll('td');
        var aElement = trElement[i].querySelector('a');

        var href = aElement!.attributes['href']; //假單連結

        var leaveType = tdElement[0].text; //假別
        var week = trElement[i].querySelector('a')!.text; // 週次-序號
        var date = tdElement[2].text; // 登錄時間
        var teacher = tdElement[3].text; // 導師/指導老師
        var instructor = tdElement[4].text; // 課程老師
        var chairman = tdElement[5].text; // 系主任/組長
        var chief = tdElement[6].text; // 生輔組組長
        var dean = tdElement[7].text; // 學務處處長
        var guidance = tdElement[8].text; // 退件說明
        var status = tdElement[9].text; // 簽核狀態

        LeaveRequest.add({
          'leaveType': leaveType,
          'week': week,
          'date': date,
          'teacher': teacher,
          'instructor': instructor,
          'chairman': chairman,
          'chief': chief,
          'dean': dean,
          'guidance': guidance,
          'status': status,
          'href': href
        });
      }
      // print(ExistLeaveRequest);
      // print(absentEvent);

      return LeaveRequest;
    } catch (e) {
      return [];
    }
    return LeaveRequest;
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final responseData = await getLeaveRequest();
      setState(() {
        Map<String, String> newItem = {
          'leaveType': '假別',
          'week': '週次-序號',
          'date': '登錄時間',
          'teacher': '導師/指導老師',
          'instructor': '課程老師',
          'chairman': '系主任/組長',
          'chief': '生輔組組長',
          'dean': '學務處處長',
          'guidance': '退件說明',
          'status': '簽核狀態',
          'href': 'https://portal.stust.edu.tw/abs_stu//query/query.asp'
        };

        responseData.insert(0, newItem);
        _responseData = responseData;
        // print(responseData);

        _isLoading = false;
      });
    } catch (e) {
      // setState(() {
      //   _isLoading = false;
      //   showDialogBox(context, e.toString());
      // });
    }
    // }
  }

  Color statusColor = const Color.fromARGB(255, 11, 111, 14);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      body: Stack(
        children: [
          Column(
            children: [
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
                        if (data['status'].contains('處理中') == true) {
                          statusColor = Colors.red;
                        } else {
                          statusColor = Colors.green;
                        }
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
                                padding:
                                    const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                child: Text(
                                  data['leaveType']!,
                                  style: _responseData.indexOf(data) == 0
                                      ? const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)
                                      : const TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            TableCell(
                              child: InkWell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                  child: Text(
                                    data['week']!,
                                    style: _responseData.indexOf(data) == 0
                                        ? const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)
                                        : const TextStyle(
                                            color: Colors.blue, fontSize: 11),
                                  ),
                                ),
                                onTap: () async {
                                  if (data['week'].contains('週次') != true) {
                                    print(data['href']);
                                    // var session = http.Client();
                                    Dio dio = Dio();
                                    // print(_account);
                                    // print(_password);
                                    final queryParameters = {
                                      'stud_no': _account,
                                      'passwd': _password,
                                      'b1': '登入Login'
                                    };
                                    // print(_account);
                                    // final uri = Uri.https('portal.stust.edu.tw',
                                    //     '/abs_stu/verify.asp', queryParameters);
                                    //authenticate
                                    try {
                                      var response = await dio.post(
                                          'https://portal.stust.edu.tw/abs_stu/verify.asp',
                                          queryParameters: queryParameters);
                                      String cookies =
                                          '${response.headers['set-cookie']!}; 3wave=1';

                                      final headers = {
                                        'User-Agent':
                                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
                                      };
                                      final link = data['href'];
                                      response = await dio.get(
                                          ('https://portal.stust.edu.tw/abs_stu//query/$link'),
                                          options: Options(headers: {
                                            ...headers,
                                            'cookie': cookies
                                          }, responseType: ResponseType.bytes));
                                      var responseBodyHex =
                                          hex.encode(response.data);
                                      var soup = html_parser.parse(utf8
                                          .decode(hex.decode(responseBodyHex)));
                                      _showAlertDialog(soup);
                                    } catch (e) {}
                                  }
                                },
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                child: Text(
                                  data['date'].toString(),
                                  style: _responseData.indexOf(data) == 0
                                      ? const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)
                                      : const TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                            TableCell(
                              child: InkWell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                  child: Text(
                                    data['teacher']!,
                                    style: _responseData.indexOf(data) == 0
                                        ? const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)
                                        : const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: InkWell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                  child: Text(
                                    data['instructor']!,
                                    style: _responseData.indexOf(data) == 0
                                        ? const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)
                                        : const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                            // if (_responseData.indexOf(data) == 0)
                            TableCell(
                              child: InkWell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                  child: Text(
                                    data['chairman']!,
                                    style: _responseData.indexOf(data) == 0
                                        ? const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)
                                        : const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: InkWell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                  child: Text(
                                    data['chief']!,
                                    style: _responseData.indexOf(data) == 0
                                        ? const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)
                                        : const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: InkWell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                  child: Text(
                                    data['dean']!,
                                    style: _responseData.indexOf(data) == 0
                                        ? const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)
                                        : const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: InkWell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                  child: Text(
                                    data['guidance']!,
                                    style: _responseData.indexOf(data) == 0
                                        ? const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)
                                        : const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: InkWell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1.5, 5, 1.5, 7),
                                  child: Text(
                                    data['status']!,
                                    style: _responseData.indexOf(data) == 0
                                        ? const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)
                                        : TextStyle(
                                            color: statusColor, fontSize: 11),
                                  ),
                                ),
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.shifting,
      //   showSelectedLabels: true,
      //   showUnselectedLabels: true,
      //   items: const [
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.assignment),
      //         label: '假單查詢',
      //         backgroundColor: Color.fromARGB(181, 65, 218, 190)),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.format_list_bulleted),
      //         label: '缺曠紀錄',
      //         backgroundColor: Color.fromARGB(181, 65, 218, 190)),
      //   ],
      //   onTap: (int index) {
      //     switch (index) {
      //       case 0:
      //         Navigator.of(context).pushNamed('/absent');
      //         break;
      //       case 1:
      //         Navigator.of(context).pushNamed('/leave_request');
      //         break;
      //     }
      //   },
      // ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 149, 120),
        // automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('假單查詢'),
        actions: const [
          // IconButton(
          //     iconSize: 35,
          //     padding: const EdgeInsets.only(right: 20),
          //     onPressed: () async {
          //       Navigator.pushNamedAndRemoveUntil(
          //           context, MyHomePage.routeName, (route) => false);
          //     },
          //     icon: const Icon(IconData(0xe328, fontFamily: 'MaterialIcons')))
        ],
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/leave_request', (route) => false)),
      ),
    );
  }
}

//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(181, 65, 218, 190),
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         title: const Text('假單查詢(e網通)'),
//         actions: [
//           IconButton(
//               iconSize: 35,
//               padding: const EdgeInsets.only(right: 20),
//               onPressed: () async {
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, MyHomePage.routeName, (route) => false);
//               },
//               icon: const Icon(IconData(0xe328, fontFamily: 'MaterialIcons')))
//           // NeumorphicButton(
//           //   child: Icon(Icons.exit_to_app_outlined),
//           //   style: NeumorphicStyle(
//           //       shape: NeumorphicShape.concave,
//           //       boxShape:
//           //           NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
//           //       depth: 3,
//           //       color: Color.fromARGB(255, 212, 69, 76)),
//           //   drawSurfaceAboveChild: false,
//           //   margin: EdgeInsets.fromLTRB(0.0, 10.0, 15.0, 10.0),
//           //   //padding: EdgeInsets.only(bottom: 1),

//           // ),
//         ],
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//     );
//   }
// }
