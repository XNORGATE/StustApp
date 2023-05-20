import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stust_app/screens/leave_request.dart';
import 'package:stust_app/utils/dialog_utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/check_connecion.dart';

class LeaveRequestPage extends StatefulWidget {
  static const routeName = '/leave_request';

  const LeaveRequestPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LeaveRequestPageState createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  // final _formKey = GlobalKey<FormState>();
  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isSending = false;

  late String _account = '0'; // Set account and password to 0 by default
  late String _password = '0';

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

      _getlocal_UserData().then((data) {
        _account = data[0];
        _password = data[1];

        setState(() {});
      });
    });
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
// Flag to indicate if API request is being made

  void _showAlertDialog(String text, String href, dynamic soup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(text),
          content: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: HtmlWidget(
                          soup.outerHtml,
                          textStyle: const TextStyle(fontSize: 50),
                        ),
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
            },
            child: const ListTile(
              title: Text('假單連結點我', style: TextStyle(color: Colors.blue)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => super.widget));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSendingDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text('正在執行請假動作 待結果顯示即可關閉...'),
            ],
          ),
        );
      },
    );
  }

  // void _hideSendingDialog() {
  //   Navigator.popUntil(context, ModalRoute.withName('leave_request'));
  // }

  int dateToWeekDay(String dateText) {
    String formattedDateText = dateText.replaceAll(RegExp(r'[^\d/]'), '');
    DateFormat formatter = DateFormat('yyyy/MM/dd');
    DateTime date = formatter.parse(formattedDateText);
    int dayIndex = date.weekday;
    // print('$dateText ,$dayIndex');
    return dayIndex;
  }

  Future<List<Map<String, String>>> getAbsent() async {
    List<Map<String, String>> absentEvent = [];
    List<Map<String, String>> ExistLeaveRequest = [];

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

    ///  responseData載入後 先去載入假單查詢 然後將處理中的href 全部抓出來 依次載入所有href裡的節數與周次 與responseData 裡的week跟 section比對 看哪個假單處理中 卻還存在於responseData 將他們del掉 避免重複請假

    response = await session.get(
        Uri.parse('https://portal.stust.edu.tw/abs_stu/query/query.asp'),
        headers: {...headers, 'cookie': cookies});
    responseBodyHex = hex.encode(response.bodyBytes);
    soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
    final rows = soup.querySelectorAll('tr[align="center"][bgcolor="#FFFF99"]');

    for (final row in rows) {
      final status = row.querySelector('td[width="104"]');
      // print(status?.innerHtml);

      if (status != null && status.innerHtml.contains('處理中')) {
        String link =
            'https://portal.stust.edu.tw/abs_stu/query/${row.querySelector('a')!.attributes['href']!}';

        response = await session
            .get(Uri.parse(link), headers: {...headers, 'cookie': cookies});
        responseBodyHex = hex.encode(response.bodyBytes);
        soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
        // print(soup.outerHtml);

        var week = soup.querySelector('td[width="134"]')!.text.trim();
        var typeElement = soup.querySelector('td[valign="center"]');
        var type = typeElement?.nextElementSibling?.text.trim(); // output 事假/病假

        // get the desired <td> element
        var tdElement = soup.querySelector('td > font.c12 > b');
        // print(tdElement);

        // get the parent <tr> element
        var trElement = tdElement!.parent!
            .parent; //<td><font class="c12"><b>事假<br>Personal Leave</b>　</font></td>
        var tableElement = trElement!.parent;

        // find the index of the <td> element in the parent <tr> element
        var tdIndex = tableElement!.children.indexOf(trElement);
        var day = (tdIndex.toInt() - 1).toString(); // 周幾
        // print(tdIndex);

        // find the index of the parent <tr> element in its parent <table> element
        // var trIndex = tableElement!.children.indexOf(trElement);

        // get the previous sibling <td> element to get the "5"
        var prevTdElement = tableElement.children[0];
        // print(prevTdElement);
        var tdValue = prevTdElement.text;
        // print('week $week ,周幾: $day  section: $tdValue');

        // print(tdValue);
        ExistLeaveRequest.add({
          'week': week,
          'day': day,
          'section': tdValue,
        });
      }
    }
    // print(ExistLeaveRequest);
    // print(absentEvent);

    absentEvent.removeWhere((absent) => ExistLeaveRequest.any((exist) =>
        exist['week'] == absent['week'] &&
        exist['section'] == absent['section'] &&
        exist['day'] == dateToWeekDay(absent['date']!).toString()));
    // print(ExistLeaveRequest);
    var now = DateTime.now();

    // Filter out entries where the date is more than 30 days ago
    var filteredAbsentEvent = absentEvent.where((event) {
      var eventDate = DateFormat('yyyy/MM/dd').parse(event['date']!);
      return now.difference(eventDate).inDays <= 30;
    }).toList();

// Update the original list with the filtered list
    absentEvent = filteredAbsentEvent;
    // Print the updated absentEvent list
    // print(absentEvent);

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

  String absentType = '4';
  String absentReason = '身體不適';

  Future _sendleave_request(String week, String absentType, String absentReason,
      String section, String day) async {
    // print(week);
    // print(absentType);
    // print(absentReason);
    // print(section);
    // print(day);

    // setState(() {});
    // _showSendingDialog();

    try {
      // // Make POST request to the API
      // http
      //     .get(
      //   Uri.parse(''),
      // )
      //     .then((response) {
      //   final responseData = json.decode(response.body) as List;
      //   //print(responseData);
      //   setState(() {
      //     _responseData = responseData;
      //     _isLoading = false;
      //   });
      //   // Display alert dialog with response data
      //   _showAlertDialog('Success', 'Your request has been sent');
      // });

      var session = http.Client();

      final queryParameters = {
        'stud_no': _account,
        'passwd': _password,
        'b1': '登入Login'
      };
      final leaveRequestFormData = {
        'weekd': week, //(周)
        'h1': '',
        'ver': '-- Select Language --',
        'weekee': week, //(周)
        'CLASSsel': absentType, //4 (4:事假3:病假 2:婚喪產假 1:公假)
        'reason': absentReason, //
        'CHAPchk$section': day
      };
      final confirmData = {'Submit': '確定送出Submit'};

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
          Uri.parse('https://portal.stust.edu.tw/abs_stu/asking/select-p.asp'),
          headers: {...headers, 'cookie': cookies});
      var responseBodyHex = hex.encode(response.bodyBytes);
      var soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
      // print(soup.outerHtml);

      if (absentType == '4') {
        //事假
        // print('absentType: $absentType');
        response = await session.get(
            Uri.parse(
                'https://portal.stust.edu.tw/abs_stu/asking/select-p.asp'),
            headers: {...headers, 'cookie': cookies});
      } else if (absentType == '3') {
        //病假
        response = await session.get(
            Uri.parse('https://portal.stust.edu.tw/abs_stu/asking/select.asp'),
            headers: {...headers, 'cookie': cookies});
      }
      response = await session.post(
          Uri.parse('https://portal.stust.edu.tw/abs_stu/asking/confirm.asp'),
          headers: {...headers, 'cookie': cookies},
          body: leaveRequestFormData);
      // var responseBodyHex = hex.encode(response.bodyBytes);
      // var soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
      // print(soup.outerHtml);
      response = await session.post(
          Uri.parse('https://portal.stust.edu.tw/abs_stu/asking/list.asp'),
          headers: {...headers, 'cookie': cookies},
          body: confirmData);
      response = await session.get(
          Uri.parse('https://portal.stust.edu.tw/abs_stu/query/query.asp'),
          headers: {...headers, 'cookie': cookies});
      responseBodyHex = hex.encode(response.bodyBytes);
      soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
      // print(soup.outerHtml);
      ////請完假了 要去query.asp檢查是否成功

      final rows =
          soup.querySelectorAll('tr[align="center"][bgcolor="#FFFF99"]');
      for (final row in rows) {
        final status = row.querySelector('td[width="104"]');
        // print(status);

        if (status != null && status.innerHtml.contains('處理中')) {
          String link =
              'https://portal.stust.edu.tw/abs_stu/query/${row.querySelector('a')!.attributes['href']!}';

          // print(link);

          response = await session
              .get(Uri.parse(link), headers: {...headers, 'cookie': cookies});
          responseBodyHex = hex.encode(response.bodyBytes);
          soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
          // print(link);

          // var tdElement = soup.querySelector('td[width="70"]');

          // print(weekElement?.text.trim());

          // 2. Extract the '事假' element and its index inside the tr tag
          var trElement = soup.querySelectorAll('tr[align="center"]');
          var weekElement = soup.querySelector('td[width="134"]');

          // var tdElements = trElement.querySelector('td');
          // print(tdElements);
          for (int i = 0; i < trElement.length; i++) {
            // print(trElement[i]);
            var td = trElement[i].querySelectorAll('td');
            // print(td);
            for (var t in td) {
              // print(t.text);
              var shijiaElement = t.text.split('\n')[0].trim();
              // print('shijiaElement: $shijiaElement');
              if (shijiaElement.contains('假')) {
                // print('shijiaElement: $shijiaElement');
                // print('absentType: $absentType');
                // print('weekElement?.text.trim(): ${weekElement?.text.trim()}');
                // print('week: $week');
                // print('(i - 1).toString(): ${(i - 1).toString()}');

                // print('section:$section');

                if (shijiaElement.contains('事假') &&
                    absentType == '4' &&
                    weekElement?.text.trim() == week &&
                    (i - 1).toString() == section) {
                  // print('成功');
                  setState(() {
                    isSending = false;
                  });
                  // _hideSendingDialog();

                  _showAlertDialog('請假成功', link, soup);
                } else if (shijiaElement.contains('病假') &&
                    absentType == '3' &&
                    weekElement?.text.trim() == week &&
                    (i - 1).toString() == section) {
                  // print('成功 假單: $link');
                  setState(() {
                    isSending = false;
                  });
                  // _hideSendingDialog();
                  _showAlertDialog('請假成功', link, soup);
                } else {
                  // print('失敗');
                  setState(() {
                    isSending = false;
                  });
                  // _hideSendingDialog();
                  // Navigator.of(context).pop();
                  showDialogBox(context, '此操作未達成，請重試');
                }

                return;
              }
            }
          }
        }
      }
    } catch (e) {
      // _hideSendingDialog();
      // MaterialPageRoute(builder: (context) => const LeaveRequestPage());

      // Navigator.of(context).pop();
      // _showDialog('此操作未達成，請重試');
      // Handle the error here
    }
    // setState(() {
    //   _isSending = false;
    // });
    // _showDialog('此操作未達成，請重試');
    // MaterialPageRoute(builder: (context) => const LeaveRequestPage());
  }

  @override
  void dispose() {
    http.Client().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
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
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['lesson']!,
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
                                    data['reason']!,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                            // if (_responseData.indexOf(data) == 0)
                            TableCell(
                              child: IconButton(
                                icon: const Icon(Icons.assignment,
                                    color: Color.fromARGB(255, 92, 90, 90),
                                    size: 30),
                                onPressed: () {
                                  if (_responseData.indexOf(data) == 0) {
                                    showDialogBox(context,
                                        '1.此系統僅提供事假/病假申請\n2.所有請假需在缺課1個月內完成申請\n3.此表格僅會顯示已被紀錄缺席之課堂\n4.若缺課無出現表示已超過請假時限或已完成請假');
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  '送出假單:',
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 16.0),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SelectorWidget(
                                                      labelText: '假別',
                                                      options: const [
                                                        '事假',
                                                        '病假'
                                                      ],
                                                      onChanged: (value) {
                                                        // Handle the value change
                                                        if (value == '病假') {
                                                          absentType = '3';
                                                        } else {
                                                          absentType = '4';
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16.0),
                                                TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: '請假事由',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) {
                                                    absentReason = value;
                                                    // Handle the value change
                                                  },
                                                ),
                                                const SizedBox(height: 16.0),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('取消'),
                                                    ),
                                                    isSending
                                                        ? const CircularProgressIndicator()
                                                        : ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              isSending = true;
                                                              // Handle the form submission
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              try {
                                                                await _sendleave_request(
                                                                    data['week']
                                                                        .toString(),
                                                                    absentType,
                                                                    absentReason,
                                                                    data['section']
                                                                        .toString(),
                                                                    dateToWeekDay(
                                                                            data['date']!)
                                                                        .toString());
                                                              } catch (e) {}
                                                            },
                                                            child: const Text(
                                                                '送出'),
                                                          ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
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
        selectedFontSize: 12.0,
        backgroundColor: const Color.fromARGB(255, 117, 149, 120),
        type: BottomNavigationBarType.shifting,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: '請假系統',
              backgroundColor: Color.fromARGB(255, 117, 149, 120),),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: '缺曠紀錄',
              backgroundColor: Color.fromARGB(255, 117, 149, 120),),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              if (ModalRoute.of(context)?.settings.name == '/absent') {
                return;
              }
              // Navigator.of(context).pushReplacementNamed('/homework');
              // // Navigator.of(context).pushNamedAndRemoveUntil('/homework',ModalRoute.withName('/home'));
              // // Navigator.pushNamedAndRemoveUntil(
              // //     context, '/homework', (route) => false);
              break;
              
            case 1:
              // if (ModalRoute.of(context)?.settings.name == '/leave_request') {
              //   return;
              // }
              // Navigator.of(context).pushNamedAndRemoveUntil('/bulletins',ModalRoute.withName('/home'));
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: const AbsentPage()));              break;
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 149, 120),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('請假'),
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
                context, '/', (route) => false)),
      ),
    );
  }
}

