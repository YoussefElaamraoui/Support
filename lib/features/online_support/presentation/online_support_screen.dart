import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/link_opener.dart';
import '../../../core/widgets/care_top_bar.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/neo_button.dart';
import '../../profile/application/profile_controller.dart';
import '../data/online_resources.dart';

class OnlineSupportScreen extends StatelessWidget {
  const OnlineSupportScreen({
    required this.profileController,
    this.resources,
    this.links,
    super.key,
  });

  final ProfileController profileController;
  final List<OnlineResource>? resources;
  final List<QuickLink>? links;

  @override
  Widget build(BuildContext context) {
    final items = resources ?? onlineResources;
    final quick = links ?? quickLinks;
    final wide = MediaQuery.sizeOf(context).width >= 768;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ListenableBuilder(
            listenable: profileController,
            builder: (context, _) => CareTopBar.brand(
              profile: profileController.profile,
              menuStyle: MenuButtonStyle.plain,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 32),
              child: Column(
                crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Access digital resources from anywhere.',
                    textAlign: wide ? TextAlign.start : TextAlign.center,
                    style: AppTypography.pageHeadline(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connect with professionals, share experiences, and learn new skills to enhance your '
                    'caregiving journey, all from the comfort of your home.',
                    textAlign: wide ? TextAlign.start : TextAlign.center,
                    style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 48),
                  for (final r in items) ...[
                    ResourceCard(resource: r),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 24),
                  _QuickLinksBox(links: quick),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastel card with icon sticker, title, copy and a black "Visit site" button.
class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.resource});

  final OnlineResource resource;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      color: resource.color,
      radius: 16,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(
            icon: resource.icon,
            size: 64,
            iconSize: 36,
            radius: 12,
            color: AppColors.surface,
            shadowOffset: 2,
          ),
          const SizedBox(height: 24),
          Text(resource.title, style: AppTypography.headlineMd),
          const SizedBox(height: 12),
          Text(resource.description, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24),
          NeoButton(
            label: 'Visit site',
            trailingIcon: Symbols.arrow_forward,
            height: 50,
            shadowColor: resource.color,
            onPressed: () => openExternalLink(context, resource.url),
          ),
        ],
      ),
    );
  }
}

class _QuickLinksBox extends StatelessWidget {
  const _QuickLinksBox({required this.links});

  final List<QuickLink> links;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      color: AppColors.surfaceContainerLow,
      radius: 16,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Symbols.link, color: AppColors.primary, fill: 1, weight: 600),
              const SizedBox(width: 12),
              Text('Quick Links', style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < links.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            NeoPressable(
              semanticLabel: links[i].label,
              onTap: () => openExternalLink(context, links[i].url),
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      links[i].label,
                      style: AppTypography.bodyLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Symbols.open_in_new, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
