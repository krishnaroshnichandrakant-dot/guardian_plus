import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../services/permission_auditor_service.dart';

class PermissionAuditorScreen extends ConsumerStatefulWidget {
  const PermissionAuditorScreen({super.key});

  @override
  ConsumerState<PermissionAuditorScreen> createState() => _PermissionAuditorScreenState();
}

class _PermissionAuditorScreenState extends ConsumerState<PermissionAuditorScreen> {
  List<AppPermissionAudit>? _audits;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAudits();
  }

  Future<void> _loadAudits() async {
    setState(() => _isLoading = true);
    final service = ref.read(permissionAuditorServiceProvider);
    final results = await service.auditInstalledApps();
    if (mounted) {
      setState(() {
        _audits = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAudits = _audits?.where((audit) {
      final matchesSearch = audit.appName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          audit.packageName.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Critical') {
        return audit.riskLevel == PermissionRiskLevel.critical;
      } else if (_selectedFilter == 'High') {
        return audit.riskLevel == PermissionRiskLevel.high;
      } else if (_selectedFilter == 'Low/Med') {
        return audit.riskLevel == PermissionRiskLevel.medium || audit.riskLevel == PermissionRiskLevel.low;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Permission Auditor'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.cyberBlue),
            tooltip: 'Re-audit Apps',
            onPressed: _loadAudits,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.cyberBlue),
                  SizedBox(height: 16),
                  Text('Scanning installed application permissions...', style: TextStyle(color: AppColors.onSurfaceMuted)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(DesignTokens.screenPadding),
              children: [
                _buildHeaderCard(),
                const SizedBox(height: DesignTokens.spacingLg),
                _buildSearchAndFilters(),
                const SizedBox(height: DesignTokens.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Flagged Applications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '${filteredAudits?.length ?? 0} apps',
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                if (filteredAudits == null || filteredAudits.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Text('No applications match your filter.', style: TextStyle(color: AppColors.onSurfaceMuted)),
                  )
                else
                  ...filteredAudits.map((audit) => Padding(
                        padding: const EdgeInsets.only(bottom: DesignTokens.spacingMd),
                        child: _AppAuditCard(
                          audit: audit,
                          onManage: () => _showManagePermissionsModal(context, audit),
                        ),
                      )),
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildHeaderCard() {
    final criticalCount = _audits?.where((a) => a.riskLevel == PermissionRiskLevel.critical).length ?? 0;
    final highCount = _audits?.where((a) => a.riskLevel == PermissionRiskLevel.high).length ?? 0;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: (criticalCount > 0 ? AppColors.errorRed : AppColors.warningAmber),
          width: 1.5,
        ),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_update_warning_rounded,
                color: criticalCount > 0 ? AppColors.errorRed : AppColors.warningAmber,
                size: 28,
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Text(
                  '$criticalCount Critical & $highCount High Risk App(s)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          const Text(
            'Over-privileged apps can access your contacts, background location, microphone, or SMS without an explicit requirement.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search app name or package...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                : null,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingSm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Critical', 'High', 'Low/Med'].map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: AppColors.cyberBlue.withOpacity(0.2),
                  onSelected: (val) => setState(() => _selectedFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showManagePermissionsModal(BuildContext context, AppPermissionAudit audit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.cyberBlue.withOpacity(0.15),
                  child: const Icon(Icons.android_rounded, color: AppColors.cyberBlue),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(audit.appName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                      Text(audit.packageName, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingLg),
            const Text('Sensitive Permissions Requested:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            const SizedBox(height: DesignTokens.spacingSm),
            ...audit.riskReasons.map((reason) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.errorRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(reason, style: const TextStyle(fontSize: 13, color: AppColors.onSurface))),
                    ],
                  ),
                )),
            const SizedBox(height: DesignTokens.spacingXl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening system settings to revoke permissions for ${audit.appName}...')),
                );
              },
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Open App Info & Revoke Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppAuditCard extends StatelessWidget {
  const _AppAuditCard({required this.audit, required this.onManage});
  final AppPermissionAudit audit;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(audit.riskLevel);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(Icons.android_rounded, color: color, size: 20),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audit.appName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      audit.packageName,
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  audit.riskLevel.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (audit.riskReasons.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingMd),
            const Divider(color: AppColors.outline, height: 1),
            const SizedBox(height: DesignTokens.spacingMd),
            ...audit.riskReasons.map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: DesignTokens.spacingMd),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onManage,
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
              label: const Text('Manage Permissions', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(120, 34),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(PermissionRiskLevel level) {
    switch (level) {
      case PermissionRiskLevel.critical:
        return AppColors.errorRed;
      case PermissionRiskLevel.high:
        return AppColors.warningOrange;
      case PermissionRiskLevel.medium:
        return AppColors.warningAmber;
      case PermissionRiskLevel.low:
        return AppColors.emeraldGreen;
    }
  }
}
