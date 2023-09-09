import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

import '../main.dart';
import '../utils/auto_logout.dart';
import '../utils/check_connecion.dart';

class BulletinsPage extends StatefulWidget {
  static const routeName = '/bulletins';

  const BulletinsPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _BulletinsPageState createState() => _BulletinsPageState();
}

class _BulletinsPageState extends State<BulletinsPage>
    with WidgetsBindingObserver, AutoLogoutMixin<BulletinsPage>{
  // final _formKey = GlobalKey<FormState>();
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  // final bool _cancelToken = false;

  late String _account = '0'; // Set account and password to 0 by default
  late String _password = '0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
      // List<Map<String, String?>> responseData = [];
      _getlocal_UserData().then((data) {
        _account = data[0];
        _password = data[1];
        //print(_account);
        //print(_password);

        setState(() {});
        _submitForm();
      });

      
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // _cancelToken = true;
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
    // SharedPreferences prefs = await SharedPreferences.getInstance();
      final userController = Get.find<UserController>();

    _account = userController.username.value;
    _password = userController.password.value;

    // Call _submitForm() method after retrieving and setting the values

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

  Future<List<Map<String, String>>> gen_bulletin() async {
    int bulletinPage = 1;
    List<Map<String, String>> Bulletin = [];
    Dio dio = Dio();
    // var session = http.Client();
    var loginUrl = 'https://flipclass.stust.edu.tw/index/login';
    try {
      var response = await dio.get((loginUrl));
      http.Response detail;
      var soup = parse(response.data);

      var hiddenInput =
          soup.querySelector('input[name="csrf-t"]')?.attributes['value'];

      // var payload = {
      //   '_fmSubmit': 'yes',
      //   'formVer': '3.0',
      //   'formId': 'login_form',
      //   'next': '/',
      //   'act': 'keep',
      //   'account': acc,
      //   'password': pwd,
      //   'rememberMe': '',
      //   'csrf-t': hiddenInput
      // };

      response = await dio.get((
          '$loginUrl?_fmSubmit=yes&formVer=3.0&formId=login_form&next=/&act=keep&account=$_account&password=$_password&rememberMe=&csrf-t=$hiddenInput'));
      if (response.headers['set-cookie'] == null) {
        return [
          {'error': 'Authenticate error(帳號密碼錯誤)'}
        ];
      }

      List<String> cookies = response.headers['set-cookie']!;

      var headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
      };
      var url =
          'https://flipclass.stust.edu.tw/dashboard/latestBulletin?&page=';

      void gen_bulletin(int bulletinPage) async {
        response = await dio.get(
            ('$url${bulletinPage.toString()}'),
            options: Options(headers: {...headers, 'cookie': cookies}));
        soup = parse(response.data);

        if (soup.querySelector('#noData > td') == null) {
          var hrefArr = soup.querySelectorAll(
              'td.text-center.col-char7 > div.text-overflow > a');
          // print(hrefArr);
          var works = soup.querySelectorAll('tbody > tr');

          var newData = List<Map<String, String>>.from(
              _responseData); // Create new list object

          for (int i = 0; i < works.length; i++) {
            var topic = works[i]
                .querySelector('a.fs-bulletin-item > span')
                ?.text
                .trim();
            var src =
                'https://flipclass.stust.edu.tw${works[i].querySelector('div.text-overflow > a')?.attributes['data-url']}&fs_no_foot_js=1';
            var href = hrefArr[i].attributes['href'];
            var classSrc = hrefArr[i].querySelector('span')?.text.trim();
            // while (href!.contains('/course')) {
            //   href = hrefArr[i+1].attributes['href'];
            // }
            // print(href);
            // var dateDiv = works[i]
            //     .querySelector('td.hidden-xs.text-center.col-date > div');
            var date = works[i]
                .querySelector('td.hidden-xs.text-center.col-date > div')
                ?.text
                .trim();

            ////scrap into detail
            var detail = await dio
                .get((src), options: Options(headers: {...headers, 'cookie': cookies}));
            var detailRes = parse(detail.data);
            String? fileName;
            String? fileUrl;
            var bulletinContent =
                detailRes.querySelector('div.bulletin-content')?.text.trim();
            var filenameElement =
                detailRes.querySelector('li.clearfix > div.text > a >span');
            if (filenameElement != null) {
              // print('fileName');
              fileName = filenameElement.text.trim();
              fileUrl =
                  'https://flipclass.stust.edu.tw${detailRes.querySelector('li.clearfix > div.text > a')!.attributes['href']!}';
            } else {
              // print('null');
              fileName = '0';
              fileUrl = '0';
            }
            newData.add({
              'topic': topic ?? '',
              'class': classSrc ?? '',
              'href': 'https://flipclass.stust.edu.tw$href',
              'date': date ?? '',
              'content': bulletinContent ?? '',
              'filename': fileName,
              'url': fileUrl
            });
          }

          try {
            setState(() {
              _responseData = newData;
            });
          } catch (e) {}

          bulletinPage++;
          gen_bulletin(bulletinPage);
        }
      }

      gen_bulletin(bulletinPage);
    } catch (e) {}

    return Bulletin;
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final responseData = await gen_bulletin();

      setState(() {
        _responseData = responseData;
        _isLoading = false;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      body: Stack(
        children: [
          // Form(
          //   key: _formKey,
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              // TextButton(
              //   onPressed: _submitForm,
              //   child: const Text(
              //     '查詢',
              //     style: TextStyle(fontSize: 30),
              //   ),
              // ),
              if (_responseData != null) // Add this check here
                Expanded(
                  child: ListView.builder(
                    itemCount: _responseData.length,
                    // separatorBuilder: (context, index) => const Divider(
                    //   height: 5,
                    // ),
                    itemBuilder: (context, index) {
                      final data = _responseData[index];

                      return InkWell(
                          onTap: () async {
                            final confirmed = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      data['topic']!,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    const Divider(
                                      thickness: 1.5,
                                    )
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black),
                                          children: () {
                                            final RegExp regex = RegExp(
                                              r"(?:(?:https?|ftp):\/\/|www\.)[^\s/$.?#].[^\s]*|[\s\S]+?(?=(?:(?:https?|ftp):\/\/|www\.)[^\s/$.?#].[^\s]*|$)",
                                              caseSensitive: false,
                                            );
                                            final RegExp urlSeparatorRegex =
                                                RegExp(
                                              r'(?<=[^/])(?=https?://)',
                                            );
                                            final Iterable<Match> matches =
                                                regex.allMatches(
                                                    data['content']!);
                                            List<InlineSpan> children = [];
                                            for (Match match in matches) {
                                              if (match
                                                      .group(0)!
                                                      .startsWith('http') ||
                                                  match
                                                      .group(0)!
                                                      .startsWith('www') ||
                                                  match
                                                      .group(0)!
                                                      .startsWith('ftp')) {
                                                Iterable<Match>
                                                    separatedUrlMatches =
                                                    urlSeparatorRegex
                                                        .allMatches(
                                                            match.group(0)!);
                                                int previousUrlEnd = 0;
                                                for (Match separatedUrlMatch
                                                    in separatedUrlMatches) {
                                                  String url = match
                                                      .group(0)!
                                                      .substring(
                                                          previousUrlEnd,
                                                          separatedUrlMatch
                                                              .start);
                                                  children.add(TextSpan(
                                                    text: url,
                                                    style: const TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      color: Colors.blue,
                                                    ),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            launchUrl(
                                                                Uri.parse(url),
                                                                mode: LaunchMode
                                                                    .externalNonBrowserApplication);
                                                          },
                                                  ));
                                                  children.add(const TextSpan(
                                                      text: '\n'));
                                                  previousUrlEnd =
                                                      separatedUrlMatch.start;
                                                }
                                                String lastUrl = match
                                                    .group(0)!
                                                    .substring(previousUrlEnd);
                                                children.add(TextSpan(
                                                  text: lastUrl,
                                                  style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color: Colors.blue,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () async {
                                                          launchUrl(
                                                              Uri.parse(
                                                                  lastUrl),
                                                              mode: LaunchMode
                                                                  .externalNonBrowserApplication);
                                                        },
                                                ));
                                              } else {
                                                children.add(TextSpan(
                                                  text: match.group(0),
                                                ));
                                              }
                                              children.add(const TextSpan(
                                                text: "\n",
                                              ));
                                            }
                                            return children;
                                          }(),
                                        ),
                                      ),
                                      if (data['filename'] != '0' &&
                                          data['url'] != '0')
                                        InkWell(
                                          onTap: () => launchUrl(
                                              Uri.parse(data['url']!),
                                              mode: LaunchMode
                                                  .externalNonBrowserApplication),
                                          child: Text(
                                            '附件: ${data['filename']!}',
                                            style: const TextStyle(
                                                color: Colors.blue),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  NeumorphicButton(
                                    // style: const NeumorphicStyle(
                                    //   color: Color.fromARGB(255, 171, 245, 167),
                                    //   shape: NeumorphicShape.flat,
                                    // ),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('退出'),
                                  ),
                                  NeumorphicButton(
                                    style: const NeumorphicStyle(
                                      color: Color.fromARGB(255, 188, 250, 185),
                                      shape: NeumorphicShape.flat,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('前往課程'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              launchUrl(Uri.parse(data['href']!),
                                  mode:
                                      LaunchMode.externalNonBrowserApplication);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 1.5, horizontal: 8),
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          data['class']!,
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16.0, 16, 16, 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              extractMonthAndDay(data['date']!),
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const Icon(
                                              Icons.feed_outlined,
                                              color: Color.fromARGB(
                                                  255, 11, 167, 245),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30.0),
                                                child: Text(
                                                  data['topic']!,
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ));
                    },
                  ),
                )
            ],
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: const Color.fromARGB(181, 65, 218, 190),
      //   type: BottomNavigationBarType.shifting,
      //   showSelectedLabels: true,
      //   showUnselectedLabels: true,
      //   items: const [
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.assignment),
      //         label: '最新作業',
      //         backgroundColor: Color.fromARGB(181, 65, 218, 190)),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.format_list_bulleted),
      //         label: '最新公告',
      //         backgroundColor: Color.fromARGB(181, 65, 218, 190)),
      //   ],
      //   onTap: (int index) {
      //     switch (index) {
      //       case 0:
      //         if (ModalRoute.of(context)?.settings.name == '/homework') {
      //           return;
      //         }
      //         // Navigator.of(context).pushNamedAndRemoveUntil('/homework',ModalRoute.withName('/home'));
      //         Navigator.pushNamedAndRemoveUntil(
      //             context, '/homework', (route) => false);
      //         break;
      //       case 1:
      //         if (ModalRoute.of(context)?.settings.name == '/bulletins') {
      //           return;
      //         }
      //         // // Navigator.of(context).pushNamedAndRemoveUntil('/bulletins',ModalRoute.withName('/home'));
      //         // Navigator.pushNamedAndRemoveUntil(
      //         //     context, '/bulletins', (route) => false);
      //         break;
      //     }
      //   },
      // ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 149, 120),
        // automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('查詢最近公告(flipclass)'),
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
                context, '/homework', (route) => false)),
      ),
    );
  }
}
