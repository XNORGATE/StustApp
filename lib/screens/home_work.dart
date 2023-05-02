import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'package:stust_app/screens/Bulletins.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import './home_work_detail.dart';
// import 'package:html/dom.dart';
import '../main.dart';

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
    WidgetsBinding.instance.addObserver(this);
    List<Map<String, String?>> responseData = [];
    _getlocal_UserData().then((data) {
      _account = data[0];
      _password = data[1];

      setState(() {});
    });

    _submitForm();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelToken = true;

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
          // print(doneButtonText);
          if (doneButtonText!.contains('檢視')) {
            isDone = '已繳交';
          }

          newData.add({
            'topic': topic ?? '',
            'src': src ?? '',
            'href': 'https://flipclass.stust.edu.tw$href',
            'date': date ?? '',
            'isDone': isDone
          });
        }

        if (mounted && !_cancelToken) {
          setState(() {
            _responseData = newData;
          });
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
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                if (_responseData != null) // Add this check here
                  Expanded(
                    child: ListView.separated(
                      itemCount: _responseData.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final data = _responseData[index];
                        bool isStringTooLong = data['topic']!.length > 15;

                        return InkWell(
                          onTap: () {
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
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Text(
                                    data['src']!,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Expanded(
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
                                      data['isDone'] == '未繳交'
                                          ? const Icon(
                                              Icons.assignment,
                                              color: Color.fromARGB(
                                                  255, 243, 79, 29),
                                            )
                                          : const Icon(
                                              Icons.done,
                                              color: Color.fromARGB(
                                                  255, 11, 167, 245),
                                            ),
                                      const SizedBox(
                                        width: 20,
                                      ),

                                      isStringTooLong
                                          ? Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Text(
                                                  data['topic']!,
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Expanded(child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                              Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 15.0),
                                                  child: Text(
                                                    data['topic']!,
                                                    style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),)

                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
        backgroundColor: const Color.fromARGB(181, 65, 218, 190),
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
              Navigator.of(context).pushNamed(HomeworkPage.routeName);
              break;
            case 1:
              Navigator.of(context).pushNamed(BulletinsPage.routeName);
              break;
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(181, 65, 218, 190),
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
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
