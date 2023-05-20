import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dialog_utils.dart';
import 'package:http/http.dart' as http;

class CreateActivitiesPage extends StatefulWidget {
  static const routeName = '/create_activities';

  const CreateActivitiesPage({super.key});

  @override
  _CreateActivitiesPageState createState() => _CreateActivitiesPageState();
}

class _CreateActivitiesPageState extends State<CreateActivitiesPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController locationController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController imageLinkController = TextEditingController();
  TextEditingController hostController = TextEditingController();

  final _dateController = TextEditingController();

  // Initialize your form fields
  String _location = '';
  String _topic = '';
  String _link = '';
  String _imageLink = '';
  String _host = '';
  DateTime _selectedDateTime = DateTime.now();

  bool isNetworkImage(String imageUrl) {
    final networkImageUrlRegex = RegExp(
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    return networkImageUrlRegex.hasMatch(imageUrl);
  }

  bool isLaunchUrl(String url) {
    final launchUrlRegex = RegExp(
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    return launchUrlRegex.hasMatch(url);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        // key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(35, 80, 35, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      cursorColor: const Color.fromARGB(255, 19, 19, 19),
                      controller: locationController,
                      decoration: const InputDecoration(
                          labelText: '活動地點(<10字)',
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color.fromARGB(255, 29, 33, 52))),
                      onChanged: (value) => _location = value,
                      validator: (value) => value!.length < 20 ? value : '',
                    ),
                  )),
              const SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      cursorColor: const Color.fromARGB(255, 19, 19, 19),
                      controller: topicController,
                      decoration: const InputDecoration(
                          labelText: '活動標題(<20字)',
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color.fromARGB(255, 29, 33, 52))),
                      onChanged: (value) => _topic = value,
                      validator: (value) => value!.length < 20 ? value : '',
                    ),
                  )),
              const SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      cursorColor: const Color.fromARGB(255, 19, 19, 19),
                      controller: linkController,
                      decoration: const InputDecoration(
                          labelText: '活動連結(文章)',
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color.fromARGB(255, 29, 33, 52))),
                      onChanged: (value) => _link = value,
                      validator: (value) => isLaunchUrl(value!) ? value : '',
                    ),
                  )),
              const SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      cursorColor: const Color.fromARGB(255, 19, 19, 19),
                      controller: imageLinkController,
                      decoration: const InputDecoration(
                          labelText: '圖片連結',
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color.fromARGB(255, 29, 33, 52))),
                      onChanged: (value) => _imageLink = value,
                      validator: (value) => isNetworkImage(value!) ? value : '',
                    ),
                  )),
              const SizedBox(
                height: 15,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      cursorColor: const Color.fromARGB(255, 19, 19, 19),
                      controller: hostController,
                      decoration: const InputDecoration(
                          labelText: '主辦人/單位(<12字)',
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color.fromARGB(255, 29, 33, 52))),
                      onChanged: (value) => _host = value,
                      validator: (value) => value!.length < 12 ? value : '',
                    ),
                  )),
              // Container(
              // decoration: BoxDecoration(
              //   color: Colors.grey,
              //   borderRadius: BorderRadius.circular(10.0),
              // ),
              // child: Padding(
              //   padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
              //   child: TextFormField(
              //     controller: topicController,
              //     decoration: const InputDecoration(labelText: '活動標題'),
              //     onChanged: (value) => _topic = value,
              //     validator: (value) => value!.isEmpty ? '請輸入活動標題' : '',
              //   ),
              // )),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: TextButton(
                    onPressed: () async {
                      final currentDate = _selectedDateTime;
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: currentDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        if (!mounted) return;
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(currentDate),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            _dateController.text =
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(_selectedDateTime);
                          });
                        }
                      }
                    },
                    child: TextFormField(
                      enabled: false,
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: '活動日期',
                        border: InputBorder.none,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Color.fromARGB(255, 29, 33, 52),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? '請選擇活動日期' : '',
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 35,
              ),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  String? account = prefs.getString('account');
                  // if (_formKey.currentState!.validate()) {
                  // Submit your form
                  if (_location != '' &&
                      _location.length < 10 &&
                      _topic != '' &&
                      _topic.length < 20 &&
                      _link != '' &&
                      isLaunchUrl(_link) &&
                      _imageLink != '' &&
                      isNetworkImage(_imageLink) &&
                      _host != '' &&
                      _host.length < 12 &&
                      _dateController.text != '') {
                    final session = http.Client();

                    final payload = {
                      'location': _location,
                      'date': _dateController.text,
                      'topic': _topic,
                      'link': _link,
                      'image_link': _imageLink,
                      'student_number': account,
                      'host': _host,
                    };
                    print(payload);
                    try {
                      final res = await session.post(
                          Uri.parse(
                              'http://api.xnor-development.com:70/stust_activities'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode(payload));

                      print(res.statusCode);

                      if (!mounted) return;
                      if (res.statusCode == 200) {
                        showDialogBox(context, '成功新增活動');
                      }
                    } catch (e) {
                      if (!mounted) return;

                      showDialogBox(context, '操作失敗\n請確認網路連線');
                    }
                    if (!mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  } else {
                    showDialogBox(context, '請填寫所有欄位\n並確認圖片連結及文章連結是否正確');
                  }
                  // }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 29, 33, 52),
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.5),
                  ),
                ),
                child: const Text('新增活動'),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 149, 120),
        // automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('新增活動'),
        actions: [
          IconButton(
              iconSize: 35,
              padding: const EdgeInsets.fromLTRB(0, 5, 20, 0),
              onPressed: () async {
                showDialogBox(context,
                    '此頁面為新增活動頁面 \n提供用戶宣傳各種活動\n\n系統會將所有輸入值及您的學號傳送至開發者私人雲端伺服器供APP使用者存取\n\n 若不能接受請點擊返回');
              },
              icon: const Icon(
                Icons.help_outline,
                size: 30,
              ))
        ],
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false)),
      ),
    );
  }
}
