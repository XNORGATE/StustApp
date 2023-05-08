import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as html_parser;
import 'package:photo_view/photo_view.dart';
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
  // late dynamic absentData;
  late dynamic foreignTestData;
  // late dynamic studentIndexData;
  late dynamic lostAndFoundData;
  late dynamic graduateData;
  late dynamic departmentOfficeData;
  late int totalcredit;
  Pages({
    // required this.absentData, //  https://portal.stust.edu.tw/StudentPortfolio/Login.aspx
    required this.foreignTestData, //  https://portal.stust.edu.tw/StudentPortfolio/Login.aspx
    // required this.studentIndexData,
    required this.graduateData, //  https://portal.stust.edu.tw/StudentPortfolio/Login.aspx
    required this.departmentOfficeData, //ImageAsset +
    required this.lostAndFoundData,
    required this.totalcredit,
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
  
  @override
  void dispose() {
    http.Client().close();
    super.dispose();
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
    // response = await session.get(
    //     Uri.parse(
    //         'https://portal.stust.edu.tw/StudentPortfolio/Pages/Manager/DataBrowse.aspx?role=S'),
    //     headers: {...headers, 'cookie': cookies});

    // responseBodyHex = hex.encode(response.bodyBytes);
    // var absentData =
    //     html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

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
    int totalcredit = 0;
    var graduateData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));

    var graduateTable = graduateData
        .querySelector('#ctl00_ContentPlaceHolder1_ctl00_GridView1');
    var graduateTableRows = graduateTable!.querySelectorAll('tr');
    try {
      // print(graduateTableRows.);
      for (int i = 1; i < graduateTableRows.length; i++) {
        if (graduateTableRows[i].attributes['style'] == null ||
            graduateTableRows[i].attributes['style'] ==
                'background-color:#FEEBAB;') {
          totalcredit += int.parse(
              graduateTableRows[i].querySelectorAll('td')[5].text.trim());
        }

        // print(graduateTableRows[i].styles.getPropertyValue('background-color'));
      }
    } catch (e) {
      print('error$e');
    }
    // print(totalcredit);
    // print(graduateTable.styles);
    // var failedClass = graduateTable.querySelectorAll('tr[style="background-color:#FFC4E1;"]');
    // for (int j=1; j < graduateTableRows.length; j++){

    // }
    // print(failedClass);

    //
    response = await session.get(
        Uri.parse('https://aura.stust.edu.tw/life/lostthing.aspx'),
        headers: {...headers});

    cookies = response.headers['set-cookie']!;

    responseBodyHex = hex.encode(response.bodyBytes);
    List fullPage = [];

    var lostAndFoundData =
        html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
    fullPage.add(lostAndFoundData);
    for (int i = 1; i < 5; i++) {
      var hiddenInput = lostAndFoundData
          .querySelector('input[name="__VIEWSTATE"]')
          ?.attributes['value'];

      final queryParameters = {
        '__EVENTTARGET': 'DataGrid1:_ctl1:_ctl$i', //從第二頁開始爬
        '__EVENTARGUMENT': '_password',
        '__VIEWSTATE': hiddenInput,
        '__VIEWSTATEGENERATOR': 'E8D08EA4'
      };
      response = await session.post(
          Uri.parse('https://aura.stust.edu.tw/life/lostthing.aspx'),
          headers: {...headers, 'cookie': cookies},
          body: queryParameters);
      responseBodyHex = hex.encode(response.bodyBytes);

      var lostAndFoundpage =
          html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
      fullPage.add(lostAndFoundpage);
    }

    return Pages(
        // absentData: absentData,
        foreignTestData: foreignTestData,
        graduateData: graduateData,
        departmentOfficeData: departmentOfficeData,
        lostAndFoundData: fullPage,
        totalcredit: totalcredit);
  }

  // dynamic absentData = '';
  dynamic foreignTestData = '';
  dynamic graduateData = '';
  dynamic departmentOfficeData = '';
  dynamic lostAndFoundData = '';
  int totalcredit = 0;
  void _submit() async {
// String removeTags(String html) {
//   RegExp exp = RegExp(r'<div align="right">|<tr class="PagerCss" align="Center">');
//   String newHtml = html.replaceAll(exp, '');
//   print(newHtml);
//   return newHtml;
// }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await getPages();
      setState(() {
        _isLoading = false;

        // absentData = res.absentData;
        foreignTestData = res.foreignTestData;
        graduateData = res.graduateData;
        departmentOfficeData = res.departmentOfficeData;
        lostAndFoundData = res.lostAndFoundData;
        // lostAndFoundData = removeTags(extractHtmlContent(
        //     res.lostAndFoundData.outerHtml, 'div',
        //     className: 'BOX', index: 1));

        totalcredit = res.totalcredit;
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
        centerTitle: true,
        backgroundColor: const Color.fromARGB(181, 65, 218, 190),
        title: const Text('學生其他事項'),
        bottom: TabBar(
          controller: _tabController,
          // isScrollable: true,
          tabs: const [
            // Tab(text: '缺曠明細'),
            Tab(text: '外語檢定紀錄'),
            Tab(text: '修課學分'),

            // Tab(text: '畢業學分'),
            Tab(text: '學校各處室'),
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
              : _foreignTestData(context),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _graduateData(context)),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _departmentOfficeData(context)),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _lostAndFoundData(context)),
        ],
      ),
    );
  }

  // Widget _absentData(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.all(10.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: MediaQuery.of(context).size.width * 0.8,
  //           height: MediaQuery.of(context).size.height * 0.8,
  //           child: FittedBox(
  //             fit: BoxFit.scaleDown,
  //             child: HtmlWidget(
  //               extractHtmlContent(absentData.outerHtml, 'table',
  //                   id: 'ctl00_ContentPlaceHolder1_ctl00_GridView25', index: 0),
  //               onTapUrl: (url) => launchUrl(Uri.parse(url)),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _foreignTestData(BuildContext context) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 75, 75, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.125,
                height: height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height *.08,),
                    FittedBox(
              fit: BoxFit.contain,
                      child: HtmlWidget(
                        extractHtmlContent(foreignTestData.outerHtml, 'div',
                            className: 'conplace', index: 0),
                        // onTapUrl: (url) => launchUrl(Uri.parse(url)),
                      textStyle: const TextStyle(fontSize: 15.1),),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _graduateData(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.8,
            height: height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height*.2,),
                FittedBox(
                  fit: BoxFit.none,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HtmlWidget(
                          extractHtmlContent(graduateData.outerHtml, 'div',
                              // id: 'ctl00_ContentPlaceHolder1_ctl00_GridView2',
                              index: 19),
                        textStyle: const TextStyle(fontSize: 25)),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          thickness: 5,
                          color: Color.fromARGB(255, 16, 14, 14),
                        ),
                        Row(
                          children: [
                            Text(
                              '目前已修課學分: $totalcredit',
                              style: const TextStyle(fontSize: 20),
                            ),
                            totalcredit >= 128
                                ? const Text(
                                    '  已修滿畢業學分(128)',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.green),
                                  )
                                : const Text(
                                    '  尚未修滿畢業學分(128)',
                                    style:
                                        TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lostAndFoundData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: FittedBox(
                fit: BoxFit.contain,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _infoRow(context, 0),
                      HtmlWidget(extractHtmlContent(
                          lostAndFoundData[0].outerHtml, 'div',
                          className: 'BOX', index: 1)),
                    ],
                  ),
                )),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  _infoRow(context, 1),
                  HtmlWidget(extractHtmlContent(
                      lostAndFoundData[1].outerHtml, 'div',
                      className: 'BOX', index: 1)),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  _infoRow(context, 2),
                  HtmlWidget(extractHtmlContent(
                      lostAndFoundData[2].outerHtml, 'div',
                      className: 'BOX', index: 1)),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  _infoRow(context, 3),
                  HtmlWidget(extractHtmlContent(
                      lostAndFoundData[3].outerHtml, 'div',
                      className: 'BOX', index: 1)),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  _infoRow(context, 4),
                  HtmlWidget(extractHtmlContent(
                      lostAndFoundData[4].outerHtml, 'div',
                      className: 'BOX', index: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _departmentOfficeData(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.9,
            height: height * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                          SizedBox(height: height* .2,),

                FittedBox(
                  fit: BoxFit.none,
                  child: HtmlWidget(
                    extractHtmlContent(departmentOfficeData.outerHtml, 'div',
                        className: 'conplace', index: 0),
                    // textStyle: const TextStyle(fontSize: 50),
                  textStyle: const TextStyle(fontSize: 7),),
                ),

              ],
            ),
          ),
          SizedBox(
            width: width * 0.8,
            height: height * 0.8,
            // child: SingleChildScrollView(
            child: PhotoView(
              imageProvider: const AssetImage('assets/stustmap.png'),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            // ),
          ),
        ],
      ),
    );
  }
}

Widget _infoRow(BuildContext context, int index) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Center(
        child: Text(
          '第${index+1}頁',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: const [
          Text(
            '編號',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 30),
          Text(
            '公告日期',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 30),
          Text(
            '物品名稱',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 30),
          Text(
            '數量',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 30),
          Text(
            '簽領情形',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 30),
          Text(
            '簽領日期',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ],
  );
}
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
