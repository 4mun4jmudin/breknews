// lib/views/widgets/profile_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui'; // Import untuk ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/profile_controller.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

// Kunci untuk mengakses data dari map userData
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
  // Helper untuk menampilkan gambar profil
  Widget _buildProfileImage(String? path, {double? width, double? height}) {
    // Widget default jika tidak ada gambar
    Widget placeholder = Icon(
      Icons.person_rounded,
      size: width ?? 60,
      color: helper.cWhite.withOpacity(0.8),
    );

    if (path == null || path.isEmpty) {
      return placeholder;
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
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
        return placeholder;
      }
    }
  }

  // Helper untuk baris info di tata letak dua kolom
  Widget _buildDetailItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          helper.hsMedium,
          Expanded(
            child: Text(
              text.isNotEmpty ? text : "...",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk ikon melingkar di baris aksi
  Widget _buildCircularActionIcon(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  // Fungsi untuk meluncurkan URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tidak dapat membuka $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Consumer<ProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.userData == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }
            if (controller.userData == null) {
              return const Center(child: Text("Data profil tidak ditemukan."));
            }

            final userData = controller.userData!;
            final displayName =
                userData[_DbColumnNames.columnUsername] as String? ??
                'Nama Pengguna';
            final displayEmail =
                userData[_DbColumnNames.columnEmail] as String? ??
                'email@example.com';
            final profilePicPath =
                userData[_DbColumnNames.columnProfilePicturePath] as String?;
            final phoneNumber =
                userData[_DbColumnNames.columnPhoneNumber] as String? ?? '';
            final address =
                userData[_DbColumnNames.columnAddress] as String? ?? '';
            final city = userData[_DbColumnNames.columnCity] as String? ?? '';

            return RefreshIndicator(
              onRefresh: () => controller.refreshProfile(),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280.0,
                    pinned: true,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        displayName,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildProfileImage(
                            profilePicPath,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 2.0,
                              sigmaY: 2.0,
                            ),
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
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
                                      width: 100,
                                      height: 100,
                                      child: _buildProfileImage(
                                        profilePicPath,
                                        width: 100,
                                      ),
                                    ),
                                  ),
                                ),
                                helper.vsMedium,
                                // Nama dan email sekarang ada di title AppBar
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Baris Aksi Ikon Melingkar
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          color: theme.colorScheme.primary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCircularActionIcon(
                                context,
                                icon: Icons.phone_outlined,
                                onPressed: () => _launchUrl('tel:$phoneNumber'),
                              ),
                              _buildCircularActionIcon(
                                context,
                                icon: Icons.email_outlined,
                                onPressed: () =>
                                    _launchUrl('mailto:$displayEmail'),
                              ),
                              _buildCircularActionIcon(
                                context,
                                icon: Icons.public_outlined,
                                onPressed: () {},
                              ),
                              _buildCircularActionIcon(
                                context,
                                icon: Icons.settings_outlined,
                                onPressed: () =>
                                    context.pushNamed(RouteName.settings),
                              ),
                            ],
                          ),
                        ),

                        // Detail Informasi Dua Kolom
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(1),
                            },
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: theme.dividerColor.withOpacity(0.5),
                                width: 1,
                              ),
                              verticalInside: BorderSide(
                                color: theme.dividerColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            children: [
                              TableRow(
                                children: [
                                  _buildDetailItem(
                                    icon: Icons.email_outlined,
                                    text: displayEmail,
                                  ),
                                  _buildDetailItem(
                                    icon: Icons.phone_android_outlined,
                                    text: phoneNumber,
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  _buildDetailItem(
                                    icon: Icons.location_on_outlined,
                                    text: address,
                                  ),
                                  _buildDetailItem(
                                    icon: Icons.location_city_outlined,
                                    text: city,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Tombol Aksi Utama
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text("Edit Profile"),
                                onPressed: () async {
                                  final String? currentUserId = controller
                                      .userData?[_DbColumnNames.columnId];
                                  if (currentUserId != null) {
                                    final bool? profileWasUpdated =
                                        await context.pushNamed<bool>(
                                          RouteName.editProfile,
                                          extra: currentUserId,
                                        );
                                    if (profileWasUpdated == true && mounted) {
                                      controller.refreshProfile();
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ),
                              helper.vsSmall,
                              OutlinedButton.icon(
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text("Logout"),
                                onPressed: () => controller.logout(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        helper.vsLarge,
                      ],
                    ),
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
