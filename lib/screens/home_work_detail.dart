import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as html;

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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
  String? detail = '無';
  String? videoUrl = '無';
  String? attachmentName = '無';
  String? attachmentUrl = '';
  String? embedYTvideoUrl = '';
  Uint8List? attachmentBytes;
  List EmbedYTList = [];
  int thumbnailCounter = 0;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _homeworkFuture = getHomework();
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

  String extractString(String originalString) {
    int index = originalString.indexOf("_");
    return index >= 0 ? originalString.substring(0, index) : originalString;
  }

  String getThumbnail(String Url) {
    String id = Url.substring(Url.length - 11);
    String thumbnail = 'https://img.youtube.com/vi/$id/0.jpg';
    // print(thumbnail);
    return thumbnail;
  }

  String? ThumbnailtoVideo(String Url) {
    List<String> parts = Url.split('/');
    // print(parts[parts.length - 2]);

    return parts.length >= 2
        ? 'https://youtu.be/${parts[parts.length - 2]}'
        : null;
  }

  Future<void> getHomework() async {
    // var homeworkCode = '';
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
      'act': 'kick',
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
      // Navigator.pop(context);
      return;
    }
    var cookies = response.headers['set-cookie']!;

    var headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
      'cookie': cookies,
    };

    response = await session.get(Uri.parse(href), headers: headers);
    soup = html.parse(response.body);
    // print(soup.outerHtml);
    // print(href);
    // print(src);

