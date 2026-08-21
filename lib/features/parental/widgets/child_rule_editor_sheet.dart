import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';

/// Bottom sheet for creating or editing a per-child rule.
/// Shows a rule type picker, then dynamic form fields based on the chosen type.
class ChildRuleEditorSheet extends ConsumerStatefulWidget {
  const ChildRuleEditorSheet({
    super.key,
    required this.childId,
    required this.childName,
    this.existingRule,
  });

  final String childId;
  final String childName;
  final ChildRule? existingRule; // null = create mode

  @override
  ConsumerState<ChildRuleEditorSheet> createState() =>
      _ChildRuleEditorSheetState();
}

class _ChildRuleEditorSheetState extends ConsumerState<ChildRuleEditorSheet> {
  RuleType _selectedType = RuleType.screenTimeLimit;
  final _labelCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  bool _isEnabled = true;

  // Screen time specific
  int _screenHours = 2;

  // Bedtime specific
  TimeOfDay _bedtime = const TimeOfDay(hour: 21, minute: 0);

  // App block
  final List<String> _commonApps = [
    'TikTok', 'Instagram', 'YouTube', 'Snapchat', 'Facebook',
    'Twitter/X', 'Discord', 'Telegram', 'WhatsApp', 'Roblox',
  ];
  String? _selectedApp;

  // Content filter
  final List<String> _filterLevels = ['Strict', 'Moderate', 'Minimal'];
  String _selectedFilterLevel = 'Strict';

