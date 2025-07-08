// lib/views/widgets/onboarding_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class OnboardingPageUIData {
  final String illustrationPath;
  final String title;
  final String description;

  OnboardingPageUIData({
    required this.illustrationPath,
    required this.title,
    required this.description,
  });
}

class OnboardingController with ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageUIData> _pages = [
    OnboardingPageUIData(
      illustrationPath: 'assets/images/img intro 1.png',
      title: 'Berita Terkini di Ujung Jari',
      description:
          'Jangan lewatkan momen penting. Dapatkan pembaruan berita global, dari politik hingga tren budaya, secara real-time dan tepercaya.',
    ),
    OnboardingPageUIData(
      illustrationPath: 'assets/images/img intro 2.png',
      title: 'Feed Berita Sesuai Minat Anda',
      description:
          'Atur preferensi dan temukan cerita yang benar-benar penting bagi Anda. Dari teknologi, bisnis, hingga olahraga, semua bisa disesuaikan.',
    ),
    OnboardingPageUIData(
      illustrationPath: 'assets/images/img intro 3.png',
      title: 'Jadi Bagian dari Cerita',
      description:
          'Tidak hanya membaca, Anda juga bisa berkontribusi. Tulis dan publikasikan artikel Anda sendiri, lalu bagikan pandangan Anda dengan dunia.',
    ),
  ];

  List<OnboardingPageUIData> get pages => _pages;
  int get totalPages => _pages.length;
  int get currentPage => _currentPage;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPage(BuildContext context) {
    pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void skip(BuildContext context) {
    context.goNamed(RouteName.login);
  }

  void finish(BuildContext context) {
    context.goNamed(RouteName.login);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class WaveCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height - 90);
    var secondEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Scaffold(
        // 1. Latar belakang utama diubah
        backgroundColor: helper.cPrimary,
        body: Consumer<OnboardingController>(
          builder: (context, controller, child) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.totalPages,
                    itemBuilder: (context, index) {
                      final pageData = controller.pages[index];
                      return _OnboardingPageContentWidget(
                        key: ValueKey('onboarding_page_$index'),
                        illustrationPath: pageData.illustrationPath,
                        title: pageData.title,
                        description: pageData.description,
                      );
                    },
                  ),
                ),
                _buildPageIndicator(controller, appTheme),
                helper.vsXLarge,
                _buildNavigationControls(context, controller),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicator(OnboardingController controller, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: controller.currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            // 2. Warna indikator disesuaikan
            color: controller.currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls(
    BuildContext context,
    OnboardingController controller,
  ) {
    // final theme = Theme.of(context);
    final isLastPage = controller.currentPage == controller.totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.5),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: isLastPage
            ? SizedBox(
                key: const ValueKey('finish_button'),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.finish(context),
                  // 3. Style tombol diubah agar kontras
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: helper.cPrimary,
                  ),
                  child: const Text('Mulai'),
                ),
              )
            : SizedBox(
                key: const ValueKey('nav_buttons'),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => controller.skip(context),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => controller.nextPage(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: helper.cPrimary,
                      ),
                      child: const Row(
                        children: [
                          Text('Next'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _OnboardingPageContentWidget extends StatelessWidget {
  final String illustrationPath;
  final String title;
  final String description;

  const _OnboardingPageContentWidget({
    super.key,
    required this.illustrationPath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: ClipPath(
            clipper: WaveCurveClipper(),
            child: Container(
              color: Colors.white, // Area kurva menjadi putih
              width: double.infinity,
              child: Stack(
                children: [
                  // 4. Warna hiasan disesuaikan
                  Positioned(
                    top: screenHeight * 0.1,
                    left: 20,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.2,
                    right: 40,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.08,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 100,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 60.0,
                      top: screenHeight * 0.1,
                    ),
                    child: Image.asset(
                      illustrationPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.hide_image_outlined, size: 100),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                helper.vsLarge,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  // 5. Warna teks diubah menjadi putih
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                helper.vsMedium,
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
