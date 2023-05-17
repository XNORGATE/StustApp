import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import '../utils/check_connecion.dart';
import './home_work_detail.dart';
// import 'package:html/dom.dart';

class HomeworkPage extends StatefulWidget {
  static const routeName = '/homework';

  const HomeworkPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _HomeworkPageState createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _cancelToken = false;

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
      WidgetsBinding.instance.addObserver(this);
      List<Map<String, String?>> responseData = [];
      _getlocal_UserData().then((data) {
        _account = data[0];
        _password = data[1];

        setState(() {});
      });

      _submitForm();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelToken = true;
    // http.Client().close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Enable controls when the page is resumed
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Disable controls when the page is inactive or paused
    }
  }

  _getlocal_UserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _account = prefs.getString('account')!;
    _password = prefs.getString('password')!;

    return [_account, _password];
  }

  late List<Map<String, String>> _responseData = [];
  late bool _isLoading = false; // Flag to indicate if API request is being made

  void _showAlertDialog(String text, String href) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

  String extractMonthAndDay(String dateString) {
    List<String> dateParts = dateString.split("-");
    String month = dateParts[1];
    String day = dateParts[2].substring(0, 2);
    return "$month-$day";
  }

  // String extractHomeworkCode(String url) {
  //   List<String> segments = url.split("/");
  //   return segments.last;
  // }
  String calculateRemainingTime(String dateString) {
    DateTime targetDate = DateTime.parse(dateString)
        .add(const Duration(seconds: 86399)); // Add one day
    DateTime now = DateTime.now();
    Duration difference = targetDate.difference(now);
    if (difference.inSeconds < 0) {
      print('targetDate :$targetDate now :$now difference :$difference');
      return '已過期';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小時';
    } else {
      return '${difference.inDays}天';
    }
  }

  String calculateRemainingTimeWithSpace(String dateString) {
    DateTime targetDate = DateTime.parse(dateString)
        .add(const Duration(seconds: 86399)); // Add one day
    DateTime now = DateTime.now();
    Duration difference = targetDate.difference(now);
    if (difference.inSeconds < 0) {
      print('targetDate :$targetDate now :$now difference :$difference');
      return '已過期';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} 小時';
    } else {
      return '${difference.inDays} 天';
    }
  }

  String extractString(String originalString) {
    int index = originalString.indexOf("_");
    return index >= 0 ? originalString.substring(0, index) : originalString;
  }

  Future<List<Map<String, String>>> getHomework() async {
    int homeworkPage = 1;
    List<Map<String, String>> homework = [];

    var session = http.Client();
    var loginUrl = 'https://flipclass.stust.edu.tw/index/login';
    var response = await session.get(Uri.parse(loginUrl));
    print(response.statusCode);
    var soup = parse(response.body);

    var hiddenInput =
        soup.querySelector('input[name="csrf-t"]')?.attributes['value'];

    response = await session.get(Uri.parse(
        '$loginUrl?_fmSubmit=yes&formVer=3.0&formId=login_form&next=/&act=keep&account=$_account&password=$_password&rememberMe=&csrf-t=$hiddenInput'));
    if (response.headers['set-cookie'] == null) {
      return [
        {'error': 'Authenticate error(帳號密碼錯誤)'}
      ];
    }

    String cookies = response.headers['set-cookie']!;

    var headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
    };
    var url = 'https://flipclass.stust.edu.tw/dashboard/latestEvent?&page=';

    void genHomework(int homeworkPage) async {
      response = await session.get(Uri.parse('$url${homeworkPage.toString()}'),
          headers: {...headers, 'cookie': cookies});
      soup = parse(response.body);

      if (soup.querySelector('#noData > td') == null) {
        var hrefArr = soup.querySelectorAll('div.sm-text-overflow > a');
        var works = soup.querySelectorAll('tbody > tr');

        var newData = List<Map<String, String>>.from(
            _responseData); // Create new list object

        for (int i = 0; i < works.length; i++) {
          var topic =
              works[i].querySelector('div.sm-text-overflow')?.text.trim();
          var src = works[i]
              .querySelector('div.text-overflow > a > span')
              ?.text
              .trim();
          var href = hrefArr[i].attributes['href'];
          var dateDiv = works[i]
              .querySelector('td.text-center.col-date > div.text-overflow');
          var date = dateDiv?.attributes['title'];
          var isDoneresponse = await session.get(
              Uri.parse('https://flipclass.stust.edu.tw$href'),
              headers: {...headers, 'cookie': cookies});
          var isDonesoup = parse(isDoneresponse.body);

          String isDone = '未繳交';
          // print(soup.outerHtml);
          var doneButtonText = isDonesoup
              .querySelector('div.text-center.fs-margin-default > a > span')
              ?.text
              .trim();

          var numberOfSubmissions = isDonesoup
              .querySelectorAll('dt')
              .firstWhere((element) => element.text == '已繳交')
              .nextElementSibling
              ?.text
              .trim();
          var submissionDeadline = isDonesoup
              .querySelectorAll('dt')
              .firstWhere((element) => element.text == '繳交期限')
              .nextElementSibling
              ?.querySelector('span')
              ?.text
              .trim();
          var remain = calculateRemainingTime(submissionDeadline!);
          var remainWithSpace =
              calculateRemainingTimeWithSpace(submissionDeadline);
          // print(doneButtonText);
          if (doneButtonText!.contains('檢視')) {
            isDone = '已繳交';
          }

          newData.add({
            'topic': topic ?? '',
            'src': src ?? '',
            'href': 'https://flipclass.stust.edu.tw$href',
            'date': date ?? '',
            'isDone': isDone,
            'numberOfSubmissions': numberOfSubmissions ?? '',
            'submissionDeadline': submissionDeadline,
            'remain': remain,
            'remainWithSpace': remainWithSpace
          });
        }

        if (mounted && !_cancelToken) {
          try {
            setState(() {
              _responseData = newData;
            });
          } catch (e) {
            setState(() {
              _responseData = newData;
            });
          }
        }
        homeworkPage++;
        genHomework(homeworkPage);
      }
    }

    genHomework(homeworkPage);
    return homework;
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    _cancelToken = false;
    try {
      final responseData = await getHomework();
      if (mounted && !_cancelToken) {
        setState(() {
          _responseData = responseData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_cancelToken) {
        setState(() {
          _isLoading = false;
          _showAlertDialog(e.toString(), e.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _responseData.length,
              // separatorBuilder: (context, index) => const Divider(
              //   height: 5,
              //   indent: 8,
              //   endIndent: 8,
              // ),
              itemBuilder: (context, index) {
                final data = _responseData[index];
                // bool isStringTooLong = data['topic']!.length > 13;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeWorkDetailPage(),
                        settings: RouteSettings(arguments: {
                          'topic': data['topic'],
                          'src': data['src'],
                          'href': data['href'],
                          'account': _account,
                          'password': _password,
                        }),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 1.5, horizontal: 8),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: Column(
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Text(
                                  //   extractMonthAndDay(data['date']!),
                                  //   style: const TextStyle(
                                  //     fontSize: 18.0,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                  // const SizedBox(
                                  //   width: 20,
                                  // ),

                                  data['isDone'] == '未繳交'
                                      ? const Icon(
                                          Icons.assignment,
                                          size: 18,
                                          color:
                                              Color.fromARGB(255, 243, 29, 29),
                                        )
                                      : const Icon(
                                          Icons.done,
                                          size: 18,
                                          color:
                                              Color.fromARGB(255, 11, 167, 245),
                                        ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    data['isDone']?.replaceAll("交", "") ?? "",
                                    strutStyle: const StrutStyle(
                                      forceStrutHeight: true,
                                      leading: 0.5,
                                    ),
                                  ),

                                  Container(
                                    width: 3,
                                    height: 3,
                                    margin: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(99)),
                                    child: const SizedBox.shrink(),
                                  ),
                                  Text(
                                    data['src']!,
                                    strutStyle: const StrutStyle(
                                      forceStrutHeight: true,
                                      leading: 0.5,
                                    ),
                                  )
                                  // Text(
                                  //   "${extractMonthAndDay(data['date']!)} 前",
                                  //   strutStyle: const StrutStyle(
                                  //     forceStrutHeight: true,
                                  //     leading: 0.5,
                                  //   ),
                                  // ),
                                  // Container(
                                  //   width: 3,
                                  //   height: 3,
                                  //   margin: const EdgeInsets.all(8),
                                  //   decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(99)),
                                  //   child: const SizedBox.shrink(),
                                  // ),
                                  // if (data['isDone'] == '未繳交')
                                  //   Text(
                                  //     '剩下${data['remain']}',
                                  //     strutStyle: const StrutStyle(
                                  //       forceStrutHeight: true,
                                  //       leading: 0.5,
                                  //     ),
                                  //   ),
                                ],
                              ),
                              // Text(
                              //   data['src']!,
                              //   style: const TextStyle(
                              //     fontSize: 15.0,
                              //     // fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              Text(
                                data['topic']!,
                                style: const TextStyle(
                                  // overflow: TextOverflow.ellipsis,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '期限: ${data['submissionDeadline']}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '已交: ${data['numberOfSubmissions']}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '剩餘: ${data['remain']}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 12.0,
        backgroundColor: Colors.green[200],
        type: BottomNavigationBarType.shifting,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: '最新作業',
              backgroundColor: Color.fromARGB(181, 65, 218, 190)),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: '最新公告',
              backgroundColor: Color.fromARGB(181, 65, 218, 190)),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              if (ModalRoute.of(context)?.settings.name == '/homework') {
                return;
              }
              // Navigator.of(context).pushReplacementNamed('/homework');
              // // Navigator.of(context).pushNamedAndRemoveUntil('/homework',ModalRoute.withName('/home'));
              // // Navigator.pushNamedAndRemoveUntil(
              // //     context, '/homework', (route) => false);
              break;
            case 1:
              if (ModalRoute.of(context)?.settings.name == '/bulletins') {
                return;
              }
              // Navigator.of(context).pushNamedAndRemoveUntil('/bulletins',ModalRoute.withName('/home'));
              Navigator.pushNamed(context, '/bulletins');
              break;
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(181, 65, 218, 190),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('查詢最近作業(flipclass)'),
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
