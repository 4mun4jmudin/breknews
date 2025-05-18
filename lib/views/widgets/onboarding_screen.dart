// lib/views/widgets/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class OnboardingController with ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;
  static const int totalPages = 3;

  int get currentPage => _currentPage;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = helper.screenHeight(context);
    final String? defaultFontFamily = helper.headline1.fontFamily;

    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Scaffold(
        backgroundColor: helper.cWhite,
        body: Consumer<OnboardingController>(
          builder: (context, controller, child) {
            return SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      children: <Widget>[
                        // ------------------------------ Halaman Onboarding 1 ------------------------------//
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Image.asset(
                                  'assets/img intro 1.png',
                                  height: screenHeight * 0.35,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: screenHeight * 0.35,
                                    color: helper.cGrey,
                                    child: const Center(
                                      child: Text('Gagal memuat gambar'),
                                    ),
                                  ),
                                ),
                              ),
                              helper.vsLarge,
                              Divider(color: helper.cBlack, thickness: 2.0),
                              helper.vsMedium,
                              Text(
                                'The World at Your Fingertips',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: helper.cTextBlue,
                                  fontWeight: helper.bold,
                                  fontFamily: defaultFontFamily,
                                ),
                              ),
                              helper.vsMedium,
                              Text(
                                'Get 24/7 updates on global news - from breaking politics to cultural trends, all in one place.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: helper.cBlack,
                                  fontWeight: helper.regular,
                                  fontFamily: defaultFontFamily,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ----------------------------- halaman 2 -----------------------------//
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Image.asset(
                                  'assets/img intro 2.png',
                                  height: screenHeight * 0.35,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: screenHeight * 0.35,
                                    color: helper.cGrey,
                                    child: const Center(
                                      child: Text('Gagal memuat gambar'),
                                    ),
                                  ),
                                ),
                              ),
                              helper.vsLarge,
                              Divider(
                                color: helper.cBlack,
                                thickness: 2.0,
                              ),
                              helper.vsMedium,
                              Text(
                                'Tailored to Your Curiosity',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: helper.cTextBlue,
                                  fontWeight: helper.bold,
                                  fontFamily: defaultFontFamily,
                                ),
                              ),
                              helper.vsMedium,
                              Text(
                                'Personalize your news feed. Discover stories that matter to you, from technology to sports.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: helper.cBlack,
                                  fontWeight: helper.regular,
                                  fontFamily: defaultFontFamily,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ---------------------- halaman 3 ----------------------//
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Image.asset(
                                  'assets/img intro 3.png',
                                  height: screenHeight * 0.35,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: screenHeight * 0.35,
                                    color: helper.cGrey,
                                    child: const Center(
                                      child: Text('Gagal memuat gambar'),
                                    ),
                                  ),
                                ),
                              ),
                              helper.vsLarge,
                              Divider(
                                color: helper.cBlack,
                                thickness: 2.0,
                              ),
                              helper.vsMedium,
                              Text(
                                'Trusted Updates in Real-Time',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: helper.cTextBlue,
                                  fontWeight: helper.bold,
                                  fontFamily: defaultFontFamily,
                                ),
                              ),
                              helper.vsMedium,
                              Text(
                                'Stay informed with verified news, delivered instantly as events unfold around the globe.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: helper.cBlack,
                                  fontWeight: helper.regular,
                                  fontFamily: defaultFontFamily,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPageIndicator(controller),
                  helper.vsLarge,
                  _buildNavigationButtons(context, controller),
                  helper.vsLarge,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicator(OnboardingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        OnboardingController.totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: controller.currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: controller.currentPage == index
                ? helper.cPrimary
                : helper.cLinear,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, OnboardingController controller) {
    final buttonTextStyle =
        helper.subtitle1.copyWith(fontWeight: helper.semibold);

    final bool isLastPage =
        controller.currentPage == OnboardingController.totalPages - 1;

    if (isLastPage) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.goNamed(RouteName.login);
              debugPrint("Tombol Finish ditekan, navigasi ke Login");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: helper.cPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'Get Starterd',
              style: buttonTextStyle.copyWith(color: helper.cWhite),
            ),
          ),
        ),
      );
    } else {
      // ------------------------------tombol Skip dan Next ----------------------------//
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.goNamed(RouteName.login);
                  debugPrint("Tombol Skip ditekan, navigasi ke Login");
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: helper.cGrey,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: buttonTextStyle.copyWith(color: helper.cPrimary),
                ),
              ),
            ),
            helper.hsMedium,
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: helper.cPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Next',
                  style: buttonTextStyle.copyWith(color: helper.cWhite),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
