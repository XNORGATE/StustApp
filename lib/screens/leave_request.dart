import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stust_app/utils/dialog_utils.dart';
import '../main.dart';

class AbsentPage extends StatefulWidget {
  static const routeName = '/absent';

  const AbsentPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AbsentPageState createState() => _AbsentPageState();
}

class _AbsentPageState extends State<AbsentPage> {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _account = prefs.getString('account')!;
    _password = prefs.getString('password')!;

    _submitForm();
    return [_account, _password];
  }

  late List _responseData;
  late bool _isLoading = false; // Flag to indicate if API request is being made

  Future<List<Map<String, String?>>> getLeaveRequest() async {
    // List<Map<String, String>> absentEvent = [];
    List<Map<String, String?>> LeaveRequest = [];

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

    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
    };

    response = await session.get(
        Uri.parse('https://portal.stust.edu.tw/abs_stu/query/query.asp'),
        headers: {...headers, 'cookie': cookies});
    var responseBodyHex = hex.encode(response.bodyBytes);
    var soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

    var trElement = soup
        .querySelectorAll('tr[align="center"][bgcolor="#FFFF99"]'); // every row
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
      setState(() {
        _isLoading = false;
        showDialogBox(context, e.toString());
      });
    }
    // }
  }
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
  //           'http://api.xnor-development.com:70/absent?account=$_account&password=$_password'),
  //     )
  //         .then((response) {
  //       final responseData = json.decode(response.body) as List;
  //       //print(responseData);
  //       setState(() {
  //         _responseData = responseData;
  //         _isLoading = false;
  //       });
  //     });
  //   }
  // }
  // // void _submitForm() {
  // //   if (_formKey.currentState!.validate()) {
  // //     _formKey.currentState!.save();
  // //     setState(() {
  // //       _isLoading = true;
  // //     });

  // //     // Make POST request to the API
  // //     http.post(
  // //       Uri.parse('http://api.xnor-development.com:70/absent'),
  // //       body: {
  // //         'account': _account,
  // //         'password': _password,
  // //       },
  // //     ).then((response) {
  // //       // Parse response body into a list of maps
  // //       final responseData = json.decode(response.body) as List;
  // //       setState(() {
  // //         _responseData = responseData;
  // //         _isLoading = false;
  // //       });
  // //       // Handle response from the API here
  // //       // Display alert dialog to the user
  // //     });
  // //   }
  // // }
  Color statusColor = const Color.fromARGB(255, 11, 111, 14);
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['leaveType']!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['week']!,
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 16),
                                    ),
                                  ),
                                  onTap: () async {
                                    if (data['week'].contains('週次') != true) {
                                      print(data['href']);
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
                                          'portal.stust.edu.tw',
                                          '/abs_stu/verify.asp',
                                          queryParameters);
                                      //authenticate
                                      var response = await session.post(uri);
                                      String cookies =
                                          '${response.headers['set-cookie']!}; 3wave=1';

                                      final headers = {
                                        'User-Agent':
                                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
                                      };
                                      final link = data['href'];
                                      response = await session.get(
                                          Uri.parse(
                                              'https://portal.stust.edu.tw/abs_stu//query/$link'),
                                          headers: {
                                            ...headers,
                                            'cookie': cookies
                                          });
                                      var responseBodyHex =
                                          hex.encode(response.bodyBytes);
                                      var soup = html_parser.parse(utf8
                                          .decode(hex.decode(responseBodyHex)));
                                      _showAlertDialog(soup);
                                    }
                                  },
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['date'].toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['teacher']!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['instructor']!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              // if (_responseData.indexOf(data) == 0)
                              TableCell(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['chairman']!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['chief']!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['dean']!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['guidance']!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['status']!,
                                      style: TextStyle(
                                          color: statusColor, fontSize: 16),
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
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
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
              label: '假單查詢',
              backgroundColor: Color.fromARGB(181, 65, 218, 190)),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: '缺曠紀錄',
              backgroundColor: Color.fromARGB(181, 65, 218, 190)),
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
        backgroundColor: const Color.fromARGB(181, 65, 218, 190),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('假單查詢(e網通)'),
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
