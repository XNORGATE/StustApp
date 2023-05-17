import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
import 'package:stust_app/screens/home_work.dart';
import 'package:stust_app/screens/leave_request.dart';
import 'package:stust_app/screens/Bulletins.dart';
import 'package:stust_app/screens/Absent.dart';
import 'package:stust_app/screens/Reflection.dart';
import 'package:stust_app/screens/Send_homework.dart';
import 'package:stust_app/utils/check_connecion.dart';
import './login/login_page.dart';
import 'package:stust_app/constats/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'model/activities.dart';
import 'screens/home_work_detail.dart';
import 'package:page_transition/page_transition.dart';
import 'screens/student_portfolio.dart';
import './screens/misc.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:math';
import './model/restuarent.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// const homeworkTask = "flipclass_homework";
// dynamic oldHomeWorkList;

// @pragma(
//     'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     await NotificationService()
//         .showNotification(title: '作業通知', body: '體育: 線上作業');
//     return Future.value(true);
//   });
// }

// _getoldHomeWorkList() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   oldHomeWorkList = prefs.getString('oldHomeWorkList') ?? '';
//   if (oldHomeWorkList.length == 0) {
//     return [];
//   } else {
//     return json.decode(oldHomeWorkList);
//   }
// }

// int id = 0;

// List<Map<String, String>> findDifferences(
//     List<Map<String, String>> map1, List<Map<String, String>> map2) {
//   List<Map<String, String>> differences = [];

//   for (var item in map2) {
//     if (!map1.any((element) => mapEquals(element, item))) {
//       differences.add(item);
//     }
//   }

//   return differences;
// }

// Future<void> fetchData() async {
//   _getoldHomeWorkList().then((data) async {
//     if (data != null || data != []) {
//       oldHomeWorkList = data;
//       final newHomeWorkList = await const HomeworkPage().getHomework();
//       var listdiff = findDifferences(oldHomeWorkList, newHomeWorkList);
//       if (listdiff.length > 0) {
//         await SharedPreferences.getInstance().then((prefs) {
//           prefs.setString('oldHomeWorkList', json.encode(newHomeWorkList));
//         });
//         await showLocalNotification('flipclass_homework', '作業更新', '有新的作業');
//       }
//     }
//   });

