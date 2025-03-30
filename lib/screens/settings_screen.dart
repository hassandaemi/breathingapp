import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Settings',
                  style: AppTheme.titleStyle,
                ),
              ),
              const SizedBox(height: 30),
              _buildSettingsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSettingsCard(
            title: 'Notifications',
            description: 'Enable or disable breathing reminders',
            icon: Icons.notifications,
            trailing: Switch(
              value: appState.notificationsEnabled,
              onChanged: (value) {
                appState.toggleNotifications();
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingsCard(
            title: 'Animation Style',
            description: 'Change the breathing animation type',
            icon: Icons.animation,
            trailing: DropdownButton<String>(
              value: appState.animationStyle,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  appState.setAnimationStyle(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'Circle',
                  child: Text('Circle'),
                ),
                DropdownMenuItem(
                  value: 'Linear',
                  enabled: false,
                  child: Text('Linear (Coming Soon)'),
                ),
                DropdownMenuItem(
                  value: 'Square',
                  enabled: false,
                  child: Text('Square (Coming Soon)'),
                ),
              ],
              underline: Container(
                height: 0,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingsCard(
            title: 'Sound',
            description: 'Choose breathing exercise sounds',
            icon: Icons.music_note,
            trailing: const Text(
              'Coming Soon',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingsCard(
            title: 'Reset Points',
            description: 'Reset your accumulated points',
            icon: Icons.refresh,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Points'),
                  content: const Text(
                      'Are you sure you want to reset your points to zero?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Reset points
                        Provider.of<AppState>(context, listen: false)
                            .addPoints(-appState.points);
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          _buildSettingsCard(
            title: 'About',
            description: 'About Breathly app',
            icon: Icons.info_outline,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Breathly',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 Breathly',
                children: const [
                  SizedBox(height: 20),
                  Text(
                    'A breathing exercise app designed to help users relax and reduce stress.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String description,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
