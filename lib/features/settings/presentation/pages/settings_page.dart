import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_pos/features/auth/domain/entities/user.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // Profile section
              SliverToBoxAdapter(
                child: _buildProfileSection(),
              ),

              // Settings sections
              SliverToBoxAdapter(
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    if (state is SettingsLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    if (state is SettingsLoaded) {
                      return Column(
                        children: [
                          // Security section
                          _buildSecuritySection(state),

                          // Notifications section
                          _buildNotificationsSection(state),

                          // Data & Sync section
                          _buildDataSyncSection(state),

                          // Preferences section
                          _buildPreferencesSection(state),

                          // About section
                          _buildAboutSection(),

                          // Logout button
                          _buildLogoutButton(),

                          const SizedBox(height: 32),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: const Text(
        AppStrings.settings,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildProfileSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'User';
        String email = 'user@example.com';
        String role = 'Staff';

        if (state is AuthAuthenticated) {
          name = state.user.name;
          email = state.user.email;
          role = state.user.role.displayName;
        }

        final initials = name.isNotEmpty
            ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
            : 'U';

        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Edit button
              IconButton(
                onPressed: () {
                  // TODO: Edit profile
                },
                icon: Icon(
                  Iconsax.edit,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildSecuritySection(SettingsLoaded state) {
    return SettingsSection(
      title: 'Security',
      icon: Iconsax.shield_tick,
      children: [
        SettingsTile(
          title: state.biometricType == 'face' ? 'Face ID' : 'Fingerprint',
          subtitle: state.biometricAvailable
              ? 'Use biometrics to login quickly'
              : 'Biometrics not available on this device',
          icon: state.biometricType == 'face' ? Iconsax.scan : Iconsax.finger_scan,
          trailing: Switch(
            value: state.biometricEnabled,
            onChanged: state.biometricAvailable
                ? (value) {
                    context.read<SettingsBloc>().add(BiometricToggled(value));
                  }
                : null,
          ),
          enabled: state.biometricAvailable,
        ),
        SettingsTile(
          title: 'Change Password',
          subtitle: 'Update your account password',
          icon: Iconsax.lock,
          onTap: () {
            // TODO: Change password
          },
        ),
        SettingsTile(
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security',
          icon: Iconsax.security_safe,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Enabled',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () {
            // TODO: 2FA settings
          },
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildNotificationsSection(SettingsLoaded state) {
    return SettingsSection(
      title: 'Notifications',
      icon: Iconsax.notification,
      children: [
        SettingsTile(
          title: 'Push Notifications',
          subtitle: 'Receive alerts for orders and updates',
          icon: Iconsax.notification_bing,
          trailing: Switch(
            value: state.notificationsEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(NotificationsToggled(value));
            },
          ),
        ),
        SettingsTile(
          title: 'Low Stock Alerts',
          subtitle: 'Get notified when stock is low',
          icon: Iconsax.box_remove,
          onTap: () {
            _showLowStockThresholdDialog(state.lowStockThreshold);
          },
          trailing: Text(
            '< ${state.lowStockThreshold} units',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        SettingsTile(
          title: 'Order Notifications',
          subtitle: 'New order alerts',
          icon: Iconsax.receipt_item,
          onTap: () {
            // TODO: Order notification settings
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildDataSyncSection(SettingsLoaded state) {
    return SettingsSection(
      title: 'Data & Sync',
      icon: Iconsax.refresh,
      children: [
        SettingsTile(
          title: 'Auto Sync',
          subtitle: 'Automatically sync data when online',
          icon: Iconsax.cloud_change,
          trailing: Switch(
            value: state.autoSyncEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(AutoSyncToggled(value));
            },
          ),
        ),
        SettingsTile(
          title: 'Sync Interval',
          subtitle: 'How often to sync data',
          icon: Iconsax.timer_1,
          trailing: Text(
            '${state.syncInterval} min',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          onTap: () {
            _showSyncIntervalDialog(state.syncInterval);
          },
          enabled: state.autoSyncEnabled,
        ),
        SettingsTile(
          title: 'Clear Cache',
          subtitle: 'Free up storage space',
          icon: Iconsax.trash,
          onTap: () {
            _showClearCacheDialog();
          },
        ),
        SettingsTile(
          title: 'Export Data',
          subtitle: 'Download your data',
          icon: Iconsax.export_1,
          onTap: () {
            // TODO: Export data
          },
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildPreferencesSection(SettingsLoaded state) {
    return SettingsSection(
      title: 'Preferences',
      icon: Iconsax.setting_2,
      children: [
        SettingsTile(
          title: 'Currency',
          subtitle: 'Display currency format',
          icon: Iconsax.dollar_circle,
          trailing: Text(
            state.currencyCode,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          onTap: () {
            _showCurrencyDialog(state.currencyCode);
          },
        ),
        SettingsTile(
          title: 'Language',
          subtitle: 'English (US)',
          icon: Iconsax.global,
          onTap: () {
            // TODO: Language settings
          },
        ),
        SettingsTile(
          title: 'Date Format',
          subtitle: 'MM/DD/YYYY',
          icon: Iconsax.calendar,
          onTap: () {
            // TODO: Date format settings
          },
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildAboutSection() {
    return SettingsSection(
      title: 'About',
      icon: Iconsax.info_circle,
      children: [
        SettingsTile(
          title: 'App Version',
          subtitle: '1.0.0 (Build 1)',
          icon: Iconsax.mobile,
        ),
        SettingsTile(
          title: 'Terms of Service',
          icon: Iconsax.document_text,
          onTap: () {
            // TODO: Show terms
          },
        ),
        SettingsTile(
          title: 'Privacy Policy',
          icon: Iconsax.shield,
          onTap: () {
            // TODO: Show privacy policy
          },
        ),
        SettingsTile(
          title: 'Help & Support',
          icon: Iconsax.message_question,
          onTap: () {
            // TODO: Show help
          },
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            _showLogoutDialog();
          },
          icon: const Icon(Iconsax.logout, color: AppColors.error),
          label: const Text(
            'Logout',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: AppColors.error.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  void _showLowStockThresholdDialog(int currentThreshold) {
    int selected = currentThreshold;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Low Stock Threshold'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Alert when stock falls below:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: selected.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: '$selected units',
                  onChanged: (value) {
                    setState(() => selected = value.toInt());
                  },
                ),
                Text(
                  '$selected units',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(LowStockThresholdChanged(selected));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSyncIntervalDialog(int currentInterval) {
    final intervals = [1, 5, 10, 15, 30, 60];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) {
            return RadioListTile<int>(
              title: Text(interval == 60 ? '1 hour' : '$interval min'),
              value: interval,
              groupValue: currentInterval,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(SyncIntervalChanged(value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog(String currentCurrency) {
    final currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: currentCurrency,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(CurrencyChanged(value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data. You will need to sync again to get the latest data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Clear cache
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
