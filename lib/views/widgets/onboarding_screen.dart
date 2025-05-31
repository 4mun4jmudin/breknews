// lib/views/widgets/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class OnboardingPageUIData {
  final String backgroundImagePath;
  final String? foregroundImagePath;
  final String title;
  final String description;
  final Color dominantColor;
  final Color backgroundColor;

  OnboardingPageUIData({
    required this.backgroundImagePath,
    this.foregroundImagePath,
    required this.title,
    required this.description,
    required this.dominantColor,
    required this.backgroundColor,
  });
}

class OnboardingController with ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageUIData> _pages = [
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/oren.jpg',
      foregroundImagePath: 'assets/images/img intro 1.png',
      title: 'Hi-Tech',
      description:
          'Explore the latest advancements and technological breakthroughs shaping our future.',
      dominantColor: Colors.orange.shade700,
      backgroundColor: Colors.orange.shade100,
    ),
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/biru.jpg',
      foregroundImagePath: 'assets/images/img intro 2.png',
      title: 'Personality',
      description:
          'Understand diverse personalities and enhance your interpersonal skills effectively.',
      dominantColor: Colors.blue.shade700,
      backgroundColor: Colors.blue.shade100,
    ),
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/hejo.jpg',
      foregroundImagePath: 'assets/images/img intro 3.png',
      title: 'Global Mind',
      description:
          'Develop a global mindset to navigate and succeed in an interconnected world.',
      dominantColor: Colors.green.shade700,
      backgroundColor: Colors.green.shade100,
    ),
  ];

  List<OnboardingPageUIData> get pages => _pages;
  int get totalPages => _pages.length;
  int get currentPage => _currentPage;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPageOrFinish(BuildContext context) {
    if (_currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(RouteName.login);
    }
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
    final ThemeData appTheme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Consumer<OnboardingController>(
        builder: (context, controller, child) {
          final currentPageData = controller.pages[controller.currentPage];
          final Color currentDominantColor = currentPageData.dominantColor;

          return Scaffold(
            body: Column(
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
                        backgroundImagePath: pageData.backgroundImagePath,
                        foregroundImagePath: pageData.foregroundImagePath,
                        title: pageData.title,
                        description: pageData.description,
                        dominantColor: pageData.dominantColor,
                        backgroundColor: pageData.backgroundColor,
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: MediaQuery.of(context).padding.bottom > 0
                        ? 24.0
                        : 32.0,
                  ),
                  child: Column(
                    children: [
                      _buildPageIndicator(
                        controller,
                        currentDominantColor,
                        appTheme,
                      ),
                      SizedBox(height: controller.totalPages > 1 ? 30.0 : 0),
                      _buildNavigationButton(
                        context,
                        controller,
                        currentDominantColor,
                        appTheme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(
    OnboardingController controller,
    Color activeColor,
    ThemeData theme,
  ) {
    if (controller.totalPages <= 1) return const SizedBox.shrink();

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
            color: controller.currentPage == index
                ? activeColor
                : theme.colorScheme.onSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    OnboardingController controller,
    Color buttonColor,
    ThemeData theme,
  ) {
    final bool isLastPage = controller.currentPage == controller.totalPages - 1;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => controller.nextPageOrFinish(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(isLastPage ? 'Mulai' : 'Selanjutnya'),
      ),
    );
  }
}

class _OnboardingPageContentWidget extends StatelessWidget {
  final String backgroundImagePath;
  final String? foregroundImagePath;
  final String title;
  final String description;
  final Color dominantColor;
  final Color backgroundColor;

  const _OnboardingPageContentWidget({
    super.key,
    required this.backgroundImagePath,
    this.foregroundImagePath,
    required this.title,
    required this.description,
    required this.dominantColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: backgroundColor,
              child: Center(
                child: Icon(
                  Icons.error_outline,
                  color: dominantColor,
                  size: 50,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                  backgroundColor.withOpacity(0.5),
                  backgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          if (foregroundImagePath != null)
            Positioned.fill(
              bottom: screenHeight * 0.25,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  foregroundImagePath!,
                  height: screenHeight * 0.5,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          Positioned(
            bottom: screenHeight * 0.05,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: helper.headline2.copyWith(
                    color: Colors.white,
                    fontWeight: helper.bold,
                    shadows: [
                      const Shadow(
                        blurRadius: 8.0,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                helper.vsSmall,
                Text(
                  description,
                  style: helper.subtitle1.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                    shadows: [
                      const Shadow(
                        blurRadius: 6.0,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
