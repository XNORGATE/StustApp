import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'package:stust_app/functions/Bulletins.dart';
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

class _HomeworkPageState extends State<HomeworkPage> {
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

    _submitForm();
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

          newData.add({
            'topic': topic ?? '',
            'src': src ?? '',
            'href': 'https://flipclass.stust.edu.tw$href',
            'date': date ?? '',
          });
        }

        setState(() {
          _responseData = newData;
        });

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

    try {
      final responseData = await getHomework();
      setState(() {
        _responseData = responseData;
        _isLoading = false;
      });
          // sleep(const Duration(seconds: 1));

    } catch (e) {
      setState(() {
        _isLoading = false;
        _showAlertDialog(e.toString(), e.toString());
      });
    }
    // }
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
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeWorkDetailPage(),
                                settings: RouteSettings(arguments: {
                                'topic': data['topic'],
                                'src':  data['src'],
                                'href':  data['href'],
                                'account': _account,
                                'password': _password,
                                }),
                              ),
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['topic']!,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
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
        type: BottomNavigationBarType.shifting,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: '最新作業',
              backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: '最新公告',
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

        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
