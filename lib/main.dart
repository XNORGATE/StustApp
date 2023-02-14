import 'package:flutter/material.dart';
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
            return MyApp();
          } else {
            return LoginPage();
          }
        } else {
          return Container();
        }
      },
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: '南台通Beta v1.0',
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
        baseColor: Color(0xFFFFFFFF),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
      home: MyHomePage(),
      routes: {
        LoginPage.routeName: (context) => LoginPage(),
        MyHomePage.routeName: (context) => MyHomePage(),
        HomeworkPage.routeName: (context) => HomeworkPage(),
        BulletinsPage.routeName: (context) => BulletinsPage(),
        AbsentPage.routeName: (context) => AbsentPage(),
        ReflectionPage.routeName: (context) => ReflectionPage(),
        LeaveRequestPage.routeName: (context) => LeaveRequestPage(),
        SendHomeworkPage.routeName: (context) => SendHomeworkPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  static const routeName = '/home';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('南台通Beta v1.0 首頁'),
          actions: [
            IconButton(
                iconSize: 35,
                padding: EdgeInsets.only(right: 20),
                onPressed: () async {
                  final confirmed = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        '登出',
                        style: TextStyle(color: Colors.black),
                      ),
                      content: Text('確定要登出 ?'),
                      actions: [
                        NeumorphicButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('取消'),
                        ),
                        NeumorphicButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('確認'),
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
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: NeumorphicButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeworkPage()));
                            },
                            child: Text(
                              '最新事件',
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
// Bulletins section
                        SizedBox(
                          height: 15,
                        ),

                        Container(
                          child: NeumorphicButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BulletinsPage()));
                            },
                            child: Text(
                              '最新公告',
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
// Absent section
                        SizedBox(
                          height: 15,
                        ),

                        Container(
                          child: NeumorphicButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AbsentPage()));
                            },
                            child: Text(
                              '缺席',
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
// Reflection section
                        SizedBox(
                          height: 15,
                        ),

                        Container(
                          child: NeumorphicButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReflectionPage()));
                            },
                            child: Text(
                              '未繳心得',
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
                        // Leave request section
                        SizedBox(
                          height: 15,
                        ),

                        Container(
                          child: NeumorphicButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LeaveRequestPage()));
                            },
                            child: Text(
                              '請假',
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
// Send homework section
                        SizedBox(
                          height: 15,
                        ),

                        Container(
                          child: NeumorphicButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SendHomeworkPage()));
                            },
                            child: Text(
                              '快速繳交作業',
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
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
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      child: NeumorphicButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeworkPage()));
                        },
                        child: Text(
                          '最新事件',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
// Bulletins section
                    SizedBox(
                      width: 15,
                    ),

                    Container(
                      child: NeumorphicButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BulletinsPage()));
                        },
                        child: Text(
                          '最新公告',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
// Absent section
                    SizedBox(
                      width: 15,
                    ),

                    Container(
                      child: NeumorphicButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AbsentPage()));
                        },
                        child: Text(
                          '缺席',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
// Reflection section
                    SizedBox(
                      width: 15,
                    ),

                    Container(
                      child: NeumorphicButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReflectionPage()));
                        },
                        child: Text(
                          '未繳心得',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                    // Leave request section
                    SizedBox(
                      width: 15,
                    ),

                    Container(
                      child: NeumorphicButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LeaveRequestPage()));
                        },
                        child: Text(
                          '請假',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
// Send homework section
                    SizedBox(
                      width: 15,
                    ),

                    Container(
                      child: NeumorphicButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendHomeworkPage()));
                        },
                        child: Text(
                          '快速繳交作業',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
