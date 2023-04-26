import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
import 'package:stust_app/screens/home_work.dart';
import 'package:stust_app/screens/leave_request.dart';
import 'package:stust_app/screens/Bulletins.dart';
import 'package:stust_app/screens/Absent.dart';
import 'package:stust_app/screens/Reflection.dart';
import 'package:stust_app/screens/Send_homework.dart';
import './login/login_page.dart';
import 'package:stust_app/constats/color.dart';
import 'package:stust_app/constats/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'screens/home_work_detail.dart';
import 'package:stust_app/model/panda_pick_model/pandaPickHelper.dart';
import 'package:stust_app/model/panda_pick_model/pandaPickItemModel.dart';
import 'package:page_transition/page_transition.dart';
import 'screens/student_portfolio.dart';

import 'package:stust_app/model/restuarent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
        baseColor: Color(0xFFFFFFFF),
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
  @override
  void initState() {
    super.initState();
    // getProfile().then((){
    //   setState(() {});
    //   }

    // );
    getProfile();

  }

   getProfile() async {
    Map<String, String> values = await getValuesFromSharedPreferences();
    name = values['name']!;
    account = values['account']!;
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('南台通首頁'),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRightWithFade,
                            child: const HomeworkPage()));

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
                        const Image(
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            image: NetworkImage(
                                'https://cdn.pixabay.com/photo/2021/01/16/09/05/meal-5921491_960_720.jpg')),
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
                                  backgroundImage:
                                      AssetImage('assets/pandamart.jpg'),
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
                                      type: PageTransitionType
                                          .leftToRightWithFade,
                                      child: const StudentPortfolioPage()));
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * .15,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: const Color(0xffef9fc4),
                                  borderRadius: BorderRadius.circular(10),
                                  image: const DecorationImage(
                                      image: AssetImage('assets/food.jpg'))),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      '學習歷程',
                                      style: TextStyle(
                                          color: blackColor,
                                          fontFamily: Bold,
                                          fontSize: 18),
                                    ),
                                    Text('學習歷程資料總覽',
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
                                      '社團系統',
                                      style: TextStyle(
                                          color: blackColor,
                                          fontFamily: Bold,
                                          fontSize: 18),
                                    ),
                                    Text('查詢未填寫之心得',
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
              const Text(
                '其他功能',
                style: TextStyle(
                    color: Color(0xff323232), fontSize: 15, fontFamily: Bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  child: ListView.builder(
                      itemCount: PandaPickHelper.itemCount,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        PandaPickItemModel model =
                            PandaPickHelper.getStatusItem(index);
                        return RestuarentScreen(
                          name: model.name,
                          image: model.image,
                          remainingTime: model.remaingTime,
                          totalRating: model.totalRating,
                          subTitle: model.subTitle,
                          rating: model.ratting,
                          deliveryTime: model.remaingTime,
                          deliveryPrice: model.deliveryPrice,
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 74, 154, 220),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: CircleAvatar(
                  radius: 25.0,
                  backgroundImage: NetworkImage(
                      'https://cdn.discordapp.com/attachments/672820483862953994/1088101079926984714/AL5GRJXhY34ARUUiwPjHIsBA_xQwyi0To9ShYof8S0Srs900-c-k-c0x00ffffff-no-rj.png'),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    account,
                    style: const TextStyle(
                        color: Color(0xff323232),
                        fontSize: 15,
                        fontFamily: Bold),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                        color: Color(0xff323232),
                        fontSize: 15,
                        fontFamily: Bold),
                  ),
                ]),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Divider(
              color: Color.fromARGB(255, 222, 220, 220),
              thickness: 2,
              height: 1,
            ),
            ListTile(
              title: const Text('設定',
                  style: TextStyle(fontFamily: Medium, color: Colors.black)),
              leading: const Icon(
                Icons.settings_outlined,
                color: Color.fromARGB(255, 24, 62, 216),
              ),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('幫助中心',
                  style: TextStyle(fontFamily: Medium, color: Colors.black)),
              leading:
                  const Icon(Icons.help_outline, color: MyColors.primaryColor),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('更多',
                  style: TextStyle(fontFamily: Medium, color: Colors.black)),
              leading:
                  const Icon(Icons.more_horiz, color: MyColors.primaryColor),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('登出',
                  style: TextStyle(fontFamily: Medium, color: Colors.black)),
              leading: const Icon(Icons.login_outlined,
                  color: MyColors.primaryColor),
              onTap:
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
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

// Navigate to login page
                  // ignore: use_build_context_synchronously
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginPage.routeName, (route) => false);
                }
              },
            ),
          ],
        ),
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