// final response = await http.get('your_api_url_here');
// if (response.statusCode == 200) {
//   final data = jsonDecode(response.body);
//   // You can compare the data with your shared preferences here
//   // If the data is different, call your local notification function
// } else {
//   // Handle the error
// }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // NotificationService().initNotification();
  // var notistatus = await Permission.notification.status;
  var mediaLibrarystatus = await Permission.mediaLibrary.status;
  var photosstatus = await Permission.photos.status;

  // if (notistatus.isDenied ||
  //     notistatus.isPermanentlyDenied ||
  //     notistatus.isRestricted) {
  //   // We didn't ask for permission yet or the permission has been denied before but not permanently.

  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.notification,
  //   ].request();
  // }

  if (mediaLibrarystatus.isDenied ||
      mediaLibrarystatus.isPermanentlyDenied ||
      mediaLibrarystatus.isRestricted) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.mediaLibrary,
    ].request();
  }

  if (photosstatus.isDenied ||
      photosstatus.isPermanentlyDenied ||
      photosstatus.isRestricted) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
    ].request();
  }

  runApp(MaterialApp(
    theme: ThemeData.light(),
    debugShowCheckedModeBanner: false,
    home: FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final prefs = snapshot.data;
          final account = prefs?.getString('account');
          final password = prefs?.getString('password');

          if (account != null && password != null) {
            return const MyApp();
          } else {
            return const LoginPage();
          }
        } else {
          return Container();
        }
      },
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: '南台通Beta v1.0',
      themeMode: ThemeMode.light,
      theme: const NeumorphicThemeData(
        baseColor: Color.fromARGB(255, 236, 236, 236),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: const NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
      home: const MyHomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/homework':
            return PageTransition(
              child: const HomeworkPage(),
              type: PageTransitionType.leftToRightWithFade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
            break;
          case '/bulletins':
            return PageTransition(
              child: const BulletinsPage(),
              type: PageTransitionType.leftToRightWithFade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
            break;
          case '/leave_request':
            return PageTransition(
              child: const AbsentPage(),
              type: PageTransitionType.leftToRightWithFade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
            break;
          case '/reflection':
            return PageTransition(
              child: const ReflectionPage(),
              type: PageTransitionType.leftToRightWithFade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
            break;
          //         case '/bulletins':
          // return PageTransition(
          //   child: BulletinsPage(),
          //   type: PageTransitionType.leftToRightWithFade,
          //   settings: settings,
          //   reverseDuration: Duration(seconds: 3),
          // );
          // break;
          case '/absent':
            return PageTransition(
              child: const LeaveRequestPage(),
              type: PageTransitionType.leftToRightWithFade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
            break;

          ////
          case '/homework-detail':
            return PageTransition(
              child: const HomeWorkDetailPage(),
              type: PageTransitionType.leftToRightWithFade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
            break;
          default:
            return null;
        }
      },
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        MyHomePage.routeName: (context) => const MyHomePage(),
        HomeworkPage.routeName: (context) => const HomeworkPage(),
        BulletinsPage.routeName: (context) => const BulletinsPage(),
        AbsentPage.routeName: (context) => const AbsentPage(),
        ReflectionPage.routeName: (context) => const ReflectionPage(),
        LeaveRequestPage.routeName: (context) => const LeaveRequestPage(),
        SendHomeworkPage.routeName: (context) => const SendHomeworkPage(),
        StudentPortfolioPage.routeName: (context) =>
            const StudentPortfolioPage(),
        StudentMiscPage.routeName: (context) => const StudentMiscPage(),
        ////////
        HomeWorkDetailPage.routeName: (context) => const HomeWorkDetailPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const routeName = '/home';

  const MyHomePage({super.key});
  @override

  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

Future<Map<String, String>> getValuesFromSharedPreferences() async {
  // Get the SharedPreferences instance
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get the values for the keys
  String? name = prefs.getString('name');
  String? account = prefs.getString('account');

  // Return the values as a map
  return {'name': name ?? '', 'account': account ?? ''};
}

class _MyHomePageState extends State<MyHomePage> {
  var name = '姓名';
  var account = '學號';
  bool _isLoading = true;
  bool _isActivitesLoading = true;
  final bool _ActivateHomeWorkNoti = false;
  final bool _ActivateBulletinsNoti = false;

  final bool _value2 = false;

  late List<Map<String, String>> StustAppFoodList = [];
  late List<Map<String, String>> StustActivitiesList = [];

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

      getFoodList().then((data) {
        setState(() {
          StustAppFoodList = data;
          // print(StustAppFoodList);
          _isLoading = false;
        });
      });

      getActivitiesList().then((data) {
        setState(() {
          StustActivitiesList = data;
          // print(StustActivitiesList);
          _isActivitesLoading = false;
        });
      });
      // );
      // try {
      //   final res = getFoodList();

      //   setState(() {
      //     StustAppFoodList = res as List<Map<String, String>>;
      //     print(StustAppFoodList);

      //     _isLoading = false;
      //   });
      // } catch (e) {
      //   setState(() {
      //     _isLoading = false;
      //     showDialogBox(context, e.toString());
      //   });
      // }
      getProfile();
    });

    // NotificationService()
    //     .showNotification(title: 'Sample title', body: 'It works!');
  }

  @override
  void dispose() {
    session.close();
    super.dispose();
  }

  getProfile() async {
    Map<String, String> values = await getValuesFromSharedPreferences();
    name = values['name']!;
    account = values['account']!;
    setState(() {});
  }

  final headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
  };
  var session = http.Client();

  Future<List<Map<String, String>>> getFoodList() async {
    // const url =
    //     "https://docs.google.com/spreadsheets/d/e/2PACX-1vRWoZnufjinYoSp0lQ9KOLuNRpxxMlOp9K2leRL7bNN4I2_wuvx-h7wWQJg4xOK4pTVv85qs3TbvyOG/pubhtml";
    // final response = await Dio().get(
    //   url,
    // );

    var response = await session.get(
        Uri.parse(
            'https://docs.google.com/spreadsheets/d/e/2PACX-1vRWoZnufjinYoSp0lQ9KOLuNRpxxMlOp9K2leRL7bNN4I2_wuvx-h7wWQJg4xOK4pTVv85qs3TbvyOG/pubhtml'),
        headers: {...headers});

    var responseBodyHex = hex.encode(response.bodyBytes);
    var document = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
    // print(pressentScoreData.outerHtml);

    var Alltr = document.querySelectorAll('tr');

    for (int i = 0; i < Alltr.length; i++) {
      var AlltdInside = Alltr[i].querySelectorAll('td');

      if (Alltr[i].attributes['style'] != null &&
          Alltr[i].attributes['style'] == 'height: 20px' &&
          AlltdInside[0].attributes['class'] != 's0') {
        StustAppFoodList.add({
          'name': AlltdInside[0].text.trim(),
          'price': AlltdInside[1].text.trim(),
          'time': AlltdInside[2].text.trim(),
          'ratting': AlltdInside[3].text.trim(),
          'foodType': AlltdInside[4].text.trim(),
          'totalRating': AlltdInside[5].text.trim(),
          'link': AlltdInside[6].text.trim(),
          'image': AlltdInside[7].text.trim(),
        });
      }
    }

    // print(StustAppFoodList);
    final random = Random();
    StustAppFoodList.shuffle(random); // randomize the order of the list

    return StustAppFoodList;
  }

  Future<List<Map<String, String>>> getActivitiesList() async {
    // const url =
    //     "https://docs.google.com/spreadsheets/d/e/2PACX-1vRWoZnufjinYoSp0lQ9KOLuNRpxxMlOp9K2leRL7bNN4I2_wuvx-h7wWQJg4xOK4pTVv85qs3TbvyOG/pubhtml";
    // final response = await Dio().get(
    //   url,
    // );

    var response = await session
        .get(Uri.parse('https://www.stust.edu.tw/'), headers: {...headers});

    var responseBodyHex = hex.encode(response.bodyBytes);
    var document = html_parser.parse(utf8.decode(hex.decode(responseBodyHex)));
    // print(document.outerHtml);

    var Alldivinside = document.querySelectorAll('div.ad-slider2 > div');
    // print(Alldivinside); //all banner-item  class
    for (int i = 0; i < Alldivinside.length; i++) {
      var href = Alldivinside[i].querySelector('a')!.attributes['href'];
      var img = Alldivinside[i].querySelector('img')!.attributes['src'];
      var topic = Alldivinside[i].querySelector('div.adlist-txt')!.text.trim();
      // print(href);
      // print(img);
      // print(title);
      StustActivitiesList.add({
        'href': href!,
        'image': img!,
        'topic': topic,
      });
    }

    // print(StustActivitiesList);
    // final random = Random();
    // StustActivitiesList.shuffle(random); // randomize the order of the list

    return StustActivitiesList;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Colors.green[200],
        title: const Text(
          '南台通首頁',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
        ),
        // actions: const[
        //   Icon(Icons.shopping_bag_outlined),
        //   SizedBox(width: 10,)
        // ],
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(10),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        //     child: Row(
        //       children: [
        //         Expanded(
        //             child: CupertinoTextField(
        //           padding:
        //               const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        //           placeholder: "Seach for shop & restaurants",
        //           prefix: const Padding(
        //             padding: EdgeInsets.only(left: 10),
        //             child: Icon(
        //               Icons.search,
        //               color: Color(0xff7b7b7b),
        //             ),
        //           ),
        //           decoration: BoxDecoration(
        //               color: const Color(0xfff7f7f7),
        //               borderRadius: BorderRadius.circular(50)),
        //           style: const TextStyle(
        //               color: Color(0xff707070),
        //               fontSize: 12,
        //               fontFamily: Regular),
        //         )),
        //       ],
        //     ),
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () async {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRightWithFade,
                          child: const HomeworkPage()));
                  // await NotificationService().showNotification(
                  //     title: 'Sample title', body: 'It works!');
                  // Navigator.of(context).pushReplacementNamed('/homework');

                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const HomeworkPage()));
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * .18,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 5, 5, 5),
                      borderRadius: BorderRadius.circular(10)),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      // const Image(
                      //     fit: BoxFit.fitWidth,
                      //     width: double.infinity,
                      //     image: NetworkImage(
                      //         'https://cdn.pixabay.com/photo/2021/01/16/09/05/meal-5921491_960_720.jpg')),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Flipclass',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Bold,
                                    fontSize: 18),
                              ),
                              Text('最新公告及最近事件(作業)',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                      fontFamily: Medium,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LeaveRequestPage()));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * .25,
                        decoration: BoxDecoration(
                            color: const Color(0xfffed271),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: const [
                              CircleAvatar(
                                radius: 50,
                                // backgroundImage:
                                //     AssetImage('assets/pandamart.jpg'),
                              ),
                              Positioned(
                                  bottom: 15,
                                  left: 0,
                                  child: Text(
                                    '請假系統',
                                    style: TextStyle(
                                        color: blackColor,
                                        fontFamily: Bold,
                                        fontSize: 18),
                                  )),
                              Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Text('查詢缺曠及請假',
                                      style: TextStyle(
                                          color: blackColor,
                                          fontWeight: FontWeight.w500,
                                          height: 1,
                                          fontFamily: Medium,
                                          fontSize: 14))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Do something when this widget is tapped
                            Navigator.push(
                                context,
                                PageTransition(
                                    type:
                                        PageTransitionType.leftToRightWithFade,
                                    child: const StudentPortfolioPage()));
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * .15,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xffef9fc4),
                              borderRadius: BorderRadius.circular(10),
                              // image: const DecorationImage(
                              //     image: AssetImage('assets/food.jpg'))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '課程事項',
                                    style: TextStyle(
                                        color: blackColor,
                                        fontFamily: Bold,
                                        fontSize: 18),
                                  ),
                                  Text('成績與課表',
                                      style: TextStyle(
                                          color: blackColor,
                                          fontWeight: FontWeight.w500,
                                          height: 1,
                                          fontFamily: Medium,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            // Do something when this widget is tapped
                            Navigator.push(
                                context,
                                PageTransition(
                                    type:
                                        PageTransitionType.leftToRightWithFade,
                                    child: const StudentMiscPage()));
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * .1,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: const Color(0xff85bfff),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '學生其他事項',
                                    style: TextStyle(
                                        color: blackColor,
                                        fontFamily: Bold,
                                        fontSize: 18),
                                  ),
                                  Text('各式事項',
                                      style: TextStyle(
                                          color: blackColor,
                                          fontWeight: FontWeight.w500,
                                          height: 1,
                                          fontFamily: Medium,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '美食地圖',
                style: TextStyle(
                    color: Color.fromARGB(255, 18, 18, 18),
                    fontSize: 17.5,
                    fontFamily: Bold),
              ),
            ),
            SizedBox(
              height: 170,
              child:
                  // const Center(child: CircularProgressIndicator())
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: StustAppFoodList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            // PandaPickItemModel model =
                            final data = StustAppFoodList[index];
                            return RestuarentScreen(
                              name: data['name'] ?? '',
                              image: data['image'] ?? '',
                              time: data['time'] ?? '',
                              totalRating: data['totalRating'] ?? '',
                              foodType: data['foodType'] ?? '',
                              rating: data['ratting'] ?? '',
                              link: data['link'] ?? '',
                              price: data['price'] ?? '',
                            );
                          }),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '校園活動',
                style: TextStyle(
                    color: Color(0xff323232), fontSize: 17.5, fontFamily: Bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .25,
                child:
                    // const Center(child: CircularProgressIndicator())
                    _isActivitesLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: StustActivitiesList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              // PandaPickItemModel model =
                              final data = StustActivitiesList[index];
                              // print(data);
                              return ActivitiesScreen(
                                href: data['href'] ?? '',
                                image: data['image'] ?? '',
                                topic: data['topic'] ?? '',
                              );
                            }),
              ),
            ),
          ],
        ),
      ),
