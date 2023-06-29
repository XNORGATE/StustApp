import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// ignore: unused_import
import '../login/login_page.dart';
// ignore: unused_import
import '../main.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  bool isLastPage = false;
  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  Widget buildPage({
    
    required Color color,
    required String urlImage,
    required String title,
    required String subtitle,
  }) =>
  
      Container(
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height / 1.75,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    urlImage,
                    fit: BoxFit.cover,
                  
                  ),
                )),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 8, 8, 8),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: const EdgeInsets.only(bottom: 80),
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 3);
            },
            children: [
              buildPage(
                color: Colors.green.shade100,
                urlImage: 'assets/homeWork.png',
                title: '快速繳交/查看作業',
                subtitle: '簡潔快速的繳交功能，支援多檔案上傳及刪除已繳交之作業',
              ),
              buildPage(
                color: Colors.green.shade100,
                urlImage: 'assets/bulletins.png',
                title: '快速查看即時公告',
                subtitle: '不必開一堆網頁，即可接收Flipclass最新公告',
              ),
              buildPage(
                color: Colors.green.shade100,
                urlImage: 'assets/leaveRequest.png',
                title: '快速請假',
                subtitle: '最簡潔快速的請假功能，支援病假/事假\n快速一鍵請假，查看假單',
              ),
              buildPage(
                color: Colors.green.shade100,
                urlImage: 'assets/createActivities.png',
                title: '校園活動宣傳',
                subtitle: '幫助你曝光/接收新的活動消息',
              ),
              // buildPage(
              //   color: Colors.orange.shade100,
              //   urlImage: 'assets/stust.png',
              //   title: '開始',
              //   subtitle: '馬上體驗',
              // ),
            ],
          ),
        ),
        bottomSheet: isLastPage
            ? TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  backgroundColor: const Color.fromARGB(255, 252, 252, 252),
                  minimumSize: const Size.fromHeight(80),
                ),
                child: const Text(
                  '開始使用',
                  style: TextStyle(color:Color.fromARGB(255, 8, 128, 50),fontSize: 24,fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  // navigate directly to home page
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool('alreadyshowHome', true);

                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(builder: (context) => HomePage(title: '社團活動分享計畫')),
                  // );
                  if (!mounted) return;
                  Navigator.of(context).pushNamed(
                    '/',
                  );
                },
              )
            : Container(
                color: Colors.green.shade100,
                // padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 80,
                child: Container(
                   decoration: const BoxDecoration(
                    color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('跳過',style: TextStyle(color:Color.fromARGB(255, 8, 128, 50),fontWeight: FontWeight.bold),),
                      onPressed: () => controller.jumpToPage(3),
                    ),
                    Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: 4,
                        effect: const WormEffect(
                          spacing: 16,
                          dotColor: Colors.black26,
                          activeDotColor: Color.fromARGB(255, 11, 11, 11),
                        ),
                        onDotClicked: (index) => controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        ),
                      ),
                    ),
                    TextButton(
                      child: const Text('下一步',style: TextStyle(color:Color.fromARGB(255, 8, 128, 50),fontWeight: FontWeight.bold),),
                      onPressed: () => controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                ),
                )
              ),
      );
}
