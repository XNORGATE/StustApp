import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' show parse;
import 'package:page_transition/page_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stust_app/constats/constants.dart';
import 'package:stust_app/screens/Bulletins.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import '../main.dart';
import '../utils/auto_logout.dart';
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
    with AutoLogoutMixin<HomeworkPage> {
  // final _formKey = GlobalKey<FormState>();
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  // bool _cancelToken = false;

  late String _account = '0'; // Set account and password to 0 by default
  late String _password = '0';
  late String doneButtonText;
  late String questionnaire;
  late bool _isLoading = false; // Flag to indicate if API request is being made

  // late String submissionDeadline ;
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
      // EZconfigLoading();
      // EasyLoading.init();

      // EasyLoading.instance.userInteractions = false;
    });
    _isLoading = true;
    setState(() {});

    // WidgetsBinding.instance.addObserver(this);
    // List<Map<String, String?>> responseData = [];
    _getlocal_UserData().then((data) {
      _account = data[0];
      _password = data[1];

      setState(() {});
    });

    _submitForm().then((value) {
      Timer(const Duration(seconds: 1), () {
        _isLoading = false;
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    // _cancelToken = true;
    // http.Client().close();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.resumed) {
  //     // Enable controls when the page is resumed
  //   } else if (state == AppLifecycleState.inactive ||
  //       state == AppLifecycleState.paused) {
  //     // Disable controls when the page is inactive or paused
  //   }
  // }

  // void EZconfigLoading() {
  //   EasyLoading.instance
  //     ..displayDuration = const Duration(milliseconds: 1500)
  //     ..indicatorType = EasyLoadingIndicatorType.rotatingCircle
  //     ..loadingStyle = EasyLoadingStyle.dark
  //     ..indicatorSize = 45.0
  //     ..radius = 10.0
  //     ..progressColor = Colors.yellow
  //     ..backgroundColor = Colors.green
  //     ..indicatorColor = Colors.yellow
  //     ..textColor = Colors.yellow
  //     ..maskColor = Colors.blue.withOpacity(0.5)
  //     ..userInteractions = true;
  // }

  _getlocal_UserData() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    final userController = Get.find<UserController>();

    _account = userController.username.value;
    _password = userController.password.value;

    // Call _submitForm() method after retrieving and setting the values

    return [_account, _password];
  }

  late List<Map<String, String>> _responseData = [];

  // void _showAlertDialog(BuildContext context,String text, String href) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //         title: Text(text),
  //         content: Html(
  //           data: '<a href="$href">查看作業</a>',
  //         ),
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
    if (dateString.isEmpty) {
      return 'Invalid input: dateString is null or empty';
    }

    if (dateString.contains('~')) {
      List<String> parts = dateString.split('~');
      if (parts.length > 1) {
        String endDate = parts[1].trim();
        print(endDate);

        endDate = '${endDate.replaceAll(' ', 'T')}:00';
        dateString = endDate;
      } else {
        return "Invalid input format";
      }
    }

    try {
      DateTime targetDate =
          DateTime.parse(dateString).add(const Duration(seconds: 86399));
      DateTime now = DateTime.now();
      Duration difference = targetDate.difference(now);

      if (difference.inSeconds < 0) {
        return '已過期';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}小時';
      } else {
        return '${difference.inDays}天';
      }
    } catch (e) {
      return 'Error parsing date: $e';
    }
  }

  String subDateToEndDate(String dateString) {
    if (dateString.isEmpty) {
      return 'Invalid input: dateString is null or empty';
    }

    if (dateString.contains('~')) {
      List<String> parts = dateString.split('~');
      if (parts.length > 1) {
        String endDate = parts[1].trim();
        print(endDate);
        endDate = '${endDate.replaceAll(' ', 'T')}:00';
        dateString = endDate;
      } else {
        return "Invalid input format";
      }
    }
    return dateString;
  }

  String extractString(String originalString) {
    int index = originalString.indexOf("_");
    return index >= 0 ? originalString.substring(0, index) : originalString;
  }

  Future<List<Map<String, String>>> getHomework() async {
    int homeworkPage = 1;
    List<Map<String, String>> homework = [];

    // var session = http.Client();
    Dio dio = Dio();
    var loginUrl = 'https://flipclass.stust.edu.tw/index/login';
    try {
      var response = await dio.get((loginUrl));
      print(response.statusCode);
      var soup = parse(response.data);

      var hiddenInput =
          soup.querySelector('input[name="csrf-t"]')?.attributes['value'];

      response = await dio.get(
          ('$loginUrl?_fmSubmit=yes&formVer=3.0&formId=login_form&next=/&act=keep&account=$_account&password=$_password&rememberMe=&csrf-t=$hiddenInput'));
      if (response.headers['set-cookie'] == null) {
        return [
          {'error': 'Authenticate error(帳號密碼錯誤)'}
        ];
      }

      dynamic cookies = response.headers['set-cookie']!;

      var headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
      };
      var url = 'https://flipclass.stust.edu.tw/dashboard/latestEvent?&page=';

      void genHomework(int homeworkPage) async {
        var response = await dio.get(('$url${homeworkPage.toString()}'),
            options: Options(headers: {...headers, 'cookie': cookies}));
        soup = parse(response.data);

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
            var isDoneresponse = await dio.get(
                ('https://flipclass.stust.edu.tw$href'),
                options: Options(headers: {...headers, 'cookie': cookies}));
            var isDonesoup = parse(isDoneresponse.data);

            // try {
            //   questionnaire = isDonesoup
            //       .querySelector(
            //           'div.text-center.fs-margin-default > button > span')!
            //       .text
            //       .trim();
            // } catch (e) {}

            if (href!.contains('questionnaire')) {
              String? submissionDeadline = '';

              try {
                submissionDeadline = isDonesoup
                    .querySelectorAll('dt')
                    .firstWhere((element) => element.text == '開放期間')
                    .nextElementSibling
                    // ?.querySelector('span')
                    ?.text
                    .trim();
              } catch (e) {}
              var remain = calculateRemainingTime(submissionDeadline!);
              var remainWithSpace = calculateRemainingTime(submissionDeadline);
              // print(doneButtonText);

              newData.add({
                'topic': topic ?? '',
                'src': src ?? '',
                'href': 'https://flipclass.stust.edu.tw$href',
                'date': date ?? '',
                'isDone': '',
                'numberOfSubmissions': '問卷不計',
                'submissionDeadline': submissionDeadline,
                'remain': remain,
                'remainWithSpace': remainWithSpace
              });
            } else if (href.contains('exam')) {
              String? submissionDeadline = '';

              try {
                submissionDeadline = isDonesoup
                    .querySelectorAll('dt')
                    .firstWhere((element) => element.text == '測驗期間')
                    .nextElementSibling
                    // ?.querySelector('span')
                    ?.text
                    .trim();
              } catch (e) {}
              var remain = calculateRemainingTime(submissionDeadline!);
              var remainWithSpace = calculateRemainingTime(submissionDeadline);
              // print(doneButtonText);

              newData.add({
                'topic': topic ?? '',
                'src': src ?? '',
                'href': 'https://flipclass.stust.edu.tw$href',
                'date': date ?? '',
                'isDone': '',
                'numberOfSubmissions': '測驗不計',
                'submissionDeadline': submissionDeadline,
                'remain': remain,
                'remainWithSpace': remainWithSpace
              });
            } else {
              String isDone = '未繳交';

              // print(soup.outerHtml);
              try {
                doneButtonText = isDonesoup
                    .querySelector(
                        'div.text-center.fs-margin-default > a > span')!
                    .text
                    .trim();
              } catch (e) {}
              print(doneButtonText);
              String? numberOfSubmissions = '';

              try {
                numberOfSubmissions = isDonesoup
                    .querySelectorAll('dt')
                    .firstWhere((element) => element.text == '已繳交')
                    .nextElementSibling
                    ?.text
                    .trim();
                print('總共$numberOfSubmissions人已繳交');
              } catch (e) {}
              String? submissionDeadline = '';

              try {
                submissionDeadline = isDonesoup
                    .querySelectorAll('dt')
                    .firstWhere((element) => element.text == '繳交期限')
                    .nextElementSibling
                    ?.querySelector('span')
                    ?.text
                    .trim();
              } catch (e) {}
              var remain = calculateRemainingTime(submissionDeadline!);
              var remainWithSpace = calculateRemainingTime(submissionDeadline);
              // print(doneButtonText);
              if (doneButtonText.contains('檢視')) {
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
          }
          // if (mounted && !_cancelToken) {
          //   try {
          //     setState(() {
          //       _responseData = newData;
          //     });
          //   } catch (e) {
          //     setState(() {
          //       _responseData = newData;
          //     });
          //   }
          // }
          try {
            setState(() {
              _responseData = newData;
            });
          } catch (e) {}
          homeworkPage++;
          genHomework(homeworkPage);
        }
      }

      genHomework(homeworkPage);
      return homework;
    } catch (e) {}
    return homework;
  }

  _submitForm() async {
    // setState(() {
    //   _isLoading = true;
    // });

    // _cancelToken = false;
    try {
      final responseData = await getHomework();
      setState(() {
        _responseData = responseData;
        // EasyLoading.instance.userInteractions = true;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
        controller: HeroController(),
        child: Hero(
            tag: 'Flipclass',
            child: Scaffold(
              // key: _scaffoldKey,
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
                        print(
                            'here : ${subDateToEndDate(data['submissionDeadline']!)}');
                        // print(
                        //     'Date.time Parse ${DateTime.parse(data['submissionDeadline']!)}');
                        return Slidable(
                            // Specify a key if the Slidable is dismissible.
                            key: ValueKey(index),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                // SlidableAction(
                                //   // An action can be bigger than the others.
                                //   flex: 2,
                                //   onPressed: (_) {
                                //     debugPrint('Button del Clicked');
                                //   },
                                //   backgroundColor:
                                //       const Color.fromARGB(255, 218, 26, 26),
                                //   foregroundColor: Colors.white,
                                //   icon: Icons.notifications_off,
                                //   label: '刪除提醒',
                                // ),
                                SlidableAction(
                                  // An action can be bigger than the others.
                                  flex: 2,
                                  onPressed: (_) {
                                    final Event event = Event(
                                      title: '${data['src']} • ${data['topic']!}',
                                      description: data['href']!,
                                      location: 'flipclass',
                                      startDate: DateTime.now(),
                                      endDate: DateTime.parse(
                                          subDateToEndDate(data[
                                              'submissionDeadline']!)),
                                      iosParams:  IOSParams(
                                        reminder: const Duration(
                                            /* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
                                        url: data['href']!, // on iOS, you can set url to your event.
                                      ),
                                      androidParams: const AndroidParams(
                                        emailInvites: [], // on Android, you can add invite emails to your event.
                                      ),
                                    );

                                    Add2Calendar.addEvent2Cal(event);
                                  },
                                  backgroundColor: const Color(0xFF7BC043),
                                  foregroundColor: Colors.white,
                                  icon: Icons.notification_add,
                                  label: '加入提醒',
                                ),
                              ],
                            ),

                            // The child of the Slidable is what the user sees when the
                            // component is not dragged.
                            child: InkWell(
                              onTap: () async {
                                if (!(data['numberOfSubmissions'] == '問卷不計' ||
                                    data['numberOfSubmissions'] == '測驗不計')) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeWorkDetailPage(),
                                      settings: RouteSettings(arguments: {
                                        'topic': data['topic'],
                                        'src': data['src'],
                                        'href': data['href'],
                                        'account': _account,
                                        'password': _password,
                                      }),
                                    ),
                                  );
                                } else {
                                  final confirmed = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      scrollable: true,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            data['topic']!,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          const Divider(
                                            thickness: 1.5,
                                          )
                                        ],
                                      ),
                                      content: const Center(
                                        child: Text(
                                          '此作業為問卷或測驗，請至flipclass作答',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          // style: const NeumorphicStyle(
                                          //   color: Color.fromARGB(255, 171, 245, 167),
                                          //   shape: NeumorphicShape.flat,
                                          // ),
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text(
                                            '退出',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color?>(
                                              (states) => const Color.fromARGB(
                                                  255, 117, 149, 120),
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            '前往作答',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    launchUrl(Uri.parse(data['href']!),
                                        mode: LaunchMode
                                            .externalNonBrowserApplication);
                                  }
                                  // _showAlertDialog(context,'此作業為問卷或測驗，請至flipclass作答', data['href']!);
                                }
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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

                                              data['isDone'] == '未繳交' ||
                                                      data['numberOfSubmissions']!
                                                          .contains('問卷') ||
                                                      data['numberOfSubmissions']!
                                                          .contains('測驗')
                                                  ? const Icon(
                                                      Icons.assignment,
                                                      size: 18,
                                                      color: Color.fromARGB(
                                                          255, 243, 29, 29),
                                                    )
                                                  : const Icon(
                                                      Icons.done,
                                                      size: 18,
                                                      color: Color.fromARGB(
                                                          255, 11, 167, 245),
                                                    ),
                                              const SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                data['isDone']
                                                        ?.replaceAll("交", "") ??
                                                    "",
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
                                                        BorderRadius.circular(
                                                            99)),
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
                                                    fontSize: 11.0,
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
                            ));
                      },
                    ),
              bottomNavigationBar: BottomNavigationBar(
                selectedFontSize: 12.0,
                backgroundColor: const Color.fromARGB(255, 117, 149, 120),
                type: BottomNavigationBarType.shifting,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment),
                    label: '最新作業',
                    backgroundColor: Color.fromARGB(255, 117, 149, 120),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.format_list_bulleted),
                    label: '最新公告',
                    backgroundColor: Color.fromARGB(255, 117, 149, 120),
                  ),
                ],
                onTap: (int index) {
                  switch (index) {
                    case 0:
                      if (ModalRoute.of(context)?.settings.name ==
                          '/homework') {
                        return;
                      }
                      // Navigator.of(context).pushReplacementNamed('/homework');
                      // // Navigator.of(context).pushNamedAndRemoveUntil('/homework',ModalRoute.withName('/home'));
                      // // Navigator.pushNamedAndRemoveUntil(
                      // //     context, '/homework', (route) => false);
                      break;
                    case 1:
                      // if (ModalRoute.of(context)?.settings.name == '/bulletins') {
                      //   return;
                      // }
                      // Navigator.of(context).pushNamedAndRemoveUntil('/bulletins',ModalRoute.withName('/home'));
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: const BulletinsPage()));
                      break;
                  }
                },
              ),
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 117, 149, 120),
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
            )));
  }
}
