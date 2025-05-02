import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'mood_analysis_screen.dart';

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
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              _buildSettingsCard(
                title: 'Notifications',
                description: 'Enable or disable breathing reminders',
                icon: Icons.notifications,
                trailing: Switch(
                  value: appState.notificationsEnabled,
                  onChanged: (value) {
                    appState.toggleNotifications();
                    if (value) {
                      _showNotificationTimePicker(context, appState);
                    }
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 15),
              if (appState.notificationsEnabled)
                _buildSettingsCard(
                  title: 'Reminder Time',
                  description: 'Set your daily breathing reminder time',
                  icon: Icons.access_time,
                  onTap: () => _showNotificationTimePicker(context, appState),
                  trailing: Text(
                    appState.reminderTime ?? '8:00 PM',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              if (appState.notificationsEnabled) const SizedBox(height: 15),
              _buildSettingsCard(
                title: 'Sound',
                description: 'Choose breathing exercise sounds',
                icon: Icons.music_note,
                onTap: () {
                  _showSoundSelectionDialog(context, appState);
                },
                trailing: Switch(
                  value: appState.soundEnabled,
                  onChanged: (value) {
                    appState.toggleSound();
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 15),
              _buildSettingsCard(
                title: 'Mood Analysis',
                description: 'View your mood history and trends',
                icon: Icons.insights,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodAnalysisScreen(),
                    ),
                  );
                },
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.grey,
                ),
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
        ),
      ),
    );
  }

  void _showSoundSelectionDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sound Selection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable Sound'),
              value: appState.soundEnabled,
              onChanged: (bool value) {
                appState.toggleSound();
                Navigator.pop(context);
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Divider(),
            const Text('Select Sound Type:'),
            const SizedBox(height: 16),
            _buildSoundOption(context, appState, 'Nature',
                'Calming nature sounds', Icons.terrain, 'nature'),
            _buildSoundOption(context, appState, 'Ocean', 'Gentle ocean waves',
                Icons.waves, 'ocean'),
            _buildSoundOption(
                context,
                appState,
                'Meditation',
                'Peaceful meditation bells',
                Icons.self_improvement,
                'meditation'),
            const SizedBox(height: 10),
            const Text(
              'More sounds coming soon!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundOption(
    BuildContext context,
    AppState appState,
    String title,
    String description,
    IconData icon,
    String soundKey,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(
        description,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Radio<String>(
        value: soundKey,
        groupValue: appState.selectedSound,
        onChanged: appState.soundEnabled
            ? (value) {
                if (value != null) {
                  appState.setSelectedSound(value);
                  Navigator.pop(context);
                }
              }
            : null,
        activeColor: AppTheme.primaryColor,
      ),
      enabled: appState.soundEnabled,
      onTap: appState.soundEnabled
          ? () {
              appState.setSelectedSound(soundKey);
              Navigator.pop(context);
            }
          : null,
    );
  }

  void _showNotificationTimePicker(
      BuildContext context, AppState appState) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(appState.reminderTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formattedTime = _formatTimeOfDay(pickedTime);
      appState.setReminderTime(formattedTime);

      // Show a loading indicator while scheduling notification
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      try {
        // Schedule notification for this time
        await appState.scheduleNotification();

        // Close loading dialog
        if (context.mounted) Navigator.of(context).pop();

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Daily reminder set for $formattedTime'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (context.mounted) Navigator.of(context).pop();

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to set reminder: ${e.toString()}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;

    // Parse time like "8:00 PM"
    final parts = timeString.split(' ');
    if (parts.length != 2) return null;

    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) return null;

    int hour = int.tryParse(timeParts[0]) ?? 0;
    final int minute = int.tryParse(timeParts[1]) ?? 0;

    if (parts[1] == 'PM' && hour < 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
