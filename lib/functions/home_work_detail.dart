import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as html;

class HomeWorkDetailPage extends StatefulWidget {
  const HomeWorkDetailPage({Key? key}) : super(key: key);

  static const routeName = '/homework-detail';

  @override
  // ignore: library_private_types_in_public_api
  _HomeWorkDetailPageState createState() => _HomeWorkDetailPageState();
}

class _HomeWorkDetailPageState extends State<HomeWorkDetailPage> {
  late String topic;
  late String src;
  late String href;
  late String account;
  late String password;

  late Future<void> _homeworkFuture;
  var typeOfHomework = '';
  var openForSubmission = '';
  String? submissionDeadline = '';
  String? numberOfSubmissions = '';
  String? allowLateSubmission = '';
  String? gradeWeight = '';
  String? gradingMethod = '';
  String? detail = '';
  String? videoUrl = '';
  String? attachmentName = '';
  String? attachmentUrl = '';

  @override
  void initState() {
    super.initState();
    _homeworkFuture = sendHomework();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    topic = args['topic'];
    src = args['src'];
    href = args['href'];
    account = args['account'];
    password = args['password'];
  }

  Future<void> sendHomework() async {
    var homeworkCode = '';
    var session = http.Client();
    var response = await session
        .get(Uri.parse('https://flipclass.stust.edu.tw/index/login'));
    var soup = html.parse(response.body);

    var hiddenInput =
        soup.querySelector('input[name="csrf-t"]')!.attributes['value']!;

    var queryParameters = {
      '_fmSubmit': 'yes',
      'formVer': '3.0',
      'formId': 'login_form',
      'next': '/',
      'act': 'keep',
      'account': account,
      'password': password,
      'rememberMe': '',
      'csrf-t': hiddenInput,
    };

    final uri =
        Uri.https('flipclass.stust.edu.tw', '/index/login', queryParameters);

    response = await session.get(uri);

    if (response.headers['set-cookie'] == null) {
      print('Authenticate error(帳號密碼錯誤)');
      return;
    }
    var cookies = response.headers['set-cookie']!;

    var headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
      'cookie': cookies,
    };

    response = await session.get(
        Uri.parse(
            'https://flipclass.stust.edu.tw/course/homework/$homeworkCode'),
        headers: headers);
    soup = html.parse(response.body);
    print(soup);
// extract the desired data
    typeOfHomework = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '類型')
        .nextElementSibling!
        .text
        .trim();
    print(typeOfHomework);
    openForSubmission = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '開放繳交')
        .nextElementSibling!
        .text
        .trim();

    submissionDeadline = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '繳交期限')
        .nextElementSibling
        ?.querySelector('span')
        ?.text
        .trim();

    numberOfSubmissions = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '已繳交')
        .nextElementSibling
        ?.text
        .trim();
    allowLateSubmission = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '允許遲交')
        .nextElementSibling
        ?.text
        .trim();

    gradeWeight = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '成績比重')
        .nextElementSibling
        ?.text
        .trim();

    gradingMethod = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '評分方式')
        .nextElementSibling
        ?.text
        .trim();

    detail = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '說明')
        .nextElementSibling
        ?.text
        .trim();

    videoUrl = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '說明')
        .nextElementSibling
        ?.querySelector('a')
        ?.attributes['href'];

    attachmentName = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '附件')
        .nextElementSibling
        ?.querySelector('a')
        ?.text
        .trim();

    attachmentUrl = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '附件')
        .nextElementSibling
        ?.querySelector('a')
        ?.attributes['href'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text(topic),
        ),
        body: SizedBox(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  if (topic.isNotEmpty)
                    ListTile(
                      title: Text('Topic: $topic'),
                    ),
                  if (src.isNotEmpty)
                    ListTile(
                      title: Text('Class: $src'),
                    ),
                  if (typeOfHomework.isNotEmpty)
                    ListTile(
                      title: Text('Type of Homework: $typeOfHomework'),
                    ),
                  if (openForSubmission.isNotEmpty)
                    ListTile(
                      title: Text('Open for Submission: $openForSubmission'),
                    ),
                  if (numberOfSubmissions!.isNotEmpty)
                    ListTile(
                      title:
                          Text('Number of Submissions: $numberOfSubmissions'),
                    ),
                  if (allowLateSubmission!.isNotEmpty)
                    ListTile(
                      title:
                          Text('Allow Late Submission: $allowLateSubmission'),
                    ),
                  if (gradeWeight!.isNotEmpty)
                    ListTile(
                      title: Text('Grade Weight: $gradeWeight'),
                    ),
                  if (gradingMethod!.isNotEmpty)
                    ListTile(
                      title: Text('Grading Method: $gradingMethod'),
                    ),
                  if (detail!.isNotEmpty)
                    ListTile(
                      title: Text('Detail: $detail'),
                    ),
                  if (videoUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(videoUrl!)),
                      child: ListTile(
                        title: Text('Video URL: $videoUrl'),
                      ),
                    ),
                  if (attachmentUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: () => launchUrl(attachmentUrl as Uri),
                      child: ListTile(
                        title: Text('Attachment: $attachmentName'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