//       drawer: Drawer(
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.horizontal(right: Radius.circular(40))),
//         child: ListView(
//           // Important: Remove any padding from the ListView.
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Color.fromARGB(255, 74, 154, 220),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                 child: CircleAvatar(
//                   radius: 25.0,
//                   backgroundImage: NetworkImage(
//                       'https://cdn.discordapp.com/attachments/672820483862953994/1088101079926984714/AL5GRJXhY34ARUUiwPjHIsBA_xQwyi0To9ShYof8S0Srs900-c-k-c0x00ffffff-no-rj.png'),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             SizedBox(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                 child:
//                     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Text(
//                     account,
//                     style: const TextStyle(
//                         color: Color(0xff323232),
//                         fontSize: 15,
//                         fontFamily: Bold),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Text(
//                     name,
//                     style: const TextStyle(
//                         color: Color(0xff323232),
//                         fontSize: 15,
//                         fontFamily: Bold),
//                   ),
//                 ]),
//               ),
//             ),
//             const SizedBox(
//               height: 15,
//             ),
//             const Divider(
//               color: Color.fromARGB(255, 222, 220, 220),
//               thickness: 2,
//               height: 1,
//             ),
//             ListTile(
//               title: const Text('設定',
//                   style: TextStyle(fontFamily: Medium, color: Colors.black)),
//               leading: const Icon(
//                 Icons.settings_outlined,
//                 color: Color.fromARGB(255, 24, 62, 216),
//               ),
//               onTap: () {
//                 // Update the state of the app
//                 // ...
//                 // Then close the drawer
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('幫助中心',
//                   style: TextStyle(fontFamily: Medium, color: Colors.black)),
//               leading:
//                   const Icon(Icons.help_outline, color: MyColors.primaryColor),
//               onTap: () {
//                 // Update the state of the app
//                 // ...
//                 // Then close the drawer
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('更多',
//                   style: TextStyle(fontFamily: Medium, color: Colors.black)),
//               leading:
//                   const Icon(Icons.more_horiz, color: MyColors.primaryColor),
//               onTap: () {
//                 // Update the state of the app
//                 // ...
//                 // Then close the drawer
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('登出',
//                   style: TextStyle(fontFamily: Medium, color: Colors.black)),
//               leading: const Icon(Icons.login_outlined,
//                   color: MyColors.primaryColor),
//               onTap:
//                   // Update the state of the app
//                   // ...
//                   // Then close the drawer
//                   () async {
//                 final confirmed = await showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text(
//                       '登出',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                     content: const Text('確定要登出 ?'),
//                     actions: [
//                       NeumorphicButton(
//                         onPressed: () => Navigator.pop(context, false),
//                         child: const Text('取消'),
//                       ),
//                       NeumorphicButton(
//                         onPressed: () => Navigator.pop(context, true),
//                         child: const Text('確認'),
//                       ),
//                     ],
//                   ),
//                 );
//                 if (confirmed == true) {
// // Clear 'account' and 'password' from SharedPreferences
//                   final prefs = await SharedPreferences.getInstance();
//                   prefs.remove('account');
//                   prefs.remove('password');
//                   prefs.remove('name');

// // Navigate to login page
//                   // ignore: use_build_context_synchronously
//                   Navigator.pushNamedAndRemoveUntil(
//                       context, LoginPage.routeName, (route) => false);
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
      drawer: Drawer(
        width: 275,
        elevation: 30,
        backgroundColor: const Color(0xF3393838),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(40))),
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x3D000000), spreadRadius: 30, blurRadius: 20)
              ]),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios),
                          color: Colors.white,
                          iconSize: 20,
                        ),
                        const SizedBox(
                          width: 56,
                        ),
                        const Text(
                          '南臺通APP',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const UserAvatar(
                          filename: 'stust.png',
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          account,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    // const DrawerItem(
                    //   title: '帳號',
                    //   icon: Icons.key,
                    // ),
                    DrawerItem(
                      title: '幫助中心',
                      icon: Icons.help_outline,
                      onTap: () {},
                    ),

                    // DrawerItem(
                    //   title: '通知設置',
                    //   icon: Icons.notifications,
                    //   onTap: () {
                    //     showDialog(
                    //         context: context,
                    //         builder: (context) {
                    //           return AlertDialog(
                    //             shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(15)),
                    //             title: const Text('通知設置'),
                    //             actions: [
                    //               TextButton(
                    //                 onPressed: () {
                    //                   Navigator.of(context).pop();
                    //                 },
                    //                 child: const Text('確定'),
                    //               ),
                    //             ],
                    //             content: Padding(
                    //                 padding: const EdgeInsets.all(.0),
                    //                 child: SizedBox(
                    //                   width: width * .3,
                    //                   height: height * .3,
                    //                   child: Column(
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.center,
                    //                     children: [
                    //                       const SizedBox(
                    //                         height: 30,
                    //                       ),
                    //                       Row(
                    //                         mainAxisAlignment:
                    //                             MainAxisAlignment.center,
                    //                         children: [
                    //                           SelectorWidget(
                    //                             labelText: '開啟作業通知',
                    //                             options: const ['關閉', '開啟'],
                    //                             onChanged: (value) {
                    //                               // Handle the value change
                    //                               if (value == '開啟') {
                    //                                 _ActivateHomeWorkNoti =
                    //                                     true;

                    //                                 Workmanager().initialize(
                    //                                     callbackDispatcher, // The top level function, aka callbackDispatcher
                    //                                     isInDebugMode:
                    //                                         true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
                    //                                     );
                    //                                 Workmanager().registerPeriodicTask(
                    //                                     "flipclass_homework",
                    //                                     '作業監控中',
                    //                                     // When no frequency is provided the default 15 minutes is set.
                    //                                     // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
                    //                                     constraints:
                    //                                         Constraints(
                    //                                       networkType:
                    //                                           NetworkType
                    //                                               .connected,
                    //                                     ));
                    //                               } else {
                    //                                 _ActivateHomeWorkNoti =
                    //                                     false;
                    //                                 Workmanager()
                    //                                     .cancelByUniqueName(
                    //                                         'flipclass_homework');
                    //                               }
                    //                             },
                    //                           ),
                    //                         ],
                    //                       ),

                    //                       const SizedBox(
                    //                         height: 30,
                    //                       ),

                    //                       Row(
                    //                         mainAxisAlignment:
                    //                             MainAxisAlignment.center,
                    //                         children: [
                    //                           SelectorWidget(
                    //                             labelText: '開啟公告通知',
                    //                             options: const ['關閉', '開啟'],
                    //                             onChanged: (value) {
                    //                               // Handle the value change
                    //                               if (value == '開啟') {
                    //                                 _ActivateBulletinsNoti =
                    //                                     true;
                    //                               } else {
                    //                                 _ActivateBulletinsNoti =
                    //                                     false;
                    //                               }
                    //                               print(_ActivateBulletinsNoti);
                    //                             },
                    //                           ),
                    //                         ],
                    //                       ),
                    //                       // CheckboxListTile(
                    //                       //   activeColor: Colors.red,
                    //                       //   title: const Text('開啟作業通知'),
                    //                       //   value: _ActivateHomeWorkNoti,
                    //                       //   onChanged: (value) {
                    //                       //     setState(() {
                    //                       //       _ActivateHomeWorkNoti = value!;
                    //                       //     });
                    //                       //   },
                    //                       // ),
                    //                       // CheckboxListTile(
                    //                       //   activeColor: Colors.red,
                    //                       //   title: const Text('開啟公告通知'),
                    //                       //   value: _ActivateHomeWorkNoti,
                    //                       //   onChanged: (value) {
                    //                       //     setState(() {
                    //                       //       _ActivateBulletinsNoti = value!;
                    //                       //       print(_ActivateBulletinsNoti);
                    //                       //     });
                    //                       //   },
                    //                       // ),
                    //                     ],
                    //                   ),
                    //                 )),
                    //           );
                    //         });
                    //   },
                    // ),

                    DrawerItem(
                      title: '關於此APP',
                      icon: Icons.perm_contact_calendar,
                      onTap: () {},
                    ),

                    DrawerItem(
                      title: '幫助中心',
                      icon: Icons.help,
                      onTap: () {},
                    ),
                    const Divider(
                      height: 35,
                      color: Color.fromARGB(255, 149, 147, 147),
                    ),
                    // const DrawerItem(
                    //     title: 'Invite a friend', icon: Icons.people_outline),
                  ],
                ),
                DrawerItem(
                  title: '登出',
                  icon: Icons.logout,
                  onTap: () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        title: const Text(
                          '登出',
                          style: TextStyle(color: Colors.black),
                        ),
                        content: const Text('確定要登出 ?'),
                        actions: [
                          NeumorphicButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('取消'),
                          ),
                          NeumorphicButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('確認'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
// Clear 'account' and 'password' from SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      prefs.remove('account');
                      prefs.remove('password');
                      prefs.remove('name');
                      // prefs.remove('oldHomeWorkList');
                      // Workmanager().cancelAll();

// Navigate to login page
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginPage.routeName, (route) => false);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final Function()? onTap;

  final String title;
  final IconData icon;
  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(
              width: 40,
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String filename;
  const UserAvatar({
    super.key,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 29,
        backgroundImage: Image.asset('assets/$filename').image,
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           automaticallyImplyLeading: false,
//           centerTitle: true,
//           title: const Text('南台通Beta v1.0 首頁'),
//           actions: [
//             IconButton(
//                 iconSize: 35,
//                 padding: const EdgeInsets.only(right: 20),
//                 onPressed: () async {
//                   final confirmed = await showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text(
//                         '登出',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                       content: const Text('確定要登出 ?'),
//                       actions: [
//                         NeumorphicButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: const Text('取消'),
//                         ),
//                         NeumorphicButton(
//                           onPressed: () => Navigator.pop(context, true),
//                           child: const Text('確認'),
//                         ),
//                       ],
//                     ),
//                   );
//                   if (confirmed == true) {
// // Clear 'account' and 'password' from SharedPreferences
//                     final prefs = await SharedPreferences.getInstance();
//                     prefs.remove('account');
//                     prefs.remove('password');
// // Navigate to login page
//                     // ignore: use_build_context_synchronously
//                     Navigator.pushNamedAndRemoveUntil(
//                         context, LoginPage.routeName, (route) => false);
//                   }
//                 },
//                 icon: const Icon(Icons.exit_to_app_outlined))
//             // NeumorphicButton(
//             //   child: Icon(Icons.exit_to_app_outlined),
//             //   style: NeumorphicStyle(
//             //       shape: NeumorphicShape.concave,
//             //       boxShape:
//             //           NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
//             //       depth: 3,
//             //       color: Color.fromARGB(255, 212, 69, 76)),
//             //   drawSurfaceAboveChild: false,
//             //   margin: EdgeInsets.fromLTRB(0.0, 10.0, 15.0, 10.0),
//             //   //padding: EdgeInsets.only(bottom: 1),

//             // ),
//           ]),
//       body: isMobile(context)
//           ? Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
// // Homework section
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const SizedBox(
//                           height: 15,
//                         ),
//                         NeumorphicButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const HomeworkPage()));
//                           },
//                           child: const Text(
//                             '最新事件',
//                             style: TextStyle(color: Colors.black, fontSize: 20),
//                           ),
//                         ),
// // Bulletins section
//                         const SizedBox(
//                           height: 15,
//                         ),

//                         NeumorphicButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const BulletinsPage()));
//                           },
//                           child: const Text(
//                             '最新公告',
//                             style: TextStyle(color: Colors.black, fontSize: 20),
//                           ),
//                         ),
// // Absent section
//                         const SizedBox(
//                           height: 15,
//                         ),

//                         NeumorphicButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const AbsentPage()));
//                           },
//                           child: const Text(
//                             '缺席',
//                             style: TextStyle(color: Colors.black, fontSize: 20),
//                           ),
//                         ),
// // Reflection section
//                         const SizedBox(
//                           height: 15,
//                         ),

//                         NeumorphicButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const ReflectionPage()));
//                           },
//                           child: const Text(
//                             '未繳心得',
//                             style: TextStyle(color: Colors.black, fontSize: 20),
//                           ),
//                         ),
//                         // Leave request section
//                         const SizedBox(
//                           height: 15,
//                         ),

//                         NeumorphicButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const LeaveRequestPage()));
//                           },
//                           child: const Text(
//                             '請假',
//                             style: TextStyle(color: Colors.black, fontSize: 20),
//                           ),
//                         ),
// // Send homework section
//                         const SizedBox(
//                           height: 15,
//                         ),

//                         NeumorphicButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const SendHomeworkPage()));
//                           },
//                           child: const Text(
//                             '快速繳交作業',
//                             style: TextStyle(color: Colors.black, fontSize: 20),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//             )
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
// // Homework section
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   //crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(
//                       width: 15,
//                     ),
//                     NeumorphicButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const HomeworkPage()));
//                       },
//                       child: const Text(
//                         '最新事件',
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       ),
//                     ),
// // Bulletins section
//                     const SizedBox(
//                       width: 15,
//                     ),

//                     NeumorphicButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const BulletinsPage()));
//                       },
//                       child: const Text(
//                         '最新公告',
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       ),
//                     ),
// // Absent section
//                     const SizedBox(
//                       width: 15,
//                     ),

//                     NeumorphicButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const AbsentPage()));
//                       },
//                       child: const Text(
//                         '缺席',
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       ),
//                     ),
// // Reflection section
//                     const SizedBox(
//                       width: 15,
//                     ),

//                     NeumorphicButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const ReflectionPage()));
//                       },
//                       child: const Text(
//                         '未繳心得',
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       ),
//                     ),
//                     // Leave request section
//                     const SizedBox(
//                       width: 15,
//                     ),

//                     NeumorphicButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const LeaveRequestPage()));
//                       },
//                       child: const Text(
//                         '請假',
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       ),
//                     ),
// // Send homework section
//                     const SizedBox(
//                       width: 15,
//                     ),

//                     NeumorphicButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const SendHomeworkPage()));
//                       },
//                       child: const Text(
//                         '快速繳交作業',
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//     );
//   }
// }
// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');

//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     await notificationsPlugin.initialize(
//       initializationSettings,
//     );
//   }

//   notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//           'default_notification_channel_id', 'Default',
//           importance: Importance.max),
//     );
//   }

//   Future showNotification(
//       {int id = 0, String? title, String? body, String? payLoad}) async {
//     return notificationsPlugin.show(
//         id, title, body, await notificationDetails());
//   }
// }
