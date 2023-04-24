import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

class StudentPortfolioPage extends StatefulWidget {
  static const routeName = '/student_portfolio';

  const StudentPortfolioPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentPortfolioPageState createState() => _StudentPortfolioPageState();
}

class Pages {
  late dynamic pressentScoreData;
  late dynamic pastScoreData;
  late dynamic timeTableData;

  Pages(
      {required this.pressentScoreData,
      required this.pastScoreData,
      required this.timeTableData});
}

class _StudentPortfolioPageState extends State<StudentPortfolioPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _account = '0'; // Set account and password to 0 by default
  late String _password = '0';
  @override
  void initState() {
    super.initState();
    _getlocal_UserData().then((data) {
      _account = data[0];
      _password = data[1];
      //print(_account);
      //print(_password);
      setState(() {});
    });
    _submit();

    _tabController = TabController(length: 3, vsync: this);
  }

  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          // content: Text(href),
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

  _getlocal_UserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _account = prefs.getString('account')!;
    _password = prefs.getString('password')!;

    return [_account, _password];
  }

  late bool _isLoading = false; // Flag to indicate if API request is being made

  Future<Pages> getPages() async {
    // List<Map<String, String>> absentEvent = [];

    var session = http.Client();
    // print(_account);
    // print(_password);

    // print(_account);
    // final uri = Uri.https(
    //     'portal.stust.edu.tw', '/abs_stu/verify.asp', formData);
    //authenticate
    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
    };

    // var response = await session
    //     .get(Uri.parse('https://course.stust.edu.tw/CourSel/Login.aspx'),
    //         // body: formData,
    //         headers: {...headers});

    // var soup = html_parser.parse(response.body);
    // var viewState =
    //     soup.querySelector('input[name="__VIEWSTATE"]')?.attributes['value'];
    // var viewStateGenerator = soup
    //     .querySelector('input[name="__VIEWSTATEGENERATOR"]')
    //     ?.attributes['value'];
    // var eventValidation = soup
    //     .querySelector('input[name="__EVENTVALIDATION"]')
    //     ?.attributes['value'];

    final formData = {
      '__VIEWSTATE': '/wEPDwUIODc3ODc3MTlkZGs0hjL5S9HpSDL/Su6nK8R121w8',
      '__VIEWSTATEGENERATOR': '975AEEEC',
      '__EVENTVALIDATION':
          '/wEWBQLHlriDAQKUvNa1DwL666vYDAKnz4ybCALM9PumD7O1wjaAeVtrt6/GmxTQRUri0zMA',
      'Login1\$UserName': _account,
      'Login1\$Password': _password,
      'Login1\$LoginButton': '登入'
    };
    print(formData);

    var dio = Dio();
    Response resp;
    // try {
      resp = await dio.post(
        'https://course.stust.edu.tw/CourSel/Login.aspx',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
        validateStatus: (status) { return true; }
          ),
      );
    // } catch (ex) {
    //   print("E");
    // }

    /// login
    ///
    // final uri =
    //     Uri.https('course.stust.edu.tw', '/CourSel/Login.aspx', formData);
    // //authenticate
    // var response = await session.post(uri);
    // response = await session.post(
    //     Uri.parse('https://course.stust.edu.tw/CourSel/Login.aspx'),
    //     headers: {...headers},
    //     body: formData);
    // var cookies = response.headers['set-cookie']!;

    // print(response.bodyBytes);
    // var responseBodyHex = hex.encode(response.);
    // var data = utf8.decode(hex.decode(responseBodyHex));
    // print(response.headers.values);
    // print(cookies);
    // print(response.statusCode);
    // if (response.statusCode == 302) {
    //   print(response.headers['Location']!);
    //   response = await session.get(Uri.https(response.headers['Location']!));
    // }

    // var responseBodyHex = hex.encode(response.bodyBytes);
    // var soup = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
    // print(soup.outerHtml);

    print(resp.headers['set-cookie']);
    String cookies = resp.headers['set-cookie']!.join(";");
    print(cookies);

    ///go to pressentScore
    var response = await session.get(
        Uri.parse(
            'https://course.stust.edu.tw/CourSel/Pages/PresentScore.aspx?role=S'),
        headers: {...headers, 'cookie': cookies});

    var responseBodyHex = hex.encode(response.bodyBytes);
    var pressentScoreData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
    // print(pressentScoreData.outerHtml);

    ///go to pastScore
    response = await session.get(
        Uri.parse(
            'https://course.stust.edu.tw/CourSel/Pages/PastScore.aspx?role=S'),
        headers: {...headers, 'cookie': cookies});

    responseBodyHex = hex.encode(response.bodyBytes);
    var pastScoreData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

    ///go to timeTable
    response = await session.get(
        Uri.parse(
            'https://course.stust.edu.tw/CourSel/Pages/MyTimeTable.aspx?role=S'),
        headers: {...headers, 'cookie': cookies});

    responseBodyHex = hex.encode(response.bodyBytes);
    var timeTableData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

    return Pages(
        pressentScoreData: pressentScoreData,
        pastScoreData: pastScoreData,
        timeTableData: timeTableData);
  }

  dynamic pressentScore = '';
  dynamic pastScore = '';
  dynamic timeTable = '';

  void _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await getPages();
      setState(() {
        _isLoading = false;
        pressentScore = res.pressentScoreData;
        pastScore = res.pastScoreData;
        timeTable = res.timeTableData;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showDialog(e.toString());
      });
    }
    // }
  }

  // void _submitpastScore() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final res = await getPressentScore();
  //     setState(() {
  //       _isLoading = false;
  //       _pastScoreData = res;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //       _showDialog(e.toString());
  //     });
  //   }
  //   // }
  // }

  // void _submittimeTable() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final res = await getPressentScore();
  //     setState(() {
  //       _isLoading = false;
  //       _timeTableData = res;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //       _showDialog(e.toString());
  //     });
  //   }
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('網路選課系統'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '現在成績'),
            Tab(text: '歷年成績'),
            Tab(text: '課表'),
          ],
          onTap: (int index) {
            // switch (index) {
            //   case 0:
            //     _submitpressentScore();
            //     break;
            //   case 1:
            //     _submitpastScore();
            //     break;
            //   case 2:
            //     _submittimeTable();
            //     break;
            // }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pressentScore(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pastScore(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _timetable(),
        ],
      ),
    );
  }

  Widget _pressentScore() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: HtmlWidget(pressentScore.outerHtml),
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigator.pushNamed(context, '/skill-contest-info-detail',
          //     arguments: {'title': title, 'content': content});
        },
      ),
    );
  }

  Widget _pastScore() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: HtmlWidget(pastScore.outerHtml),
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigator.pushNamed(context, '/skill-contest-info-detail',
          //     arguments: {'title': title, 'content': content});
        },
      ),
    );
  }

  Widget _timetable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: HtmlWidget(timeTable.outerHtml),
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigator.pushNamed(context, '/skill-contest-info-detail',
          //     arguments: {'title': title, 'content': content});
        },
      ),
    );
  }
}