  // Safe zone
  final _zoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingRule != null) {
      final r = widget.existingRule!;
      _selectedType = r.type;
      _labelCtrl.text = r.label;
      _valueCtrl.text = r.value;
      _detailCtrl.text = r.detail;
      _isEnabled = r.isEnabled;
      _initFromRule(r);
    } else {
      _labelCtrl.text = _selectedType.displayName;
    }
  }

  void _initFromRule(ChildRule r) {
    switch (r.type) {
      case RuleType.screenTimeLimit:
        final h = int.tryParse(r.value.split(' ').first) ?? 2;
        _screenHours = h;
        break;
      case RuleType.bedtimeCurfew:
        final parts = r.value.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 21;
          final rest = parts[1].split(' ');
          final min = int.tryParse(rest[0]) ?? 0;
          final isPm = rest.length > 1 && rest[1] == 'PM';
          _bedtime = TimeOfDay(hour: isPm && hour != 12 ? hour + 12 : hour, minute: min);
        }
        break;
      case RuleType.appBlock:
        _selectedApp = r.value;
        break;
      case RuleType.contentFilter:
        _selectedFilterLevel = r.value;
        break;
      case RuleType.safeZone:
        _zoneCtrl.text = r.value;
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    _detailCtrl.dispose();
    _zoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingRule != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXxl)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Rule' : 'Add Rule',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                        ),
                        Text(
                          'For ${widget.childName}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.cyberBlue, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.outline, height: 24),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    _buildRuleTypePicker(),
                    const SizedBox(height: DesignTokens.spacingXl),
                    _buildDynamicFields(),
                    const SizedBox(height: DesignTokens.spacingXl),
                    _buildLabelField(),
                    const SizedBox(height: DesignTokens.spacingLg),
                    _buildEnabledToggle(),
                    const SizedBox(height: DesignTokens.spacingXxl),
                    _buildApplyButton(isEdit),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Rule Type Picker ────────────────────────────────────────────────

  Widget _buildRuleTypePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rule Type',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceMuted),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        Wrap(
          spacing: DesignTokens.spacingSm,
          runSpacing: DesignTokens.spacingSm,
          children: RuleType.values.map((type) {
            final isSelected = _selectedType == type;
            return AnimatedContainer(
              duration: DesignTokens.animFast,
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedType = type;
                  _labelCtrl.text = type.displayName;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _typeColor(type).withValues(alpha: 0.12)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    border: Border.all(
                      color: isSelected ? _typeColor(type) : AppColors.outline,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(type.emoji, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? _typeColor(type) : AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Dynamic Fields per Rule Type ────────────────────────────────────

  Widget _buildDynamicFields() {
    switch (_selectedType) {
      case RuleType.screenTimeLimit:
        return _buildScreenTimeFields();
      case RuleType.appBlock:
        return _buildAppBlockFields();
      case RuleType.bedtimeCurfew:
        return _buildBedtimeFields();
      case RuleType.safeZone:
        return _buildSafeZoneFields();
      case RuleType.contentFilter:
        return _buildContentFilterFields();
      case RuleType.webFilter:
        return _buildWebFilterFields();
    }
  }

  Widget _buildScreenTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Screen Time Limit',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: DesignTokens.spacingMd),
        Container(
          padding: const EdgeInsets.all(DesignTokens.spacingLg),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                '$_screenHours hour${_screenHours == 1 ? '' : 's'} / day',
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.cyberBlue),
              ),
              const SizedBox(height: 12),
              Slider(
                value: _screenHours.toDouble(),
                min: 0.5,
                max: 10,
                divisions: 19,
                activeColor: AppColors.cyberBlue,
                inactiveColor: AppColors.outline,
                onChanged: (v) => setState(() => _screenHours = v.round()),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('30 min', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                  Text('10 hours', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: DesignTokens.animFast);
  }

  Widget _buildAppBlockFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Block App',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: DesignTokens.spacingMd),
        const Text('Choose from common apps or type a custom name below:',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
        const SizedBox(height: DesignTokens.spacingMd),
        Wrap(
          spacing: DesignTokens.spacingSm,
          runSpacing: DesignTokens.spacingSm,
          children: _commonApps.map((app) {
            final isSelected = _selectedApp == app;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedApp = app;
                  _valueCtrl.text = app;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.errorRed.withValues(alpha: 0.1)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(
                    color: isSelected ? AppColors.errorRed : AppColors.outline,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  app,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.errorRed : AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        TextField(
          controller: _valueCtrl,
          decoration: const InputDecoration(
            labelText: 'Or enter custom app name',
            prefixIcon: Icon(Icons.apps_rounded),
          ),
          onChanged: (v) => setState(() => _selectedApp = null),
        ),
      ],
    ).animate().fadeIn(duration: DesignTokens.animFast);
  }

  Widget _buildBedtimeFields() {
    final formattedTime = _bedtime.format(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bedtime Curfew',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: DesignTokens.spacingMd),
        const Text('Internet will be disabled after this time on school nights.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
        const SizedBox(height: DesignTokens.spacingMd),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _bedtime,
            );
            if (picked != null) setState(() => _bedtime = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spacingLg),
            decoration: BoxDecoration(
              color: AppColors.neonPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bedtime_rounded, color: AppColors.neonPurple, size: 28),
                const SizedBox(width: 12),
                Text(
                  formattedTime,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.neonPurple),
                ),
                const Spacer(),
                const Icon(Icons.edit_rounded, color: AppColors.neonPurple, size: 18),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: DesignTokens.animFast);
  }

  Widget _buildSafeZoneFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Safe Zone Location',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: DesignTokens.spacingSm),
        const Text('Get an alert when your child leaves this location.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
        const SizedBox(height: DesignTokens.spacingMd),
        TextField(
          controller: _zoneCtrl,
          decoration: const InputDecoration(
            labelText: 'Location name (e.g. school, home)',
            hintText: 'Green Park High School',
            prefixIcon: Icon(Icons.location_on_rounded),
          ),
          onChanged: (v) => _valueCtrl.text = v,
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.emeraldGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.2)),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, color: AppColors.emeraldGreen, size: 32),
                SizedBox(height: 8),
                Text('Map picker available in full version',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: DesignTokens.animFast);
  }

  Widget _buildContentFilterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Content Filter Level',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: DesignTokens.spacingMd),
        ..._filterLevels.map((level) {
          final isSelected = _selectedFilterLevel == level;
          final descriptions = {
            'Strict': 'Block adult, violent, and gambling content',
            'Moderate': 'Block adult content, allow educational videos',
            'Minimal': 'Basic filter — only block illegal content',
          };
          return GestureDetector(
            onTap: () => setState(() {
              _selectedFilterLevel = level;
              _valueCtrl.text = level;
            }),
            child: AnimatedContainer(
              duration: DesignTokens.animFast,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cyberBlue.withValues(alpha: 0.08)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.cyberBlue : AppColors.outline,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: DesignTokens.animFast,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.cyberBlue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.cyberBlue : AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(level,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.cyberBlue : AppColors.onSurface,
                            )),
                        Text(descriptions[level] ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.onSurfaceMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: DesignTokens.animFast);
  }

  Widget _buildWebFilterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Web Filter',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: DesignTokens.spacingSm),
        const Text('Control which websites your child can access.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
        const SizedBox(height: DesignTokens.spacingMd),
        ..._filterLevels.map((level) {
          final isSelected = _selectedFilterLevel == level;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedFilterLevel = level;
              _valueCtrl.text = level;
            }),
            child: AnimatedContainer(
              duration: DesignTokens.animFast,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cyberBlue.withValues(alpha: 0.08) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                    color: isSelected ? AppColors.cyberBlue : AppColors.outline,
                    width: isSelected ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? AppColors.cyberBlue : AppColors.outlineVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(level,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.cyberBlue : AppColors.onSurface,
                      )),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: DesignTokens.spacingMd),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Block specific website (optional)',
            hintText: 'e.g. example.com',
            prefixIcon: Icon(Icons.language_rounded),
          ),
        ),
      ],
    ).animate().fadeIn(duration: DesignTokens.animFast);
  }

  // ── Label + Toggle ──────────────────────────────────────────────────

  Widget _buildLabelField() {
    return TextField(
      controller: _labelCtrl,
      decoration: const InputDecoration(
        labelText: 'Rule Label',
        hintText: 'e.g. School Night Screen Limit',
        prefixIcon: Icon(Icons.label_outline_rounded),
      ),
    );
  }

  Widget _buildEnabledToggle() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enable Rule',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              SizedBox(height: 2),
              Text('Disable to pause without deleting',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
            ],
          ),
        ),
        Switch(
          value: _isEnabled,
          onChanged: (v) => setState(() => _isEnabled = v),
          activeColor: AppColors.emeraldGreen,
        ),
      ],
    );
  }

  Widget _buildApplyButton(bool isEdit) {
    return ElevatedButton.icon(
      onPressed: _saveRule,
      icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
      label: Text(isEdit ? 'Save Changes' : 'Apply Rule to ${widget.childName}'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _typeColor(_selectedType),
        foregroundColor: Colors.white,
      ),
    );
  }

  // ── Save ────────────────────────────────────────────────────────────

  void _saveRule() {
    final value = _resolvedValue();
    final detail = _resolvedDetail(value);
    final label = _labelCtrl.text.trim().isEmpty
        ? _selectedType.displayName
        : _labelCtrl.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the required fields.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final notifier = ref.read(familyProfileProvider.notifier);

    if (widget.existingRule != null) {
      notifier.updateRule(widget.existingRule!.copyWith(
        type: _selectedType,
        label: label,
        value: value,
        detail: detail,
        isEnabled: _isEnabled,
      ));
    } else {
      notifier.addRule(ChildRule(
        id: 'r_${DateTime.now().millisecondsSinceEpoch}',
        childId: widget.childId,
        type: _selectedType,
        label: label,
        value: value,
        detail: detail,
        isEnabled: _isEnabled,
      ));
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingRule != null ? 'Rule updated!' : 'Rule added for ${widget.childName}',
        ),
        backgroundColor: AppColors.emeraldGreen,
      ),
    );
  }

  String _resolvedValue() {
    switch (_selectedType) {
      case RuleType.screenTimeLimit:
        return '$_screenHours hour${_screenHours == 1 ? '' : 's'}/day';
      case RuleType.appBlock:
        return _selectedApp ?? _valueCtrl.text.trim();
      case RuleType.bedtimeCurfew:
        return _bedtime.format(context);
      case RuleType.safeZone:
        return _zoneCtrl.text.trim();
      case RuleType.contentFilter:
      case RuleType.webFilter:
        return _selectedFilterLevel;
    }
  }

  String _resolvedDetail(String value) {
    switch (_selectedType) {
      case RuleType.screenTimeLimit:
        return 'Max $_screenHours hour${_screenHours == 1 ? '' : 's'} of screen time per day';
      case RuleType.appBlock:
        return '$value is blocked on this device';
      case RuleType.bedtimeCurfew:
        return 'Internet disabled after $value on school nights';
      case RuleType.safeZone:
        return 'Alert when ${widget.childName} leaves "$value"';
      case RuleType.contentFilter:
        return '$value content filter active';
      case RuleType.webFilter:
        return '$value web filter active';
    }
  }

  Color _typeColor(RuleType type) {
    switch (type) {
      case RuleType.screenTimeLimit: return AppColors.cyberBlue;
      case RuleType.appBlock:        return AppColors.errorRed;
      case RuleType.bedtimeCurfew:   return AppColors.neonPurple;
      case RuleType.safeZone:        return AppColors.emeraldGreen;
      case RuleType.contentFilter:   return AppColors.warningOrange;
      case RuleType.webFilter:       return AppColors.warningAmber;
    }
  }
}
