import 'package:flutter/material.dart';
import 'package:stichanda_driver/view/screen/profile/update_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final Map<String, dynamic> profileData = {
    'firstName': 'John',
    'lastName': 'Doe',
    'imageUrl': 'https://static.vecteezy.com/system/resources/thumbnails/003/337/584/small_2x/default-avatar-photo-placeholder-profile-icon-vector.jpg',
    'version': '1.0.0',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Profile Picture
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 3,
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      profileData['imageUrl'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                '${profileData['firstName']} ${profileData['lastName']}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Profile Actions Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildProfileButton(
                      context,
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateProfileScreen())),
                    ),
                    _divider(context),
                    _buildProfileButton(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () => _showSnack(context, 'Change Password tapped'),
                    ),

                    _divider(context),
                    _buildProfileButton(
                      context,
                      icon: Icons.logout_outlined,
                      title: 'Logout',
                      iconColor: Colors.red,
                      onTap: () => _showSnack(context, 'Logout tapped'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // App Version Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Version: ${profileData['version']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Generic Button Builder
  Widget _buildProfileButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        bool isToggle = false,
        bool isActive = false,
        Color? iconColor,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  size: 20, color: iconColor ?? Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (isToggle)
              Container(
                width: 50,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.5),
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment:
                  isActive ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.2),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