//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.shifting,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.assignment),
//               label: '假單查詢',
//               backgroundColor: Color.fromARGB(181, 65, 218, 190)),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.format_list_bulleted),
//               label: '缺曠紀錄',
//               backgroundColor: Color.fromARGB(181, 65, 218, 190)),
//         ],
//         onTap: (int index) {
//           switch (index) {
//             case 0:
//               Navigator.of(context).pushNamed('/absent');
//               break;
//             case 1:
//               Navigator.of(context).pushNamed('/leave_request');
//               break;
//           }
//         },
//       ),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(181, 65, 218, 190),
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         title: const Text('缺曠紀錄及請假(e網通)'),
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

/////////////////////////////////////////////////

class SelectorWidget extends StatefulWidget {
  final String labelText;
  final List<String> options;
  final Function(String)? onChanged;

  const SelectorWidget({
    super.key,
    required this.labelText,
    required this.options,
    this.onChanged,
  });

  @override
  _SelectorWidgetState createState() => _SelectorWidgetState();
}

class _SelectorWidgetState extends State<SelectorWidget> {
  String _selectedOption = '';

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: widget.options.map((option) {
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedOption = option;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(_selectedOption);
                }
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: option == _selectedOption
                          ? Colors.blueAccent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        width: 1.0,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            color: option == _selectedOption
                                ? Colors.white
                                : Colors.black,
                            fontWeight: option == _selectedOption
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
