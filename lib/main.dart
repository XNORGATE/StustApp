import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
import 'package:stust_app/home_work.dart';
import 'package:stust_app/Absent.dart';
import 'package:stust_app/Bulletins.dart';
import 'package:stust_app/leave_request.dart';
import 'package:stust_app/Reflection.dart';
import 'package:stust_app/Send_homework.dart';
import 'package:stust_app/login_page.dart';
import 'package:stust_app/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

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
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        MyHomePage.routeName: (context) => const MyHomePage(),
        HomeworkPage.routeName: (context) => const HomeworkPage(),
        BulletinsPage.routeName: (context) => const BulletinsPage(),
        AbsentPage.routeName: (context) => const AbsentPage(),
        ReflectionPage.routeName: (context) => const ReflectionPage(),
        LeaveRequestPage.routeName: (context) => const LeaveRequestPage(),
        SendHomeworkPage.routeName: (context) => const SendHomeworkPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  static const routeName = '/home';

  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('南台通Beta v1.0 首頁'),
          actions: [
            IconButton(
                iconSize: 35,
                padding: const EdgeInsets.only(right: 20),
                onPressed: () async {
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
// Navigate to login page
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginPage.routeName, (route) => false);
                  }
                },
                icon: const Icon(Icons.exit_to_app_outlined))
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
          ]),
      body: isMobile(context)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
// Homework section
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        NeumorphicButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeworkPage()));
                          },
                          child: const Text(
                            '最新事件',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
// Bulletins section
                        const SizedBox(
                          height: 15,
                        ),

                        NeumorphicButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BulletinsPage()));
                          },
                          child: const Text(
                            '最新公告',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
// Absent section
                        const SizedBox(
                          height: 15,
                        ),

                        NeumorphicButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AbsentPage()));
                          },
                          child: const Text(
                            '缺席',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
// Reflection section
                        const SizedBox(
                          height: 15,
                        ),

                        NeumorphicButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ReflectionPage()));
                          },
                          child: const Text(
                            '未繳心得',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                        // Leave request section
                        const SizedBox(
                          height: 15,
                        ),

                        NeumorphicButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LeaveRequestPage()));
                          },
                          child: const Text(
                            '請假',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
// Send homework section
                        const SizedBox(
                          height: 15,
                        ),

                        NeumorphicButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SendHomeworkPage()));
                          },
                          child: const Text(
                            '快速繳交作業',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
// Homework section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    NeumorphicButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeworkPage()));
                      },
                      child: const Text(
                        '最新事件',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
// Bulletins section
                    const SizedBox(
                      width: 15,
                    ),

                    NeumorphicButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BulletinsPage()));
                      },
                      child: const Text(
                        '最新公告',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
// Absent section
                    const SizedBox(
                      width: 15,
                    ),

                    NeumorphicButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AbsentPage()));
                      },
                      child: const Text(
                        '缺席',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
// Reflection section
                    const SizedBox(
                      width: 15,
                    ),

                    NeumorphicButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ReflectionPage()));
                      },
                      child: const Text(
                        '未繳心得',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                    // Leave request section
                    const SizedBox(
                      width: 15,
                    ),

                    NeumorphicButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LeaveRequestPage()));
                      },
                      child: const Text(
                        '請假',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
// Send homework section
                    const SizedBox(
                      width: 15,
                    ),

                    NeumorphicButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SendHomeworkPage()));
                      },
                      child: const Text(
                        '快速繳交作業',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
