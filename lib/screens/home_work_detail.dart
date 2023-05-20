import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';

import '../main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' as html;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../utils/check_connecion.dart';

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
  String isDone = '交作業';

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
                  onPressed: () {
                    // Navigator.of(context).pop();
                    // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    FlutterExitApp.exitApp();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      try {
        _homeworkFuture = getHomework();
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!mounted) return;
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

    var doneButtonText = soup
        .querySelector('div.text-center.fs-margin-default > a > span')
        ?.text
        .trim();

    if (doneButtonText!.contains('檢視')) {
      isDone = '收回並刪除作業';
    } else {
      isDone = '交作業';
    }
    print('isDone: $isDone');
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
    try {
      setState(() {
        isLoaded = true;
      });
    } catch (e) {}
  }

  Future<dynamic> sendHomeworkWithFiles(
      String href, String content, List finalFiles) async {
    // var homeworkCode = '';
    var session = http.Client();

    var response = await session
        .get(Uri.parse('https://flipclass.stust.edu.tw/index/login'));
    var soup = html.parse(response.body);

    String? hiddenInput =
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

    response = await session.get(
      Uri.parse(href),
      headers: {...headers},
    );
    soup = html.parse(response.body);

    ///進到作業頁面
    var iframeUrl = soup
        .querySelector("a[data-modal-title='交作業' ]")!
        .attributes['data-url']!;

    ///取得iframe的網址
    iframeUrl = "https://flipclass.stust.edu.tw$iframeUrl&fs_no_foot_js=1";
    // iframeUrl = iframeUrl;

    // print(iframeUrl);

    response = await session.get(
      Uri.parse(iframeUrl),
      headers: {...headers},
    );
    soup = html.parse(response.body); // 進到iframe
    hiddenInput =
        soup.querySelector('input[name="csrf-t"]')?.attributes['value'];
    var titleInput =
        soup.querySelector('input[name="title"]')?.attributes['value'];
    print('hiddenInput: $hiddenInput');
    print('title_input: $titleInput');

    var finalUrl =
        soup.querySelector('form[id="media-edit-form"]')!.attributes['action'];

    print('finalUrl: $finalUrl');
    // print('soup: ${soup.outerHtml}');

    List scripts = soup.getElementsByTagName('script');
    // String firstUrlPath = '';
    String secondUrlPath = '';
    // // Define a regular expression pattern for the strings.
    // RegExp regExp1 = RegExp(r'"fetchUrl":"(.*?)"');

    // // Iterate over the script tags.
    // for (var script in scripts) {
    //   // Get the JavaScript code.
    //   String jsCode = script.innerHtml;
    //   // print('jsCode: $jsCode');
    //   // Use the allMatches method to get all matches.
    //   Iterable<RegExpMatch> matches = regExp1.allMatches(jsCode);

    //   // Extract the strings from the matches.
    //   for (RegExpMatch match in matches) {
    //     String string = match.group(0)!;
    //     firstUrlPath = string;
    //     // print('firstUrlPath: $firstUrlPath');
    //   }
    // }
    // print('firstUrlPath: $firstUrlPath');

    RegExp regExp = RegExp(
        r'uploadUrl\":\"\\/ajax\\/sys.modules.mod_fileUpload2\\/upload\\/\?([^"]*)');

    // Iterate over the script tags.
    for (var script in scripts) {
      // Get the JavaScript code.
      String jsCode = script.innerHtml;

      // Use the allMatches method to get all matches.
      Iterable<RegExpMatch> matches = regExp.allMatches(jsCode);

      // Extract the strings from the matches.
      for (RegExpMatch match in matches) {
        String string = match.group(0)!;
        // Split the string by the question mark '?'
        List<String> splitString = string.split('?');

        // Check if the split produced two parts
        if (splitString.length == 2) {
          String result = splitString[1];
          secondUrlPath = result;
        }

        // print('secondUrlPath: $secondUrlPath');
      }
    }
    print('secondUrlPath: $secondUrlPath');

    // var firstUrl =
    //     'https://flipclass.stust.edu.tw/ajax/sys.pages.attach_get/tempItems/?$firstUrlPath';
    // print(firstUrl);
    // response = await session.get(
    //   // first request (after click and loading iframe)
    //   Uri.parse(firstUrl),
    //   headers: {...headers},
    // );

    var secondUrl =
        'https://flipclass.stust.edu.tw/ajax/sys.modules.mod_fileUpload2/upload/?$secondUrlPath';

    for (var file in finalFiles) {
      String fname = file.name;
      FormData data = FormData.fromMap({
        'action': 'submit',
        'title': titleInput,
        'content': '',
        'csrf-t': hiddenInput,
        "files[]": await MultipartFile.fromFile(
          file.path,
          filename: fname,
        ),
      });

      Dio dio = Dio();

      print('Image File Name: $fname');
      var response = await dio.post(
        secondUrl,
        data: data,
        options: Options(
          // contentType: 'multipart/form-data',
          followRedirects: false,
          headers: {...headers},
        ),
      );

      print('response.statusCode: ${response.statusCode}');
      print('response.data: ${response.data}');
    }

    var formData = {
      '_fmSubmit': 'yes',
      'formVer': '3.0',
      'formId': 'media-edit-form',
      'action': 'submit',
      'title': titleInput,
      'content': '<div>$content</div>',
      'csrf-t': hiddenInput
    };

    response = await session.post(
        Uri.parse('https://flipclass.stust.edu.tw$finalUrl'),
        headers: {...headers},
        body: formData);

    ///最終繳交

    var isDoneresponse = await session.get(
        //確認繳交
        Uri.parse(href),
        headers: {...headers, 'cookie': cookies});
    var isDonesoup = html.parse(isDoneresponse.body);

    // bool isDone = false;
    // print(soup.outerHtml);
    var doneButtonText = isDonesoup
        .querySelector('div.text-center.fs-margin-default > a > span')
        ?.text
        .trim();
    if (doneButtonText!.contains('檢視')) {
      // isDone = true;
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> sendHomeworkOnlyText(String href, String content) async {
    // var homeworkCode = '';
    var session = http.Client();
    var response = await session
        .get(Uri.parse('https://flipclass.stust.edu.tw/index/login'));
    var soup = html.parse(response.body);

    String? hiddenInput =
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

    response = await session.get(
      Uri.parse(href),
      headers: {...headers},
    );
    soup = html.parse(response.body);

    ///進到作業頁面
    var iframeUrl = soup
        .querySelector("a[data-modal-title='交作業' ]")!
        .attributes['data-url']!;

    ///取得iframe的網址
    iframeUrl = "https://flipclass.stust.edu.tw$iframeUrl&fs_no_foot_js=1";
    // iframeUrl = iframeUrl;

    // print(iframeUrl);

    response = await session.get(
      Uri.parse(iframeUrl),
      headers: {...headers},
    );
    soup = html.parse(response.body); // 進到iframe
    hiddenInput =
        soup.querySelector('input[name="csrf-t"]')?.attributes['value'];
    var titleInput =
        soup.querySelector('input[name="title"]')?.attributes['value'];
    print('hiddenInput: $hiddenInput');
    print('title_input: $titleInput');

    var finalUrl =
        soup.querySelector('form[id="media-edit-form"]')!.attributes['action'];
    // .replaceAll('https://flipclass.stust.edu.tw', '');

    print('finalUrl: $finalUrl');

    var formData = {
      '_fmSubmit': 'yes',
      'formVer': '3.0',
      'formId': 'media-edit-form',
      'action': 'submit',
      'title': titleInput,
      'content': '<div>$content</div>',
      'csrf-t': hiddenInput
    };

    response = await session.post(
        Uri.parse('https://flipclass.stust.edu.tw$finalUrl'),
        headers: {...headers},
        body: formData);

    ///最終繳交

    var isDoneresponse = await session.get(
        //確認繳交
        Uri.parse(href),
        headers: {...headers, 'cookie': cookies});
    var isDonesoup = html.parse(isDoneresponse.body);

    // print(soup.outerHtml);
    var doneButtonText = isDonesoup
        .querySelector('div.text-center.fs-margin-default > a > span')
        ?.text
        .trim();
    if (doneButtonText!.contains('檢視')) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteHomework() async {
    // var homeworkCode = '';
    var session = http.Client();
    var response = await session
        .get(Uri.parse('https://flipclass.stust.edu.tw/index/login'));
    var soup = html.parse(response.body);

    String? hiddenInput =
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

    response = await session.get(
      Uri.parse(href),
      headers: {...headers},
    );
    soup = html.parse(response.body);

    // print(soup.outerHtml);
    var editUrl = soup
        .querySelector('div.text-center.fs-margin-default > a')!
        .attributes['href']!;

    response = await session.get(
      Uri.parse('https://flipclass.stust.edu.tw$editUrl'),
      headers: {...headers},
    );
    soup = html.parse(response.body);

    String extractURL(String htmlString) {
      RegExp regExp = RegExp(r"fs\.post\('(.*?)',");
      Match? match = regExp.firstMatch(htmlString);
      return match?.group(1) ?? '';
    }
    // List scripts = soup.getElementsByTagName('script');

    String url = extractURL(soup.outerHtml); //收回的URL
    print('retrieve_url: $url');

    Dio dio = Dio();

    var Dioresponse = await dio.post(
      'https://flipclass.stust.edu.tw$url',
      options: Options(
        // contentType: 'multipart/form-data',
        followRedirects: true,
        headers: {...headers},
      ),
    );

    // RegExp regExp = RegExp(r'reportId=(\d+)&');
    // Match? match = regExp.firstMatch(url);
    // String? reportID = '';
    // if (match != null) {
    //   reportID = match.group(1);
    //   print(reportID);
    // } else {
    //   print('No match found');
    // }

    response = await session.get(
      Uri.parse('https://flipclass.stust.edu.tw$editUrl'),
      headers: {...headers},
    );

    soup = html.parse(response.body);

    // print(Dioresponse.data.toString());
    // print(Dioresponse.data);
    // print('soup: $soup');
    // print('soup.outerHtml ${soup.outerHtml}');
    List scripts = soup.getElementsByTagName('script');
    print('scripts: $scripts');
    String UrlPath = '';

    var regExp = RegExp(
        r'"/ajax/sys\.pages\.homework_report/deleteReport/\?id=\d+&_lock=id&ajaxAuth=\w+"');
    // Match match = regExp.firstMatch(soup.outerHtml) as Match;

    for (var script in scripts) {
      // Get the JavaScript code.
      String jsCode = script.innerHtml;
      print('jsCode: $jsCode');
      // Use the allMatches method to get all matches.

      String? matchedString = regExp.stringMatch(jsCode);

      // Remove the double quotes around the matched string.
      if (matchedString != null) {
        matchedString = matchedString.substring(1, matchedString.length - 1);
        UrlPath = matchedString;
      }

      // print('UrlPath: $UrlPath');

      // Iterable<RegExpMatch> matches = regExp.allMatches(jsCode);

      // Extract the strings from the matches.
      // for (RegExpMatch match in matches) {
      //   String string = match.group(0)!;
      //   // Split the string by the question mark '?'
      //   List<String> splitString = string.split('?');

      //   // Check if the split produced two parts
      //   if (splitString.length == 2) {
      //     String result = splitString[1];
      //     UrlPath = result;
      //   }

      //   // print('secondUrlPath: $secondUrlPath');
      // }
    }
    print('UrlPath: $UrlPath');

    Dioresponse = await dio.post(
      'https://flipclass.stust.edu.tw$UrlPath',
      options: Options(
        // contentType: 'multipart/form-data',
        followRedirects: true,
        headers: {...headers},
      ),
    ); // 刪除作業

    // response = await session.post(
    //   Uri.parse('https://flipclass.stust.edu.tw$UrlPath'),
    //   headers: {...headers},
    // );

    var isDoneresponse = await session.get(
        //確認繳交
        Uri.parse(href),
        headers: {...headers, 'cookie': cookies});
    var isDonesoup = html.parse(isDoneresponse.body);

    // bool isDone = false;
    // print(soup.outerHtml);
    var doneButtonText = isDonesoup
        .querySelector('div.text-center.fs-margin-default > a > span')
        ?.text
        .trim();
    if (!doneButtonText!.contains('檢視')) {
      return true;
    }
    return false;
  }

  // void _showSendingDialog(context) {
  //   showDialog(
  //     context: context,
  //     // barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: const <Widget>[
  //             CircularProgressIndicator(),
  //             SizedBox(height: 16.0),
  //             Text('正在送出...'),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  List<PlatformFile> filteredFiles = [];
  // void openFiles(List<PlatformFile> files) {
  //   show(files: files);
  // }

  Widget show({
    List<PlatformFile>? filteredFiles,
  }) {
    return Scaffold(
      body: ListView.builder(
          itemCount: filteredFiles!.length,
          itemBuilder: (context, index) {
            final file = filteredFiles[index];
            return SingleChildScrollView(child: buildFile(file));
          }),
    );
  }

  Widget buildFile(PlatformFile file) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final size = (mb >= 1)
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
    return InkWell(
      onTap: () => null,
      child: ListTile(
        leading: (file.extension == 'jpg' || file.extension == 'png')
            ? Image.file(
                File(file.path.toString()),
                width: 80,
                height: 80,
              )
            : const SizedBox(
                width: 80,
                height: 80,
              ),
        title: Text(file.name),
        subtitle: Text('${file.extension}'),
        trailing: Text(
          size,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  dynamic _showSendBox() async {
    TextEditingController controller = TextEditingController();
    // controller.text = '輸入作業內容';
    FilePickerResult? result;
    bool isSent = false;
    showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) {
          return StatefulBuilder(// Add this
              builder: (BuildContext context, StateSetter setState) {
            // Modify this line
            return AlertDialog(
              insetPadding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.95,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                        height: 200,
                        child: Expanded(
                          child: TextFormField(
                            textAlignVertical: TextAlignVertical.bottom,
                            // style: TextStyle(
                            //   color: Theme.of(context)
                            //       .textTheme
                            //       .bodySmall
                            //       ?.color,
                            //   fontSize: 20,
                            //   height: 0.0,
                            // ),
                            cursorHeight: 24,
                            enableInteractiveSelection: true,
                            controller: controller,
                            cursorColor: Colors.grey,
                            // initialValue: 'Input text',
                            expands: true,
                            maxLines: null,
                            // cursorHeight: 30,
                            // expands: true,
                            // maxLines: 5000,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              // contentPadding:
                              //     EdgeInsets.fromLTRB(10, 25, 10, 25),
                              // icon: Icon(Icons.favorite),
                              labelText: '作業內容',

                              labelStyle: TextStyle(
                                  color: Color(0xFF6200EE), fontSize: 24),
                              // helperText: '輸入文字',
                              // suffixIcon: Icon(
                              //   Icons.check_circle,
                              // ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF6200EE)),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      child: const Text('選取檔案(單個最大30MB 可多選)'),
                      onPressed: () async {
                        // result = await FilePicker.platform.pickFiles(
                        //   type: FileType.any,
                        //   // allowedExtensions: [
                        //   //   'txt',
                        //   //   'pdf',
                        //   //   'jpg'
                        //   // ], // adjust these as needed
                        // );
                        // print(result!.files);

                        // if (result
                        // != null) {
                        //   PlatformFile file = result!.files.first;

                        //   print(file.name);
                        //   print(file.bytes);
                        //   print(file.readStream);
                        //   print(file.size);
                        //   print(file.extension);
                        //   print(file.path);
                        // } else {
                        //   // User canceled the picker
                        // }
                        result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        if (result == null) return;

                        setState(() {
                          // This will now rebuild the AlertDialog
                          filteredFiles = result!.files
                              .where((file) => file.size / 1024 / 1024 <= 30)
                              .toList();

                          // files = result.files;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(child: show(filteredFiles: filteredFiles)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('送出'),
                  onPressed: () async {
                    // setState(() {
                    //   isSending = true;
                    // });
                    EasyLoading.init();
                    EasyLoading.instance.userInteractions = false;
                    showDialog(
                      context: context,
                      // barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 16.0),
                              Text('正在送出...'),
                            ],
                          ),
                        );
                      },
                    );

                    if (result != null) {
                      var finalFiles = filteredFiles;
                      try {
                        isSent = await sendHomeworkWithFiles(
                            href, controller.text, finalFiles);
                      } catch (e) {
                        print(e);
                      }
                    } else {
                      try {
                        isSent =
                            await sendHomeworkOnlyText(href, controller.text);
                      } catch (e) {
                        print(e);
                      }
                    }

                    if (isSent) {
                      Fluttertoast.showToast(
                          msg: "繳交成功",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor:
                              const Color.fromARGB(255, 81, 82, 81),
                          textColor: const Color.fromARGB(255, 59, 154, 88),
                          fontSize: 25.0);
                      EasyLoading.instance.userInteractions = true;
                    } else {
                      Fluttertoast.showToast(
                          msg: "繳交失敗",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor:
                              const Color.fromARGB(255, 81, 82, 81),
                          textColor: const Color.fromARGB(255, 59, 154, 88),
                          fontSize: 25.0);
                      EasyLoading.instance.userInteractions = true;
                    }
                    if (!mounted) return;

                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const MyHomePage()));

                    //   isSending = false;
                    // });
                  },
                ),
              ],
            );
          });
        });
  }

  String calculateRemainingTime(String dateString) {
    if (dateString.isEmpty) {
      return 'Invalid date';
    }

    DateFormat format = DateFormat("yyyy-MM-dd");
    DateTime targetDate = format
        .parse(dateString)
        .add(const Duration(seconds: 86399)); // Add one day
    DateTime now = DateTime.now();
    Duration difference = targetDate.difference(now);
    print(difference);
    if (difference.inSeconds < 0) {
      print('targetDate :$targetDate now :$now difference :$difference');
      return '已過期';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小時';
    } else {
      return '${difference.inDays}天';
    }
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
                            const SizedBox(
                              height: 10,
                            ),
                            if (attachmentName == "無")
                              Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      width * .3, 5, width * .3, 0),
                                  child: InkWell(
                                      onTap: () async {
                                        if (calculateRemainingTime(
                                                submissionDeadline!) ==
                                            '已過期') {
                                          return showDialog(
                                            context: context,
                                            // barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const <Widget>[
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 16.0),
                                                    Text('功課已過期無法繳交'),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                        if (isDone == '交作業') {
                                          await _showSendBox();
                                        } else {
                                          if (!mounted) return;
                                          EasyLoading.init();
                                          EasyLoading.instance
                                              .userInteractions = false;
                                          showDialog(
                                            context: context,
                                            // barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const <Widget>[
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 16.0),
                                                    Text('正在送出...'),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                          try {
                                            final isDeleted =
                                                await deleteHomework();

                                            if (isDeleted) {
                                              Fluttertoast.showToast(
                                                  msg: "刪除成功",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 81, 82, 81),
                                                  textColor:
                                                      const Color.fromARGB(
                                                          255, 59, 154, 88),
                                                  fontSize: 16.0);
                                              EasyLoading.instance
                                                  .userInteractions = true;
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: "刪除失敗",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 81, 82, 81),
                                                  textColor:
                                                      const Color.fromARGB(
                                                          255, 59, 154, 88),
                                                  fontSize: 16.0);
                                              EasyLoading.instance
                                                  .userInteractions = true;
                                            }
                                            if (!mounted) return;

                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        const MyHomePage()));
                                          } catch (e) {}
                                        } // var iframe = await sendHomework(href);

                                        // iframe = '<iframe src="$iframe" frameborder="0" border="0" style="display: inline;"></iframe>';
                                      },
                                      child: SizedBox(
                                          height: 45,
                                          width: 150,
                                          child: Card(
                                            color: const Color.fromARGB(
                                                255, 114, 142, 204),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Center(
                                              child: (isDone == '交作業')
                                                  ? Text(
                                                      isDone,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  : FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: Text(isDone,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400))),
                                            ),
                                          ))))
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
                                child: FittedBox(
                                    fit: BoxFit.contain,
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
                                )
                              ),
                              if (attachmentBytes != null)
                                Image.memory(attachmentBytes!),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      width * .3, 5, width * .3, 5),
                                  child: InkWell(
                                      onTap: () async {
                                        if (calculateRemainingTime(
                                                submissionDeadline!) ==
                                            '已過期') {
                                          return showDialog(
                                            context: context,
                                            // barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const <Widget>[
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 16.0),
                                                    Text('功課已過期無法繳交'),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                        if (isDone == '交作業') {
                                          await _showSendBox();
                                        } else {
                                          if (!mounted) return;
                                          EasyLoading.init();
                                          EasyLoading.instance
                                              .userInteractions = false;
                                          showDialog(
                                            context: context,
                                            // barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const <Widget>[
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 16.0),
                                                    Text('正在送出...'),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                          try {
                                            final isDeleted =
                                                await deleteHomework();
                                            if (isDeleted) {
                                              Fluttertoast.showToast(
                                                  msg: "刪除成功",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 81, 82, 81),
                                                  textColor:
                                                      const Color.fromARGB(
                                                          255, 59, 154, 88),
                                                  fontSize: 16.0);
                                              EasyLoading.instance
                                                  .userInteractions = true;
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: "刪除失敗",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 81, 82, 81),
                                                  textColor:
                                                      const Color.fromARGB(
                                                          255, 59, 154, 88),
                                                  fontSize: 16.0);
                                              EasyLoading.instance
                                                  .userInteractions = true;
                                            }
                                            if (!mounted) return;

                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        const MyHomePage()));
                                          } catch (e) {}
                                        }
                                        // var iframe = await sendHomework(href);

                                        // iframe = '<iframe src="$iframe" frameborder="0" border="0" style="display: inline;"></iframe>';
                                      },
                                      child: SizedBox(
                                          height: 50,
                                          width: 150,
                                          child: Card(
                                            color: const Color.fromARGB(
                                                255, 114, 142, 204),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Center(
                                              child: (isDone == '交作業')
                                                  ? Text(
                                                      isDone,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  : FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: Text(isDone,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400))),
                                            ),
                                          ))))
                            ],
                          ),
                        ),
                      ),
                    ),

                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
