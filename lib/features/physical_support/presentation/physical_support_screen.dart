import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/link_opener.dart';
import '../../../core/widgets/care_top_bar.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_sheet.dart';
import '../../profile/application/profile_controller.dart';
import '../data/physical_services.dart';

class PhysicalSupportScreen extends StatefulWidget {
  const PhysicalSupportScreen({
    required this.profileController,
    required this.appDatabase,
    this.services = physicalServices,
    super.key,
  });

  final ProfileController profileController;
  final AppDatabase appDatabase;
  final List<PhysicalService> services;

  @override
  State<PhysicalSupportScreen> createState() => _PhysicalSupportScreenState();
}

class _PhysicalSupportScreenState extends State<PhysicalSupportScreen> {
  static const _filters = <ServiceCategory?>[
    null,
    ServiceCategory.inHomeCare,
    ServiceCategory.medicalSupplies,
    ServiceCategory.therapy,
  ];

  ServiceCategory? _category;
  String _query = '';

  List<PhysicalService> get _visible {
    final q = _query.trim().toLowerCase();
    return widget.services.where((s) {
      final matchesCategory = _category == null || s.category == _category;
      final matchesQuery = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.category.label.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _suggestService() async {
    final result = await showNeoSheet<({String name, String details})>(
      context: context,
      title: 'Suggest a Service',
      builder: (_) => const _SuggestionForm(),
    );
    if (result == null) return;
    await widget.appDatabase.saveServiceSuggestion(name: result.name, details: result.details);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks! Suggestion saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ListenableBuilder(
            listenable: widget.profileController,
            builder: (context, _) => CareTopBar.brand(profile: widget.profileController.profile),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Text('Physical Support', style: AppTypography.pageHeadline(context)),
                          NeoPressable(
                            onTap: _suggestService,
                            color: AppColors.warmPeach,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Symbols.add_circle, size: 18, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('Suggest Service', style: AppTypography.labelLg),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SearchField(onChanged: (v) => setState(() => _query = v)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        for (final c in _filters) ...[
                          _FilterChip(
                            label: c?.label ?? 'All Services',
                            selected: c == _category,
                            onTap: () => setState(() => _category = c),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: visible.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No services match your search.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        )
                      : SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.crossAxisExtent;
                            final columns = (width / 304).floor().clamp(1, 4);
                            return SliverGrid.builder(
                              itemCount: visible.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                mainAxisExtent: 236,
                              ),
                              itemBuilder: (context, i) => ServiceCard(service: visible[i]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionForm extends StatefulWidget {
  const _SuggestionForm();

  @override
  State<_SuggestionForm> createState() => _SuggestionFormState();
}

class _SuggestionFormState extends State<_SuggestionForm> {
  final _name = TextEditingController();
  final _details = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _details.dispose();
    super.dispose();
  }

  void _send() {
    if (_name.text.trim().isEmpty) return;
    Navigator.of(context).pop((name: _name.text.trim(), details: _details.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Service name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _details,
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Location, contact, why it helps…'),
        ),
        const SizedBox(height: 20),
        NeoButton(label: 'Send suggestion', shadowColor: AppColors.warmPeach, onPressed: _send),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      radius: 12,
      shadowOffset: 4,
      child: TextField(
        onChanged: onChanged,
        style: AppTypography.bodyLg,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search for services, locations...',
          prefixIcon: const Icon(Symbols.search, color: AppColors.outline),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintStyle: AppTypography.bodyLg.copyWith(color: AppColors.outlineVariant),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeoPressable(
      onTap: onTap,
      semanticLabel: label,
      radius: 999,
      color: selected ? AppColors.primary : AppColors.surfaceContainerLowest,
      shadowOffset: selected ? 2 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label,
        style: AppTypography.labelLg.copyWith(color: selected ? AppColors.onPrimary : AppColors.primary),
      ),
    );
  }
}

/// Coloured bento card for one physical service.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service});

  final PhysicalService service;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      color: service.color,
      radius: 16,
      clip: true,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.2,
                child: Icon(service.decorIcon, size: 150, color: AppColors.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Text(service.title, style: AppTypography.headlineMd.copyWith(height: 1.15)),
                      ),
                    ),
                    IconTile(
                      icon: service.icon,
                      rotationDegrees: service.iconTilt,
                      radius: 12,
                      iconSize: 30,
                      shadowOffset: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Text(
                    service.description,
                    overflow: TextOverflow.fade,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.primary),
                  ),
                ),
                GestureDetector(
                  onTap: () => openMapSearch(context, service.mapQuery),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Symbols.map, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('View map', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
