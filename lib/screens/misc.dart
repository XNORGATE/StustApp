import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';
import '../utils/html_utils.dart';
import 'package:stust_app/utils/dialog_utils.dart';

import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

class StudentMiscPage extends StatefulWidget {
  static const routeName = '/student_misc';

  const StudentMiscPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentMiscPageState createState() => _StudentMiscPageState();
}

class Pages {
  late dynamic absentData;
  late dynamic foreignTestData;
  // late dynamic studentIndexData;
  late dynamic lostAndFoundData;
  late dynamic graduateData;
  late dynamic departmentOfficeData;

  Pages({
    required this.absentData, //  https://portal.stust.edu.tw/StudentPortfolio/Login.aspx
    required this.foreignTestData, //  https://portal.stust.edu.tw/StudentPortfolio/Login.aspx
    // required this.studentIndexData,
    required this.graduateData, //  https://portal.stust.edu.tw/StudentPortfolio/Login.aspx
    required this.departmentOfficeData, //ImageAsset +
    required this.lostAndFoundData,
  });
}

class _StudentMiscPageState extends State<StudentMiscPage>
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
      _submit();
    });

    _tabController = TabController(length: 4, vsync: this);
  }

  _getlocal_UserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _account = prefs.getString('account')!;
    _password = prefs.getString('password')!;

    return [_account, _password];
  }

  late bool _isLoading = true; // Flag to indicate if API request is being made

  Future<Pages> getPages() async {
    // List<Map<String, String>> absentEvent = [];

    var session = http.Client();
    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
    };

    final formData = {
      '__VIEWSTATE':
          '/wEPDwUKMTYwODgyOTkwMw9kFgICAw9kFgICAQ9kFgJmD2QWAgILDxAPFgIeB0NoZWNrZWRoZGRkZGQWKnTmzl1cURZoksJIMvq6hZTR7eDps+zEbINCwxd9Tg==',
      '__VIEWSTATEGENERATOR': '2999667C',
      '__EVENTVALIDATION':
          '/wEdAASYmZq8LXOFJcfnwypq+y6A8x5TPe4Fb2SCxWQFXQqD6Fz4Ff/mRdr9eJovHJ26GXDQt9u8Yj9aTUScKk9HMLRqm6Ke5f4MGOu/AFmm6vTqnEnxdSqixh050We0ftBDOGk=',
      'Login1\$UserName': _account,
      'Login1\$Password': _password,
      'Login1\$LoginButton': '登入'
    };
    // print(formData);

    var dio = Dio();
    Response resp;
    // try {
    resp = await dio.post(
      'https://portal.stust.edu.tw/StudentPortfolio/Login.aspx',
      data: formData,
      options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: true,
          validateStatus: (status) {
            return true;
          }),
    );
    // } catch (ex) {
    //   print("E");
    // }

    String cookies = resp.headers['set-cookie']!.join(";");
    // print(resp.data);

    ///go to departmentOfficeData
    var response = await session.get(
        Uri.parse('https://portal.stust.edu.tw/StudentPortfolio/Board.aspx'),
        headers: {...headers, 'cookie': cookies});

    var responseBodyHex = hex.encode(response.bodyBytes);
    var departmentOfficeData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
    // print(pressentScoreData.outerHtml);

    ///go to absentData
    response = await session.get(
        Uri.parse(
            'https://portal.stust.edu.tw/StudentPortfolio/Pages/Manager/DataBrowse.aspx?role=S'),
        headers: {...headers, 'cookie': cookies});

    responseBodyHex = hex.encode(response.bodyBytes);
    var absentData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

    ///go to foreignTestData
    response = await session.get(
        Uri.parse(
            'https://portal.stust.edu.tw/StudentPortfolio/Pages/stud_lang_grad/stud_lang_grad.aspx'),
        headers: {...headers, 'cookie': cookies});

    responseBodyHex = hex.encode(response.bodyBytes);
    var foreignTestData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

    //go to graduateData
    response = await session.get(
        Uri.parse(
            'https://portal.stust.edu.tw/StudentPortfolio/Pages/Manager/Student_Score.aspx?role=S'),
        headers: {...headers, 'cookie': cookies});

    responseBodyHex = hex.encode(response.bodyBytes);
    var graduateData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

    //
    response = await session.get(
        Uri.parse('https://aura.stust.edu.tw/life/lostthing.aspx'),
        headers: {...headers});

    responseBodyHex = hex.encode(response.bodyBytes);
    var lostAndFoundData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

    return Pages(
        absentData: absentData,
        foreignTestData: foreignTestData,
        graduateData: graduateData,
        departmentOfficeData: departmentOfficeData,
        lostAndFoundData: lostAndFoundData);
  }

  dynamic absentData = '';
  dynamic foreignTestData = '';
  dynamic graduateData = '';
  dynamic departmentOfficeData = '';
  dynamic lostAndFoundData = '';

  void _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await getPages();
      setState(() {
        _isLoading = false;

        absentData = res.absentData;
        foreignTestData = res.foreignTestData;
        graduateData = res.graduateData;
        departmentOfficeData = res.departmentOfficeData;
        lostAndFoundData = res.lostAndFoundData;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        showDialogBox(context, e.toString());
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
        backgroundColor: const Color.fromARGB(181, 65, 218, 190),
        title: const Text('網路選課系統'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '缺曠明細'),
            Tab(text: '外語檢定紀錄'),
            Tab(text: '南台人學習檔'),

            // Tab(text: '畢業學分'),
            // Tab(text: '學校各處室'),
            // Tab(text: '計算社團學分'),
            Tab(text: '失物招領'),
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
          // Center(child: CircularProgressIndicator()),
          // Center(child: CircularProgressIndicator()),
          // Center(child: CircularProgressIndicator())
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _absentData(context)),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _foreignTestData(context)),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _graduateData(context)),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _lostAndFoundData(context)),
        ],
      ),
    );
  }

  Widget _absentData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: HtmlWidget(
                extractHtmlContent(absentData.outerHtml, 'table',
                    id: 'ctl00_ContentPlaceHolder1_ctl00_GridView25', index: 0),
                onTapUrl: (url) => launchUrl(Uri.parse(url)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foreignTestData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: HtmlWidget(
                extractHtmlContent(foreignTestData.outerHtml, 'table',
                    id: 'ctl00_ContentPlaceHolder1_stud_lang_grad_uc1_GridView2',
                    index: 0),
                onTapUrl: (url) => launchUrl(Uri.parse(url)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _graduateData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HtmlWidget(
                      graduateData.outerHtml,
                      onTapUrl: (url) => launchUrl(Uri.parse(url)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lostAndFoundData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: HtmlWidget(
                extractHtmlContent(lostAndFoundData.outerHtml, 'table',
                    id: 'DataGrid1', index: 0),
                onTapUrl: (url) => launchUrl(Uri.parse(url)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//   Widget _departmentOfficeData(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: MediaQuery.of(context).size.width * 0.8,
//             height: MediaQuery.of(context).size.height * 0.8,
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: PhotoView(
//         imageProvider: Image.asset('assets/stustmap.png').image,
//         minScale: PhotoViewComputedScale.contained * 0.8,
//         maxScale: PhotoViewComputedScale.covered * 2,
//       ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//   Widget _reflectionData(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: MediaQuery.of(context).size.width * 0.8,
//             height: MediaQuery.of(context).size.height * 0.8,
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: HtmlWidget(
//                 extractHtmlContent(timeTable.outerHtml, 'table', 'style8',
//                     index: 0),
//                 onTapUrl: (url) => launchUrl(Uri.parse(url)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
