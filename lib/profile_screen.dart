import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'app_state.dart';
import 'common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Tài khoản'),
            _buildListTile(
              icon: Icons.person_outline,
              title: 'Chỉnh sửa thông tin',
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.security_outlined,
              title: 'Bảo mật',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Cài đặt chung'),
            _buildListTile(
              icon: Icons.notifications_outlined,
              title: 'Thông báo',
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.language_outlined,
              title: 'Ngôn ngữ',
              trailing: const Text('Tiếng Việt', style: TextStyle(color: AppColors.textSecondary)),
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.dark_mode_outlined,
              title: 'Giao diện tối',
              trailing: Switch(
                value: false,
                onChanged: (val) {},
                activeColor: AppColors.primary,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Khác'),
            _buildListTile(
              icon: Icons.help_outline,
              title: 'Trợ giúp & Hỗ trợ',
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.info_outline,
              title: 'Giới thiệu',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.read<AppState>().signOut();
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final appState = context.watch<AppState>();
    final userName = appState.userName;
    final userEmail = appState.userEmail;
    final photoUrl = appState.userPhotoUrl;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? const Icon(Icons.person, size: 40, color: AppColors.primary) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Tài khoản Premium',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.chipBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }
}
