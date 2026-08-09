import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../shared/widgets/glass_card.dart';

enum RiskLevel { clean, low, medium, high, critical }

class ChildDeviceData {
  ChildDeviceData({
    required this.id,
    required this.name,
    required this.model,
    required this.riskLevel,
    required this.screenTimeToday,
    required this.lastSeen,
    required this.batteryLevel,
    required this.location,
    this.isPaused = false,
  });

  final String id;
  String name;
  String model;
  RiskLevel riskLevel;
  String screenTimeToday;
  String lastSeen;
  int batteryLevel;
  String location;
  bool isPaused;
}

/// Parent Dashboard — Module 1B
/// Shows child device cards, risk alerts, screen time summary, and device management.
class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final List<ChildDeviceData> _devices = [
    ChildDeviceData(
      id: 'dev_1',
      name: "Riya's Phone",
      model: 'Samsung Galaxy A54',
      riskLevel: RiskLevel.medium,
      screenTimeToday: '4h 23m',
      lastSeen: '2 min ago',
      batteryLevel: 78,
      location: 'Green Park High School',
    ),
    ChildDeviceData(
      id: 'dev_2',
      name: "Arjun's Tablet",
      model: 'Samsung Tab S7',
      riskLevel: RiskLevel.low,
      screenTimeToday: '1h 45m',
      lastSeen: '15 min ago',
      batteryLevel: 92,
      location: 'Home Wi-Fi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(DesignTokens.screenPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildRiskOverview(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildMonitoredDevicesHeader(),
                  const SizedBox(height: DesignTokens.spacingMd),
                  ..._devices.map((device) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: DesignTokens.spacingMd),
                      child: _buildChildDeviceCard(device),
                    );
                  }),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildSectionTitle('Recent Alerts'),
                  const SizedBox(height: DesignTokens.spacingLg),
                  _buildAlertFeed(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: DesignTokens.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Parent Hub',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              Text('${_devices.length} devices monitored',
                  style: const TextStyle(fontSize: 11, color: AppColors.neonPurple, fontWeight: FontWeight.w500)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.cyberBlue),
            tooltip: 'Add Device',
            onPressed: () => _showAddDeviceModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskOverview() {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Family Safety Index',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Moderate Attention Needed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(color: AppColors.warningAmber, width: 1),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warningAmber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '1 Risk Alert',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warningAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Row(
            children: [
              _MetricCard(label: 'Active Rules', value: '14/14', icon: Icons.gavel_rounded, color: AppColors.cyberBlue),
              const SizedBox(width: DesignTokens.spacingMd),
              _MetricCard(label: 'Safe Zone', value: 'Inside', icon: Icons.location_on_rounded, color: AppColors.emeraldGreen),
              const SizedBox(width: DesignTokens.spacingMd),
              _MetricCard(label: 'Avg Screen Time', value: '3h 04m', icon: Icons.timer_rounded, color: AppColors.neonPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoredDevicesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Monitored Devices',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddDeviceModal(context),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Device'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyberBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 38),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
          ),
        ),
      ],
    );
  }

  Widget _buildChildDeviceCard(ChildDeviceData device) {
    Color riskColor;
    String riskLabel;
    switch (device.riskLevel) {
      case RiskLevel.clean:
      case RiskLevel.low:
        riskColor = AppColors.emeraldGreen;
        riskLabel = 'Safe';
        break;
      case RiskLevel.medium:
        riskColor = AppColors.warningAmber;
        riskLabel = 'Medium Risk';
        break;
      case RiskLevel.high:
      case RiskLevel.critical:
        riskColor = AppColors.errorRed;
        riskLabel = 'High Risk';
        break;
    }

    return GlassCard(
      onTap: () => _showDeviceDetailsModal(context, device),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Icon(Icons.phone_android_rounded, color: AppColors.neonPurple, size: 24),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface)),
                    Text('${device.model} • ${device.location}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.onSurfaceMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(color: riskColor.withOpacity(0.5)),
                ),
                child: Text(
                  riskLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              _DeviceStat(
                  icon: Icons.timer_outlined,
                  label: 'Screen time',
                  value: device.screenTimeToday),
              const SizedBox(width: DesignTokens.spacingLg),
              _DeviceStat(
                  icon: Icons.battery_charging_full_rounded,
                  label: 'Battery',
                  value: '${device.batteryLevel}%'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showDeviceDetailsModal(context, device),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  backgroundColor: AppColors.cyberBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
                ),
                child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildAlertFeed() {
    return Column(
      children: [
        _AlertTile(
          category: 'Possible explicit language',
          source: 'SMS',
          confidence: 73,
          signals: '3 matched patterns',
          time: '14 min ago',
          level: RiskLevel.medium,
        ),
        const SizedBox(height: DesignTokens.spacingSm),
        _AlertTile(
          category: 'Unknown URL in message',
          source: 'SMS',
          confidence: 89,
          signals: 'Domain age < 7 days, no HTTPS',
          time: '1 hr ago',
          level: RiskLevel.high,
        ),
        const SizedBox(height: DesignTokens.spacingSm),
        _AlertTile(
          category: 'Excessive app screen time',
          source: 'App Usage',
          confidence: 100,
          signals: 'TikTok: 3h 12m today (limit: 2h)',
          time: '2 hr ago',
          level: RiskLevel.low,
        ),
      ],
    );
  }

  void _showAddDeviceModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final modelCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: DesignTokens.screenPadding,
          right: DesignTokens.screenPadding,
          top: DesignTokens.screenPadding,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + DesignTokens.screenPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Child Device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.cyberBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(color: AppColors.cyberBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, color: AppColors.cyberBlue, size: 28),
                  const SizedBox(width: DesignTokens.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Pairing PIN: 842-195',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.cyberBlue)),
                        Text('Enter this code on the child Guardian app to pair automatically.',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacingLg),
            const Text('Or Register Manually:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted)),
            const SizedBox(height: DesignTokens.spacingSm),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Child's Device Name (e.g. Maya's Phone)",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            TextField(
              controller: modelCtrl,
              decoration: const InputDecoration(
                labelText: 'Device Model (e.g. Pixel 8, iPhone 14)',
                prefixIcon: Icon(Icons.phone_android_outlined),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXl),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _devices.add(
                      ChildDeviceData(
                        id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text,
                        model: modelCtrl.text.isEmpty ? 'Android Device' : modelCtrl.text,
                        riskLevel: RiskLevel.clean,
                        screenTimeToday: '0m',
                        lastSeen: 'Just now',
                        batteryLevel: 100,
                        location: 'Connected',
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added "${nameCtrl.text}" to monitored devices.')),
                  );
                }
              },
              child: const Text('Add Monitored Device'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceDetailsModal(BuildContext context, ChildDeviceData device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(DesignTokens.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cyberBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: const Icon(Icons.phone_android_rounded, color: AppColors.cyberBlue, size: 26),
                  ),
                  const SizedBox(width: DesignTokens.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        Text('${device.model} • ${device.location}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingLg),
              const Divider(color: AppColors.outline),
              const SizedBox(height: DesignTokens.spacingMd),

              // Device Quick Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickControl(
                    icon: device.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    label: device.isPaused ? 'Resume Internet' : 'Pause Internet',
                    color: device.isPaused ? AppColors.emeraldGreen : AppColors.warningOrange,
                    onTap: () {
                      setModalState(() => device.isPaused = !device.isPaused);
                      setState(() {});
                    },
                  ),
                  _QuickControl(
                    icon: Icons.notifications_active_rounded,
                    label: 'Ring Device',
                    color: AppColors.cyberBlue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ringing ${device.name}...')),
                      );
                    },
                  ),
                  _QuickControl(
                    icon: Icons.location_on_rounded,
                    label: 'Live Track',
                    color: AppColors.neonPurple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Locating ${device.name}: ${device.location}')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: DesignTokens.spacingLg),
              const Text('Screen Time & Restrictions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: DesignTokens.spacingSm),
              _DetailRow(label: 'Today Screen Time', value: device.screenTimeToday, icon: Icons.timer_outlined),
              _DetailRow(label: 'Battery Remaining', value: '${device.batteryLevel}%', icon: Icons.battery_std_rounded),
              _DetailRow(label: 'Safe Zone Status', value: device.location, icon: Icons.shield_outlined),

              const SizedBox(height: DesignTokens.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _devices.removeWhere((d) => d.id == device.id);
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Removed ${device.name}')),
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 18),
                      label: const Text('Unpair Device', style: TextStyle(color: AppColors.errorRed)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.errorRed),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted)),
          ],
        ),
      ),
    );
  }
}

class _DeviceStat extends StatelessWidget {
  const _DeviceStat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceMuted),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.onSurfaceMuted)),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          ],
        ),
      ],
    );
  }
}

class _QuickControl extends StatelessWidget {
  const _QuickControl({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceMuted),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.category,
    required this.source,
    required this.confidence,
    required this.signals,
    required this.time,
    required this.level,
  });

  final String category;
  final String source;
  final int confidence;
  final String signals;
  final String time;
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    Color levelColor;
    switch (level) {
      case RiskLevel.clean:
      case RiskLevel.low:
        levelColor = AppColors.emeraldGreen;
        break;
      case RiskLevel.medium:
        levelColor = AppColors.warningAmber;
        break;
      case RiskLevel.high:
      case RiskLevel.critical:
        levelColor = AppColors.errorRed;
        break;
    }

    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: levelColor, size: 20),
          ),
          const SizedBox(width: DesignTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                Text('$source • $signals', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted)),
        ],
      ),
    );
  }
}
