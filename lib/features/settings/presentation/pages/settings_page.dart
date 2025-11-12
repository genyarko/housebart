import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/theme_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Theme Selector
            const ThemeSelector(),

            // Preferences Section
            _MenuSection(
              title: 'Preferences',
              items: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notifications',
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                _MenuItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'Choose your language',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language settings coming soon')),
                    );
                  },
                ),
              ],
            ),

            // Privacy & Security Section
            _MenuSection(
              title: 'Privacy & Security',
              items: [
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy',
                  subtitle: 'Manage your privacy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy settings coming soon')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.security_outlined,
                  title: 'Security',
                  subtitle: 'Password and security',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Security settings coming soon')),
                    );
                  },
                ),
              ],
            ),

            // Support Section
            _MenuSection(
              title: 'Support',
              items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help coming soon')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback coming soon')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App info',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'HouseBart',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 HouseBart. All rights reserved.',
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () => context.push(AppRoutes.termsOfService),
                ),
                _MenuItem(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our policy',
                  onTap: () => context.push(AppRoutes.privacyPolicy),
                ),
              ],
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              context.read<AuthBloc>().add(AuthLogoutRequested());
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
