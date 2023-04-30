import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:stust_app/screens/home_work.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

class BulletinsPage extends StatefulWidget {
  static const routeName = '/bulletins';

  const BulletinsPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _BulletinsPageState createState() => _BulletinsPageState();
}

class _BulletinsPageState extends State<BulletinsPage> {
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
      //print(_account);
      //print(_password);

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
  //           'http://api.xnor-development.com:70/homework?account=$_account&password=$_password'),
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

  Future<List<Map<String, String>>> gen_bulletin() async {
    int bulletinPage = 1;
    List<Map<String, String>> Bulletin = [];

    var session = http.Client();
    var loginUrl = 'https://flipclass.stust.edu.tw/index/login';
    var response = await session.get(Uri.parse(loginUrl));
    http.Response detail;
    var soup = parse(response.body);

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
    var url = 'https://flipclass.stust.edu.tw/dashboard/latestBulletin?&page=';

    void gen_bulletin(int bulletinPage) async {
      response = await session.get(Uri.parse('$url${bulletinPage.toString()}'),
          headers: {...headers, 'cookie': cookies});
      soup = parse(response.body);

      if (soup.querySelector('#noData > td') == null) {
        var hrefArr = soup.querySelectorAll(
            'td.text-center.col-char7 > div.text-overflow > a');
        // print(hrefArr);
        var works = soup.querySelectorAll('tbody > tr');

        var newData = List<Map<String, String>>.from(
            _responseData); // Create new list object

        for (int i = 0; i < works.length; i++) {
          var topic =
              works[i].querySelector('a.fs-bulletin-item > span')?.text.trim();
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
          var detail = await session
              .get(Uri.parse(src), headers: {...headers, 'cookie': cookies});
          var detailRes = parse(detail.body);
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

        setState(() {
          _responseData = newData;
        });

        bulletinPage++;
        gen_bulletin(bulletinPage);
      }
    }

    gen_bulletin(bulletinPage);
    return Bulletin;
  }

  void _submitForm() async {
    // if (!_formKey.currentState!.mounted) {
    //   return;
    // }

    // if (_formKey.currentState!.validate()) {
    //   _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final responseData = await gen_bulletin();
      setState(() {
        _responseData = responseData;
        _isLoading = false;
      });
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
                // TextButton(
                //   onPressed: _submitForm,
                //   child: const Text(
                //     '查詢',
                //     style: TextStyle(fontSize: 30),
                //   ),
                // ),
                if (_responseData != null) // Add this check here
                  Expanded(
                    child: ListView.separated(
                      itemCount: _responseData.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final data = _responseData[index];
                        return InkWell(
                          onTap: () async {
                            final confirmed = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                title: Text(
                                  data['topic']!,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(data['content']!),
                                      if (data['filename'] != '0' &&
                                          data['url'] != '0')
                                        InkWell(
                                          onTap: () => launchUrl(
                                              Uri.parse(data['url']!),mode: LaunchMode.externalNonBrowserApplication),
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
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('退出'),
                                  ),
                                  NeumorphicButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('前往課程'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              launchUrl(Uri.parse(data['href']!),mode: LaunchMode.externalNonBrowserApplication);
                            }
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${data['date']!} ${data['class']} : ${data['topic']!}',
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // IconButton(
                                  //   icon: Icon(
                                  //     _isFavorite(newsTitle)
                                  //         ? Icons.favorite
                                  //         : Icons.favorite_border,
                                  //   ),
                                  //   onPressed: () {
                                  //     _toggleFavorite(newsTitle);
                                  //   },
                                  // ),
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
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.calendar_today),
          //     label: '曠課與遲到',
          //     backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.question_answer),
          //     label: '未繳心得',
          //     backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.add_box),
          //     label: '請假',
          //     backgroundColor: Color.fromARGB(255, 40, 105, 218)),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.send),
          //     label: '快速繳交作業',
          //     backgroundColor: Color.fromARGB(255, 40, 105, 218)),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushNamed(HomeworkPage.routeName);
              break;
            case 1:
              Navigator.of(context).pushNamed(BulletinsPage.routeName);
              break;
            // case 2:
            //   Navigator.of(context).pushNamed(AbsentPage.routeName);
            //   break;
            // case 3:
            //   Navigator.of(context).pushNamed(ReflectionPage.routeName);
            //   break;
            // case 4:
            //   Navigator.of(context).pushNamed(LeaveRequestPage.routeName);
            //   break;
            // case 5:
            //   Navigator.of(context).pushNamed(SendHomeworkPage.routeName);
            //   break;
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(181, 65, 218, 190),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('查詢最近公告(flipclass)'),
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
