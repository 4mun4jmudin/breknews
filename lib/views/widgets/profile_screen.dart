// lib/views/widgets/profile_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui'; // Untuk ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/profile_controller.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class _DbColumnNames {
  static const columnId = '_id';
  static const columnUsername = 'username';
  static const columnEmail = 'email';
  static const columnPhoneNumber = 'phone_number';
  static const columnAddress = 'address';
  static const columnCity = 'city';
  static const columnProfilePicturePath = 'profile_picture_path';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- WIDGET HELPER BARU UNTUK MENAMPILKAN GAMBAR ---
  Widget _buildProfileImage(String? path, {double? width, double? height}) {
    if (path == null || path.isEmpty) {
      return Icon(
        Icons.person_rounded,
        size: 60,
        color: helper.cWhite.withOpacity(0.8),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person_rounded,
          size: 60,
          color: helper.cWhite.withOpacity(0.8),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      );
    } else {
      final imageFile = File(path);
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      } else {
        return Icon(
          Icons.person_rounded,
          size: 60,
          color: helper.cWhite.withOpacity(0.8),
        );
      }
    }
  }

  Widget _buildProfileDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final Color textColor = theme.brightness == Brightness.dark
        ? helper.cWhite.withOpacity(0.9)
        : helper.cBlack.withOpacity(0.8);
    final Color labelColor = theme.brightness == Brightness.dark
        ? helper.cGrey.withOpacity(0.8)
        : helper.cTextBlue.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          helper.hsMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                helper.vsSuperTiny,
                Text(
                  value?.isNotEmpty ?? false ? value! : "Belum diisi",
                  style: textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final Color itemColor = theme.brightness == Brightness.dark
        ? helper.cWhite
        : helper.cBlack;

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: 26),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: itemColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: itemColor.withOpacity(0.7),
      ),
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fitur "$title" belum tersedia.')),
            );
          },
      contentPadding: const EdgeInsets.symmetric(
        vertical: 6.0,
        horizontal: 8.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    final Color headerTextColor = helper.cWhite;

    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: headerTextColor.withOpacity(0.8),
            ),
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
        ),
        body: Consumer<ProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              );
            }
            if (controller.userData == null) {
              return Center(
                child: Text(
                  "Tidak dapat memuat data profil.",
                  style: textTheme.titleMedium,
                ),
              );
            }

            final userData = controller.userData!;
            String displayName =
                userData[_DbColumnNames.columnUsername] as String? ??
                'Nama Pengguna';
            String displayEmail =
                userData[_DbColumnNames.columnEmail] as String? ??
                'email@example.com';
            String? profilePicPath =
                userData[_DbColumnNames.columnProfilePicturePath] as String?;
            String displayPhoneNumber =
                userData[_DbColumnNames.columnPhoneNumber] as String? ?? "";
            String displayAddress =
                userData[_DbColumnNames.columnAddress] as String? ?? "";
            String displayCity =
                userData[_DbColumnNames.columnCity] as String? ?? "";

            return RefreshIndicator(
              onRefresh: () => controller.refreshProfile(),
              color: colorScheme.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 280.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                    elevation: 2.0,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        displayName,
                        style: textTheme.titleLarge?.copyWith(
                          color: headerTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRect(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 2.0,
                                sigmaY: 2.0,
                              ),
                              child: _buildProfileImage(
                                profilePicPath,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),

                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 55,
                                  backgroundColor: theme.cardColor.withOpacity(
                                    0.5,
                                  ),
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 110,
                                      height: 110,
                                      child: _buildProfileImage(profilePicPath),
                                    ),
                                  ),
                                ),
                                helper.vsMedium,
                                Text(
                                  displayName,
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: headerTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                helper.vsSuperTiny,
                                Text(
                                  displayEmail,
                                  style: textTheme.titleSmall?.copyWith(
                                    color: headerTextColor.withOpacity(0.85),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 3.0,
                              margin: const EdgeInsets.only(bottom: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        bottom: 8.0,
                                        top: 4.0,
                                      ),
                                      child: Text(
                                        "Detail Informasi",
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    _buildProfileDetailRow(
                                      context,
                                      Icons.phone_android_rounded,
                                      "Nomor HP",
                                      displayPhoneNumber,
                                    ),
                                    Divider(
                                      height: 1,
                                      color: theme.dividerColor.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    _buildProfileDetailRow(
                                      context,
                                      Icons.location_on_outlined,
                                      "Alamat",
                                      displayAddress,
                                    ),
                                    Divider(
                                      height: 1,
                                      color: theme.dividerColor.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    _buildProfileDetailRow(
                                      context,
                                      Icons.location_city_rounded,
                                      "Kota",
                                      displayCity,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Card(
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                child: Column(
                                  children: [
                                    _buildActionItem(
                                      context,
                                      Icons.edit_attributes_outlined,
                                      "Edit Profile",
                                      onTap: () async {
                                        final String? currentUserId = controller
                                            .userData?[_DbColumnNames.columnId];
                                        if (currentUserId != null) {
                                          final bool? profileWasUpdated =
                                              await context.pushNamed<bool>(
                                                RouteName.editProfile,
                                                extra:
                                                    currentUserId, // Kirim ID sebagai string
                                              );
                                          if (profileWasUpdated == true &&
                                              mounted) {
                                            controller.refreshProfile();
                                          }
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'User ID tidak ditemukan untuk edit profil.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    Divider(
                                      indent: 16,
                                      endIndent: 16,
                                      color: theme.dividerColor.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    _buildActionItem(
                                      context,
                                      Icons.settings_outlined,
                                      "Pengaturan",
                                      onTap: () =>
                                          context.pushNamed(RouteName.settings),
                                    ),
                                    Divider(
                                      indent: 16,
                                      endIndent: 16,
                                      color: theme.dividerColor.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    _buildActionItem(
                                      context,
                                      Icons.logout_rounded,
                                      "Logout",
                                      onTap: () => controller.logout(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            helper.vsLarge,
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