// extract the desired data
    typeOfHomework = soup
        .querySelectorAll('dt')
        .firstWhere((element) => element.text == '類型')
        .nextElementSibling!
        .text
        .trim();
    // print(typeOfHomework);
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

    try {
      detail = soup
          .querySelectorAll('dt')
          .firstWhere((element) => element.text == '說明')
          .nextElementSibling
          ?.text
          .trim();
    } catch (e) {
      // Handle the error here
    }

    try {
      final embedYTs = soup.querySelectorAll('iframe');

      for (var embedYT in embedYTs) {
        if (embedYT.attributes['src']!.contains('youtube')) {
          EmbedYTList.add(getThumbnail(embedYT.attributes['src']!));
          // print(getThumbnail(embedYT.attributes['src']!));
        }
      }
      // print(EmbedYTList);
    } catch (e) {}

    try {
      videoUrl = soup
          .querySelectorAll('dt')
          .firstWhere((element) => element.text == '說明')
          .nextElementSibling
          ?.querySelector('a')
          ?.attributes['href'];
    } catch (e) {
      // Handle the error here
    }

    try {
      attachmentName = soup
          .querySelectorAll('dt')
          .firstWhere((element) => element.text == '附件')
          .nextElementSibling
          ?.querySelector('a')
          ?.text
          .trim();
    } catch (e) {
      // Handle the error here
    }

    try {
      attachmentUrl = soup
          .querySelectorAll('dt')
          .firstWhere((element) => element.text == '附件')
          .nextElementSibling
          ?.querySelector('a')
          ?.attributes['href'];

      var attachment = await session.get(
          Uri.parse('https://flipclass.stust.edu.tw$attachmentUrl'),
          headers: headers);

      if (attachment.headers['content-type']!.contains("image")) {
        attachmentBytes = attachment.bodyBytes;
      }
    } catch (e) {
      // Handle the error here
    }

    // sleep(const Duration(seconds: 1));
    setState(() {
      isLoaded = true;
    });
  }

  Future<String> sendHomework(String href) async {
    // var homeworkCode = '';
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
      'act': 'kick',
      'account': account,
      'password': password,
      'rememberMe': '',
      'csrf-t': hiddenInput,
    };

    final uri =
        Uri.https('flipclass.stust.edu.tw', '/index/login', queryParameters);

    response = await session.get(uri);

    var cookies = response.headers['set-cookie']!;

    var headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
      'cookie': cookies,
    };

    response = await session.get(Uri.parse(href), headers: headers);
    soup = html.parse(response.body);

    ///進到作業頁面
    var iframeUrl = soup
        .querySelector("a[data-modal-title='交作業' ]")!
        .attributes['data-url']!;

    ///取得iframe的網址
    iframeUrl = "https://flipclass.stust.edu.tw$iframeUrl&fs_no_foot_js=1";
    print(iframeUrl);

    // print(soup.outerHtml);
    // print(href);
    // print(src);
    return iframeUrl;
  }

  dynamic _showIframe (String iframe) async{
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: const HtmlWidget('<iframe src="https://www.youtube.com/embed/jNQXAC9IVRw"></iframe>')
            ),
            actions: [
              TextButton(
                child: const Text('關閉'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // print(detail);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      appBar: AppBar(
        title: const Text('作業內容'),
        backgroundColor: Colors.green[200],
      ),
      body: SizedBox(
        child: isLoaded
            ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                    child: Text(
                      topic,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(
                    thickness: 1.5,
                    indent: 8,
                    endIndent: 8,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: Text(src)))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '開放繳交',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            strutStyle: StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                          Text(
                                            openForSubmission,
                                            strutStyle: const StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '繳交期限',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            strutStyle: StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                          Text(
                                            '$submissionDeadline',
                                            strutStyle: const StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '功課類型',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            strutStyle: StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                          Text(
                                            typeOfHomework,
                                            strutStyle: const StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '評分方式',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            strutStyle: StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                          Text(
                                            '$gradingMethod'
                                                .replaceAll("直接打分數", "直接評分"),
                                            strutStyle: const StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '允許遲交',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            strutStyle: StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                          Text(
                                            '$allowLateSubmission',
                                            strutStyle: const StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                            style: const TextStyle(
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '已交人數',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            strutStyle: StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                          Text(
                                            '$numberOfSubmissions',
                                            strutStyle: const StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '成績比重',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            strutStyle: StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                          Text(
                                            '$gradeWeight',
                                            strutStyle: const StrutStyle(
                                              forceStrutHeight: true,
                                              leading: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text(
                                  '說明',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            RichText(
                              // overflow: TextOverflow.clip,
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                                children: () {
                                  final RegExp regex = RegExp(
                                    r"(?:(?:https?|ftp):\/\/|www\.)[^\s/$.?#].[^\s]*|[\s\S]+?(?=(?:(?:https?|ftp):\/\/|www\.)[^\s/$.?#].[^\s]*|$)",
                                    caseSensitive: false,
                                  );
                                  final RegExp urlSeparatorRegex = RegExp(
                                    r'(?<=[^/])(?=https?://)',
                                  );
                                  final RegExp breaklineRegex =
                                      RegExp(r'\n|\r\n');

                                  final Iterable<Match> matches =
                                      regex.allMatches(detail!);
                                  List<InlineSpan> children = [];
                                  int breaklinecounter = 0;
                                  int thumbnailCounter = 0;
                                  for (Match match in matches) {
                                    if (match.group(0)!.startsWith('http') ||
                                        match.group(0)!.startsWith('www') ||
                                        match.group(0)!.startsWith('ftp')) {
                                      Iterable<Match> separatedUrlMatches =
                                          urlSeparatorRegex
                                              .allMatches(match.group(0)!);
                                      int previousUrlEnd = 0;
                                      for (Match separatedUrlMatch
                                          in separatedUrlMatches) {
                                        String url = match.group(0)!.substring(
                                            previousUrlEnd,
                                            separatedUrlMatch.start);
                                        children.add(TextSpan(
                                          text: url,
                                          style: const TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.blue,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              launchUrl(Uri.parse(url),
                                                  mode: LaunchMode
                                                      .externalNonBrowserApplication);
                                            },
                                        ));
                                        children
                                            .add(const TextSpan(text: '\n'));
                                        previousUrlEnd =
                                            separatedUrlMatch.start;
                                      }
                                      String lastUrl = match
                                          .group(0)!
                                          .substring(previousUrlEnd);
                                      children.add(TextSpan(
                                        text: lastUrl,
                                        style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            launchUrl(Uri.parse(lastUrl),
                                                mode: LaunchMode
                                                    .externalNonBrowserApplication);
                                          },
                                      ));
                                    } else {
                                      String textContent = match.group(0)!;
                                      while (textContent.isNotEmpty) {
                                        int breaklineCount = breaklineRegex
                                            .allMatches(textContent)
                                            .length;
                                        if (breaklineCount > 2 &&
                                            thumbnailCounter <
                                                EmbedYTList.length) {
                                          int endIndex =
                                              textContent.indexOf('\n\n\n');
                                          String textBeforeImage =
                                              endIndex == -1
                                                  ? textContent
                                                  : textContent.substring(
                                                      0, endIndex + 3);
                                          children.add(
                                              TextSpan(text: textBeforeImage));
                                          var ImageUrl =
                                              EmbedYTList[thumbnailCounter]!;
                                          children.add(WidgetSpan(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: InkWell(
                                                onTap: () {
                                                  launchUrl(
                                                      Uri.parse(
                                                          ThumbnailtoVideo(
                                                              ImageUrl)!),
                                                      mode: LaunchMode
                                                          .externalNonBrowserApplication);
                                                },
                                                child: Image.network(
                                                  ImageUrl,
                                                  fit: BoxFit.fitWidth,
                                                  width: double.infinity,
                                                ),
                                              ),
                                            ),
                                          ));
                                          thumbnailCounter++;

                                          endIndex = endIndex == -1
                                              ? endIndex
                                              : endIndex + 3;
                                          textContent = textContent
                                              .substring(endIndex)
                                              .trim();
                                          children.add(const TextSpan(
                                            text: "\n",
                                          ));
                                        } else {
                                          children.add(TextSpan(
                                            text: textContent,
                                          ));
                                          textContent = '';
                                        }
                                      }
                                    }
                                    children.add(const TextSpan(
                                      text: "\n",
                                    ));
                                  }
                                  thumbnailCounter = 0;
                                  // 移除多餘的 TextSpan (text=\n)
                                  print(children.removeLast());
                                  return children;
                                }(),
                              ),
                            ),
                            // if (attachmentName != "無")
                            //   const SizedBox(
                            //     height: 10,
                            //   ),
                            // if (attachmentName != "無")
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //     children: [
                            //       const Text(
                            //         '附件',
                            //         style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            //       ),
                            //       InkWell(
                            //         onTap: () => launchUrl(Uri.parse('https://flipclass.stust.edu.tw$attachmentUrl'), mode: LaunchMode.externalNonBrowserApplication),
                            //         child: Text(
                            //           '$attachmentName',
                            //           style: const TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // const SizedBox(height: 10)
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (attachmentName != "無")
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  Text(
                                    '附件',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () => launchUrl(
                                    Uri.parse(
                                        'https://flipclass.stust.edu.tw$attachmentUrl'),
                                    mode: LaunchMode
                                        .externalNonBrowserApplication),
                                child: Row(
                                  children: [
                                    const Icon(Icons.file_present),
                                    Text(
                                      '$attachmentName',
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              if (attachmentBytes != null)
                                Image.memory(attachmentBytes!)
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                      padding:
                          EdgeInsets.fromLTRB(width * .35, 5, width * .35, 5),
                      child: InkWell(
                        onTap: () async {
                          var iframe = await sendHomework(href);
                          
                          iframe = '<iframe src="$iframe" frameborder="0" border="0" style="display: inline;"></iframe>';
                          await _showIframe(iframe);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.send,
                            ),
                          ),
                        ),
                      ))
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
