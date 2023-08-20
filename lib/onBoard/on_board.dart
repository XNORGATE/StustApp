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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 500,
              width: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  urlImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 85, 179, 241),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                urlImage: 'assets/homeWork.jpg',
                title: '快速繳交/查看作業',
                subtitle: '不用再煩惱作業繳交/查看要載入許久',
              ),
              buildPage(
                color: Colors.blue.shade100,
                urlImage: 'assets/bulletins.jpg',
                title: '快速查看即時公告',
                subtitle: '不必再開一堆網頁',
              ),
              buildPage(
                color: Colors.blue.shade100,
                urlImage: 'assets/leaveRequest.jpg',
                title: '快速請假',
                subtitle: '最簡潔快速的請假功能',
              ),
              buildPage(
                color: Colors.blue.shade100,
                urlImage: 'assets/homePage.jpg',
                title: '首頁',
                subtitle: '美食地圖，校園活動，最新消息，快速查看成績，計算GPA，以及更多功能都在南臺通',
              ),
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
                  style: TextStyle(fontSize: 24),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('跳過'),
                      onPressed: () => controller.jumpToPage(2),
                    ),
                    Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: 4,
                        effect: const WormEffect(
                          spacing: 16,
                          dotColor: Colors.black26,
                          activeDotColor: Color.fromARGB(255, 85, 179, 241),
                        ),
                        onDotClicked: (index) => controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        ),
                      ),
                    ),
                    TextButton(
                      child: const Text('下一步'),
                      onPressed: () => controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                ),
              ),
      );
}
