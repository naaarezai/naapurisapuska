import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/locale_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'terms_of_use_screen.dart';
import 'privacy_policy_screen.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _userService.deleteAccount();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountError)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader(context, l10n.appearance),

          // Theme Mode Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.themeMode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    return SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text(l10n.themeModeSystem),
                          icon: const Icon(Icons.brightness_auto),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text(l10n.themeModeLight),
                          icon: const Icon(Icons.light_mode),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text(l10n.themeModeDark),
                          icon: const Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: {themeService.themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        themeService.setThemeMode(newSelection.first);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // Language Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<LocaleService>(
                  builder: (context, localeService, child) {
                    String? currentLocale;
                    if (localeService.locale == null) {
                      currentLocale = 'system';
                    } else {
                      currentLocale = localeService.locale!.languageCode;
                    }

                    return SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(
                          value: 'system',
                          label: Text(l10n.languageSystem),
                          icon: const Icon(Icons.language),
                        ),
                        ButtonSegment<String>(
                          value: 'fi',
                          label: Text(l10n.languageFinnish),
                          icon: const Text('🇫🇮'),
                        ),
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text(l10n.languageEnglish),
                          icon: const Text('🇬🇧'),
                        ),
                      ],
                      selected: {currentLocale},
                      onSelectionChanged: (Set<String> newSelection) {
                        final selected = newSelection.first;
                        if (selected == 'system') {
                          localeService.setSystemLocale();
                        } else if (selected == 'fi') {
                          localeService.setFinnish();
                        } else {
                          localeService.setEnglish();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(),
          _buildSectionHeader(context, l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: Text(l10n.version),
            subtitle: const Text('1.0.22+22'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.grey),
            title: Text(l10n.termsOfUse),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfUseScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
            title: Text(l10n.privacyPolicy),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              l10n.deleteAccount,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
