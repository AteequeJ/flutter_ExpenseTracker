import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/notification_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(localizations.translate('account')),
                  subtitle: Text(authProvider.currentUser?.email ?? ''),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(localizations.translate('logout')),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(
                              localizations.translate('confirm_logout'),
                            ),
                            content: Text(
                              localizations.translate('logout_confirmation'),
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: Text(localizations.translate('cancel')),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: Text(localizations.translate('logout')),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.loginRoute,
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(localizations.translate('language')),
                  trailing: DropdownButton<String>(
                    value: languageProvider.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        print(value);
                        languageProvider.setLanguage(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                      DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                    ],
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: Text(localizations.translate('dark_mode')),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: Text(localizations.translate('daily_reminder')),
                  subtitle: Text(
                    localizations.translate('reminder_description'),
                  ),
                  value: true,
                  onChanged: (value) async {
                    if (value) {
                      await NotificationHelper.scheduleDaily(
                        id: 1,
                        title: 'Expense Reminder',
                        body:
                            'Don\'t forget to record your expenses for today!',
                        hour: 20,
                        minute: 0,
                      );
                    } else {
                      await NotificationHelper.cancelNotification(1);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(localizations.translate('about')),
                  subtitle: const Text('Expense Tracker v1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
