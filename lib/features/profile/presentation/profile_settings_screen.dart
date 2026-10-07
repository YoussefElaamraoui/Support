import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/care_top_bar.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_sheet.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../application/profile_controller.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({required this.profileController, this.onLogOut, super.key});

  final ProfileController profileController;
  final VoidCallback? onLogOut;

  Future<void> _editProfile(BuildContext context) async {
    final result = await showNeoSheet<_ProfileEdit>(
      context: context,
      title: 'Account Details',
      builder: (_) => _ProfileForm(initial: profileController.profile),
    );
    if (result != null) {
      await profileController.update(fullName: result.fullName, role: result.role, avatarUrl: result.avatarUrl);
    }
  }

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what – coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profileController,
      builder: (context, _) {
        final profile = profileController.profile;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              CareTopBar(
                leading: ProfileAvatar(profile: profile, shadowOffset: 0),
                title: Text('CarePals', style: CareTopBar.brandStyle),
                centerTitle: true,
                menuStyle: MenuButtonStyle.round,
                bottomBorder: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProfileHeader(profile: profile, onEdit: () => _editProfile(context)),
                          const SizedBox(height: 56),
                          _MenuRow(
                            label: 'Account Details',
                            icon: Symbols.person,
                            color: AppColors.softPink,
                            tilt: -3,
                            onTap: () => _editProfile(context),
                          ),
                          const SizedBox(height: 16),
                          _MenuRow(
                            label: 'Notification Preferences',
                            icon: Symbols.notifications,
                            color: AppColors.warmPeach,
                            tilt: 2,
                            onTap: () => _comingSoon(context, 'Notification preferences'),
                          ),
                          const SizedBox(height: 16),
                          _MenuRow(
                            label: 'Privacy Settings',
                            icon: Symbols.lock,
                            color: AppColors.periwinkle,
                            tilt: -1,
                            onTap: () => _comingSoon(context, 'Privacy settings'),
                          ),
                          const SizedBox(height: 16),
                          _MenuRow(
                            label: 'Help & Support',
                            icon: Symbols.help,
                            color: AppColors.mintGreen,
                            tilt: 4,
                            onTap: () => _comingSoon(context, 'Help & support'),
                          ),
                          const SizedBox(height: 48),
                          NeoButton(
                            label: 'Log Out',
                            trailingIcon: Symbols.logout,
                            height: 58,
                            shadowOffset: 4,
                            shadowColor: AppColors.warmPeach,
                            textStyle: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
                            onPressed: onLogOut ?? () => _comingSoon(context, 'Log out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            children: [
              ProfileAvatar(profile: profile, size: 128, borderWidth: 4, shadowOffset: 4),
              Positioned(
                right: 0,
                bottom: 0,
                child: NeoPressable(
                  semanticLabel: 'Edit profile',
                  onTap: onEdit,
                  shape: BoxShape.circle,
                  color: AppColors.mintGreen,
                  width: 40,
                  height: 40,
                  child: const Center(child: Icon(Symbols.edit, color: AppColors.primary, weight: 700, size: 22)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(profile.fullName, textAlign: TextAlign.center, style: AppTypography.pageHeadline(context)),
        const SizedBox(height: 4),
        Text(
          profile.role,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w700),
        ),
        if (profile.certified) ...[
          const SizedBox(height: 12),
          NeoBox(
            color: AppColors.periwinkle,
            radius: 999,
            shadowOffset: 2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Symbols.verified, size: 16, color: AppColors.primary, weight: 700),
                const SizedBox(width: 4),
                Text('CERTIFIED', style: AppTypography.labelSm),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.tilt,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double tilt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeoPressable(
      semanticLabel: label,
      onTap: onTap,
      shadowOffset: 4,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconTile(icon: icon, color: color, rotationDegrees: tilt, filled: true),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: AppTypography.bodyLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const Icon(Symbols.chevron_right, color: AppColors.primary, weight: 700),
        ],
      ),
    );
  }
}

typedef _ProfileEdit = ({String fullName, String role, String avatarUrl});

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.initial});

  final UserProfile initial;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  late final _name = TextEditingController(text: widget.initial.fullName);
  late final _role = TextEditingController(text: widget.initial.role);
  late final _avatar = TextEditingController(text: widget.initial.avatarUrl ?? '');

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _avatar.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) return;
    Navigator.of(context).pop<_ProfileEdit>((fullName: _name.text, role: _role.text, avatarUrl: _avatar.text));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _role,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Role'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _avatar,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: 'Photo URL (optional)'),
        ),
        const SizedBox(height: 20),
        NeoButton(label: 'Save', shadowColor: AppColors.moodHappy, onPressed: _save),
      ],
    );
  }
}
