// lib/views/widgets/profile_screen.dart
import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/profile_controller.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';
import '../../services/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentBottomNavIndex = 2;

  void _onBottomNavTapped(int index) {
    if (index == _currentBottomNavIndex) return;
    switch (index) {
      case 0:
        context.goNamed(RouteName.home);
        break;
      case 1:
        context.goNamed(RouteName.bookmark);
        break;
      case 2:
        break;
    }
  }

  Widget _buildProfileDetailRow(
      BuildContext context, String label, String? value) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: helper.cBlack
                    .withOpacity(0.9), // Warna hitam tetap untuk label
                fontWeight: helper.regular,
              ),
            ),
          ),
          helper.hsTiny,
          Expanded(
            child: Text(
              value?.isNotEmpty ?? false ? value! : "Belum diisi",
              style: textTheme.bodyLarge?.copyWith(
                color: helper.cBlack, // Warna hitam tetap untuk value
                fontWeight: helper.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String title,
      {VoidCallback? onTap}) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fitur "$title" belum tersedia.')),
            );
            debugPrint("$title di-tap");
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: helper.cBlack, size: 30),
            helper.hsMedium,
            Expanded(
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: helper.cBlack,
                  fontWeight: helper.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 20, color: helper.cBlack.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/bgf.jpg', // Ganti dengan path gambar Anda
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Consumer<ProfileController>(
                builder: (context, controller, child) {
                  if (controller.isLoading && controller.userData == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    );
                  }
                  if (controller.errorMessage != null &&
                      controller.userData == null) {
                    return Center(
                        child: Text(controller.errorMessage!,
                            style: textTheme.titleMedium));
                  }
                  if (controller.userData == null) {
                    return Center(
                        child: Text("Tidak dapat memuat data profil.",
                            style: textTheme.titleMedium));
                  }

                  final userData = controller.userData!;
                  String displayName =
                      userData.containsKey(DatabaseHelper.columnUsername)
                          ? userData.containsKey(DatabaseHelper.columnUsername)
                              ? userData['username'] as String
                              : 'Nama Pengguna'
                          : 'Nama Pengguna';
                  String displayEmail =
                      userData.containsKey(DatabaseHelper.columnEmail)
                          ? userData.containsKey(DatabaseHelper.columnEmail)
                              ? userData['email'] as String
                              : 'email@example.com'
                          : 'email@example.com';
                  String? profilePicPath = userData
                          .containsKey(DatabaseHelper.columnProfilePicturePath)
                      ? userData.containsKey(
                              DatabaseHelper.columnProfilePicturePath)
                          ? userData['profile_picture_path'] as String?
                          : null
                      : null;
                  String displayPhoneNumber = userData
                          .containsKey(DatabaseHelper.columnPhoneNumber)
                      ? userData.containsKey(DatabaseHelper.columnPhoneNumber)
                          ? userData['phone_number'] as String
                          : ""
                      : "";
                  String displayAddress =
                      userData.containsKey(DatabaseHelper.columnAddress)
                          ? userData.containsKey(DatabaseHelper.columnAddress)
                              ? userData['address'] as String
                              : ""
                          : "";
                  String displayCity =
                      userData.containsKey(DatabaseHelper.columnCity)
                          ? userData.containsKey(DatabaseHelper.columnCity)
                              ? userData['city'] as String
                              : ""
                          : "";

                  return RefreshIndicator(
                    onRefresh: () => controller.refreshProfile(),
                    color: colorScheme.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        // Tambahkan padding utama untuk keseluruhan konten
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                "Data Diri", // Teks tambahan Anda
                                style: textTheme.titleMedium?.copyWith(
                                    color: textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text("Profil",
                                    style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary)),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.0),
                                // border: Border.all(
                                //   color: theme.dividerColor,
                                //   width: 0.5,
                                // ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3.0,
                                    spreadRadius: 1.0,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 80,
                                          backgroundColor: theme.highlightColor,
                                          backgroundImage: (profilePicPath !=
                                                      null &&
                                                  profilePicPath.isNotEmpty)
                                              ? FileImage(File(profilePicPath))
                                              : null,
                                          child: (profilePicPath == null ||
                                                  profilePicPath.isEmpty)
                                              ? Icon(Icons.person_rounded,
                                                  size: 70,
                                                  color: theme.hintColor
                                                      .withOpacity(0.7))
                                              : null,
                                        ),
                                        helper.vsMedium,
                                        // Text(
                                        //   displayName,
                                        //   style: textTheme.headlineSmall
                                        //       ?.copyWith(
                                        //           fontWeight: FontWeight.bold,
                                        //           color: textTheme
                                        //               .bodyLarge?.color),
                                        //   textAlign: TextAlign.center,
                                        // ),
                                      ],
                                    ),
                                  ),
                                  _buildProfileDetailRow(
                                      context,
                                      "Nama \u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0:",
                                      displayName),
                                  _buildProfileDetailRow(
                                      context,
                                      "Email\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0:",
                                      displayEmail),
                                  _buildProfileDetailRow(
                                      context,
                                      "Number\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0:",
                                      displayPhoneNumber),
                                  _buildProfileDetailRow(
                                      context,
                                      "Address\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0:",
                                      displayAddress),
                                  _buildProfileDetailRow(
                                      context,
                                      "Kota\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0:",
                                      displayCity),
                                ],
                              ),
                            ),
                            helper.vsLarge,

                            // --- ITEM AKSI ---
                            // Text(
                            //   "Lainnya",
                            //   style: textTheme.titleMedium?.copyWith(
                            //       fontWeight: FontWeight.bold,
                            //       color: colorScheme.primary),
                            //   textAlign: TextAlign.start,
                            // ),
                            helper.vsSmall,
                            Column(
                              children: [
                                _buildActionItem(
                                  context,
                                  Icons.edit_note_rounded,
                                  "Edit Profile",
                                  onTap: () async {
                                    final int? currentUserId = controller
                                        .userData?[DatabaseHelper.columnId];
                                    if (currentUserId != null) {
                                      final bool? profileWasUpdated =
                                          await context.pushNamed<bool>(
                                        RouteName.editProfile,
                                        extra: currentUserId,
                                      );
                                      if (profileWasUpdated == true &&
                                          mounted) {
                                        controller.refreshProfile();
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'User ID tidak ditemukan untuk edit profil.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                                Divider(height: 1, color: helper.cBlack),
                                _buildActionItem(
                                  context,
                                  Icons.settings_suggest_rounded,
                                  "Pengaturan",
                                  onTap: () {
                                    context.pushNamed(RouteName.settings);
                                  },
                                ),
                                Divider(height: 1, color: helper.cBlack),
                                _buildActionItem(
                                  context,
                                  Icons.logout_rounded,
                                  "Logout",
                                  onTap: () => controller.logout(context),
                                ),
                                Divider(height: 1, color: helper.cBlack),
                              ],
                            ),
                            helper.vsLarge,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          // Warna sudah diatur oleh BottomNavigationBarThemeData di main.dart
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline), label: 'Bookmark'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
