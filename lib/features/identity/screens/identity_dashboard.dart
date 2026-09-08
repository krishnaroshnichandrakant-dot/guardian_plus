import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// Guardian Identity (PS #20) — Screen 9 from reference mockups.
class IdentityDashboard extends StatefulWidget {
  const IdentityDashboard({super.key});

  @override
  State<IdentityDashboard> createState() => _IdentityDashboardState();
}

class _IdentityDashboardState extends State<IdentityDashboard> {
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guardian Identity',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Secure Access. Complete Control.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.emeraldGreen,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(DesignTokens.screenPadding),
          child: Column(
            children: [
              _buildIdentityOptionsContainer(context),
              const SizedBox(height: 24),
              _buildSecurityStatusCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityOptionsContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          // Biometric Unlock (with Switch)
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            secondary: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fingerprint_rounded, color: AppColors.emeraldGreen, size: 22),
            ),
            title: Text(
              'Biometric Unlock',
              style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            value: _biometricEnabled,
            activeThumbColor: AppColors.emeraldGreen,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _biometricEnabled = v);
            },
          ),
          const Divider(color: AppColors.outline, height: 1, indent: 64),

          // Enter PIN
          _buildItem(
            icon: Icons.dialpad_rounded,
            title: 'Enter PIN',
            accent: AppColors.cyberBlue,
            onTap: () => _showPinDialog(context),
          ),
          const Divider(color: AppColors.outline, height: 1, indent: 64),

          // Trusted Devices
          _buildItem(
            icon: Icons.devices_rounded,
            title: 'Trusted Devices',
            subtitle: '3 devices',
            accent: AppColors.neonPurple,
            onTap: () => _showDevicesSheet(context),
          ),
          const Divider(color: AppColors.outline, height: 1, indent: 64),

          // Manage Sessions
          _buildItem(
            icon: Icons.manage_accounts_rounded,
            title: 'Manage Sessions',
            accent: AppColors.scamAmber,
            onTap: () => _showMessage(context, 'All active sessions are verified & secured.'),
          ),
          const Divider(color: AppColors.outline, height: 1, indent: 64),

          // Account Security
          _buildItem(
            icon: Icons.security_rounded,
            title: 'Account Security',
            accent: AppColors.emeraldGreen,
            onTap: () => _showMessage(context, 'Argon2id + PBKDF2 Master Encryption Active.'),
          ),
          const Divider(color: AppColors.outline, height: 1, indent: 64),

          // Privacy Settings
          _buildItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Settings',
            accent: AppColors.detectiveTeal,
            onTap: () => _showMessage(context, 'Zero-Knowledge On-Device Storage Enabled.'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: accent, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceMuted))
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.onSurfaceSubtle,
        size: 20,
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }

  Widget _buildSecurityStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.emeraldGreen, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End-to-End Encryption',
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                Text(
                  'X25519 & Argon2id key exchange active',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context) {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Security PIN', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'Enter 6-digit PIN'),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldGreen, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Confirm PIN'),
          ),
        ],
      ),
    );
  }

  void _showDevicesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('3 Trusted Devices', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
            const SizedBox(height: 14),
            _buildDeviceRow('📱 iPhone 15 Pro (This device)', 'Online now', true),
            _buildDeviceRow('💻 MacBook Air M2', 'Active 10m ago', true),
            _buildDeviceRow('📱 Samsung Galaxy S24', 'Active yesterday', true),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceRow(String name, String active, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            Text(active, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceMuted)),
          ]),
          const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 18),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.surfaceElevated, behavior: SnackBarBehavior.floating),
    );
  }
}
