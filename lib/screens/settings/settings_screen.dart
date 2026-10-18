import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../theme/theme_controller.dart';
import '../../utils/validators.dart';
import '../auth/login_screen.dart';
import '../../utils/page_transitions.dart';

/// App Settings Screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _wateringReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Receive daily plant care updates',
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          _buildSwitchTile(
            title: 'Watering Reminders',
            subtitle: 'Alert when plants require watering',
            value: _wateringReminders,
            onChanged: (val) => setState(() => _wateringReminders = val),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Appearance'),
          _buildThemeSelector(),
          const SizedBox(height: 24),

          _buildSectionHeader('Account & Privacy'),
          _buildTile(
            title: 'Edit Profile Information',
            onTap: () => _editProfile(context),
          ),
          _buildTile(
            title: 'Change Password',
            onTap: () => _changePassword(context),
          ),
          _buildTile(
            title: 'Privacy Policy',
            onTap: () => _showMessage(
              context,
              'Privacy Policy',
              'Plant photos are sent to Pl@ntNet only when you ask to identify a plant. Your My Plants collection remains on this device in the current app session.',
            ),
          ),
          _buildTile(
            title: 'Terms of Service',
            onTap: () => _showMessage(
              context,
              'Terms of Service',
              'Identification and care guidance are informational. Confirm species-specific care before changing a plant’s routine.',
            ),
          ),
          const SizedBox(height: 32),

          // Logout Action Button
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.error),
            ),
            tileColor: AppColors.errorBackground,
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: Text(
              'Logout',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              AuthService().logout();
              Navigator.of(context).pushAndRemoveUntil(
                AppPageRoute.fadeIn(const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return ListenableBuilder(
      listenable: appThemeController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Choose how Plant Care should appear',
                style: AppTextStyles.bodySmall,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<AppThemePreference>(
                  value: appThemeController.preference,
                  isExpanded: true,
                  onChanged: (value) {
                    if (value != null) appThemeController.setPreference(value);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: AppThemePreference.system,
                      child: Text('System default'),
                    ),
                    DropdownMenuItem(
                      value: AppThemePreference.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: AppThemePreference.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          title: Text(title, style: AppTextStyles.titleMedium),
          subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
          activeTrackColor: Theme.of(context).colorScheme.primary,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTile({required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          title: Text(title, style: AppTextStyles.titleMedium),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = AuthService().currentUser;
    final name = TextEditingController(text: user?.name ?? '');
    final email = TextEditingController(text: user?.email ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isNotEmpty &&
                  email.text.trim().contains('@')) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true) {
      AuthService().updateProfile(name: name.text, email: email.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated.')));
      }
    }
    name.dispose();
    email.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmPassword = TextEditingController();
    final changed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var isSaving = false;
        String? error;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Change password'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPassword,
                    obscureText: true,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Current password',
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm new password',
                    ),
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      newPassword.text,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() {
                          isSaving = true;
                          error = null;
                        });
                        final success = await AuthService().changePassword(
                          currentPassword: currentPassword.text,
                          newPassword: newPassword.text,
                        );
                        if (!dialogContext.mounted) return;
                        if (success) {
                          Navigator.pop(dialogContext, true);
                        } else {
                          setDialogState(() {
                            isSaving = false;
                            error = AuthService().errorMessage;
                          });
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    }
  }

  void _showMessage(BuildContext context, String title, String message) =>
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );
}
