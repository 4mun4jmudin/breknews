// lib/main.dart
// ignore_for_file: deprecated_member_use

import 'package:breaknews/views/widgets/bookmark_screen.dart';
import 'package:breaknews/views/widgets/edit_article_screen.dart';
import 'package:breaknews/views/widgets/edit_profile_screen.dart';
import 'package:breaknews/views/widgets/forgot_password_screen.dart';
import 'package:breaknews/views/widgets/reset_password_screen.dart';
import 'package:breaknews/views/widgets/home_screen.dart';
import 'package:breaknews/views/widgets/news_detail_screen.dart';
import 'package:breaknews/views/widgets/profile_screen.dart';
import 'package:breaknews/views/widgets/register_screen.dart';
import 'package:breaknews/views/widgets/splas_screen.dart';
import 'package:breaknews/views/widgets/settings_screen.dart';
import 'package:breaknews/views/widgets/widgets/change_password_screen.dart';
import 'package:breaknews/views/widgets/add_local_article_screen.dart';
import 'package:breaknews/views/widgets/local_articles_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'views/widgets/onboarding_screen.dart';
import 'views/widgets/login_screen.dart';
import 'routes/route_name.dart';
import 'views/utils/helper.dart' as helper;
import 'data/models/article_model.dart';
import 'controllers/theme_controller.dart';
import 'views/widgets/main_scaffold.dart';
import 'package:breaknews/controllers/local_article_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LocalArticleController()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: RouteName.splash,
  routes: <RouteBase>[
    GoRoute(
      path: RouteName.splash,
      name: RouteName.splash,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/introduction',
      name: RouteName.introduction,
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/login',
      name: RouteName.login,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      name: RouteName.register,
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainScaffold(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          name: RouteName.home,
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/bookmark',
          name: RouteName.bookmark,
          builder: (BuildContext context, GoRouterState state) {
            return const BookmarkScreen();
          },
        ),
        GoRoute(
          path: '/add-local-article',
          name: RouteName.addLocalArticle,
          builder: (BuildContext context, GoRouterState state) {
            return const AddLocalArticleScreen();
          },
        ),
        GoRoute(
          path: '/local-articles',
          name: RouteName.localArticles,
          builder: (BuildContext context, GoRouterState state) {
            return const LocalArticlesScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          name: RouteName.profile,
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'edit',
              name: RouteName.editProfile,
              builder: (BuildContext context, GoRouterState state) {
                final String? userId = state.extra as String?;

                if (userId != null) {
                  return EditProfileScreen(userId: userId);
                } else {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Error')),
                    body: const Center(
                      child: Text('User ID tidak valid untuk edit profil.'),
                    ),
                  );
                }
              },
            ),
            GoRoute(
              path: 'settings',
              name: RouteName.settings,
              builder: (BuildContext context, GoRouterState state) {
                return const SettingsScreen();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'change-password',
                  name: RouteName.changePassword,
                  builder: (BuildContext context, GoRouterState state) {
                    return const ChangePasswordScreen();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/article-detail',
      name: RouteName.articleDetail,
      builder: (BuildContext context, GoRouterState state) {
        final Article? article = state.extra as Article?;
        if (article != null) {
          return NewsDetailScreen(article: article);
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Artikel tidak ditemukan.')),
          );
        }
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: RouteName.forgotPassword,
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: RouteName.resetPassword,
      builder: (BuildContext context, GoRouterState state) {
        final String? email = state.extra as String?;
        if (email != null) {
          return ResetPasswordScreen(email: email);
        }
        return Scaffold(
          appBar: AppBar(title: const Text("Error")),
          body: const Center(
            child: Text("Email tidak valid untuk reset password."),
          ),
        );
      },
    ),
    GoRoute(
      path: '/edit-article',
      name: 'editArticle', // Beri nama rute
      builder: (BuildContext context, GoRouterState state) {
        final Article? article = state.extra as Article?;
        if (article != null) {
          return EditArticleScreen(articleToEdit: article);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(
            child: Text('Artikel tidak ditemukan untuk diedit.'),
          ),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Halaman tidak ditemukan: ${state.error?.message ?? state.uri.toString()}',
      ),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp.router(
      title: 'Break News',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeController.themeMode,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: helper.cPrimary,
      scaffoldBackgroundColor: helper.cWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: helper.cPrimary,
        brightness: Brightness.light,
        primary: helper.cPrimary,
        secondary: helper.cAccent,
        background: helper.cWhite,
        surface: helper.cLightGrey, // Untuk card
        onPrimary: helper.cWhite,
        onSecondary: helper.cWhite,
        onBackground: helper.cTextDark,
        onSurface: helper.cTextDark,
        error: helper.cError,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: helper.cWhite,
        foregroundColor: helper.cTextDark,
        elevation: 0.5,
        titleTextStyle: helper.headline4.copyWith(
          color: helper.cPrimary,
          fontWeight: helper.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: helper.headline1,
        displayMedium: helper.headline2,
        displaySmall: helper.headline3,
        headlineMedium: helper.headline4,
        titleLarge: helper.subtitle1.copyWith(fontWeight: helper.bold),
        bodyLarge: helper.subtitle1.copyWith(color: helper.cTextDark),
        bodyMedium: helper.subtitle2,
        labelLarge: helper.subtitle1.copyWith(fontWeight: helper.semibold),
        bodySmall: helper.caption,
        labelSmall: helper.overline,
      ).apply(bodyColor: helper.cTextDark, displayColor: helper.cTextDark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: helper.cPrimary,
          foregroundColor: helper.cWhite,
          textStyle: helper.subtitle1.copyWith(fontWeight: helper.semibold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: helper.cGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: helper.cPrimary, width: 1.5),
        ),
        labelStyle: helper.subtitle2.copyWith(color: helper.cTextMedium),
        hintStyle: helper.subtitle2.copyWith(
          color: helper.cTextMedium.withOpacity(0.7),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: helper.cWhite,
        selectedItemColor: helper.cPrimary,
        unselectedItemColor: helper.cTextMedium,
        elevation: 2.0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: helper.cPrimary,
      scaffoldBackgroundColor: const Color(
        0xFF121212,
      ), // Latar belakang gelap murni
      colorScheme: ColorScheme.fromSeed(
        seedColor: helper.cPrimary,
        brightness: Brightness.dark,
        primary: helper.cAccent, // Biru cerah sebagai primary di mode gelap
        secondary: helper.cPrimary,
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E), // Untuk card di mode gelap
        onPrimary: helper.cWhite,
        onSecondary: helper.cWhite,
        onBackground: helper.cWhite.withOpacity(0.87),
        onSurface: helper.cWhite.withOpacity(0.87),
        error: helper.cError,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: helper.cWhite.withOpacity(0.87),
        elevation: 0,
        titleTextStyle: helper.headline4.copyWith(
          color: helper.cAccent,
          fontWeight: helper.bold,
        ),
      ),
      textTheme:
          TextTheme(
            displayLarge: helper.headline1.copyWith(
              color: helper.cWhite.withOpacity(0.87),
            ),
            displayMedium: helper.headline2.copyWith(
              color: helper.cWhite.withOpacity(0.87),
            ),
            displaySmall: helper.headline3.copyWith(
              color: helper.cWhite.withOpacity(0.87),
            ),
            headlineMedium: helper.headline4.copyWith(
              color: helper.cWhite.withOpacity(0.87),
            ),
            titleLarge: helper.subtitle1.copyWith(
              color: helper.cWhite.withOpacity(0.87),
              fontWeight: helper.bold,
            ),
            bodyLarge: helper.subtitle1.copyWith(
              color: helper.cWhite.withOpacity(0.87),
            ),
            bodyMedium: helper.subtitle2.copyWith(
              color: helper.cWhite.withOpacity(0.70),
            ),
            labelLarge: helper.subtitle1.copyWith(fontWeight: helper.semibold),
            bodySmall: helper.caption.copyWith(
              color: helper.cWhite.withOpacity(0.70),
            ),
            labelSmall: helper.overline.copyWith(
              color: helper.cWhite.withOpacity(0.70),
            ),
          ).apply(
            bodyColor: helper.cWhite.withOpacity(0.87),
            displayColor: helper.cWhite.withOpacity(0.87),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: helper.cAccent,
          foregroundColor: helper.cWhite,
          textStyle: helper.subtitle1.copyWith(fontWeight: helper.semibold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: helper.cAccent, width: 1.5),
        ),
        labelStyle: helper.subtitle2.copyWith(
          color: helper.cWhite.withOpacity(0.70),
        ),
        hintStyle: helper.subtitle2.copyWith(
          color: helper.cWhite.withOpacity(0.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: helper.cAccent,
        unselectedItemColor: Colors.grey[500],
      ),
    );
  }
}
