import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/auth_provider.dart';

/// Consent screen — DPDPA / COPPA compliant age gate and disclosure.
/// Must be shown before any monitoring is activated.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key, required this.role});
  final UserRole role;
  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _consentGiven = false;
  bool _ageVerified = false;
  int? _age;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy & Consent'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisclosureCard(),
            const SizedBox(height: DesignTokens.spacingXl),
            if (widget.role == UserRole.parent || widget.role == UserRole.child)
              _buildAgeVerification(),
            const SizedBox(height: DesignTokens.spacingXl),
            _buildConsentCheckbox(),
            const SizedBox(height: DesignTokens.spacingXl),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclosureCard() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.cyberBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.privacy_tip_rounded, color: AppColors.cyberBlue, size: 24),
              SizedBox(width: 8),
              Text(
                'What Guardian Plus collects',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          ..._getDisclosureItems().map((item) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingMd),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, color: item.allowed ? AppColors.emeraldGreen : AppColors.errorRed, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.text,
                        style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<_DisclosureItem> _getDisclosureItems() {
    return [
      _DisclosureItem(
        icon: Icons.check_circle_rounded,
        text: 'SMS metadata and risk scores (processed on-device; content never leaves your phone unless you opt into cloud-assist).',
        allowed: true,
      ),
      _DisclosureItem(
        icon: Icons.check_circle_rounded,
        text: 'App usage statistics (screen time, app names, duration).',
        allowed: true,
      ),
      _DisclosureItem(
        icon: Icons.check_circle_rounded,
        text: 'GPS location (only during active SOS or time-boxed location sharing).',
        allowed: true,
      ),
      _DisclosureItem(
        icon: Icons.cancel_rounded,
        text: 'Raw message content — never stored, never sent to servers.',
        allowed: false,
      ),
      _DisclosureItem(
        icon: Icons.cancel_rounded,
        text: 'WhatsApp, Signal, or Telegram message content — not accessible and not attempted.',
        allowed: false,
      ),
    ];
  }

  Widget _buildAgeVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Age Verification',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        const SizedBox(height: DesignTokens.spacingSm),
        const Text(
          'Guardian Plus requires users to be 13 or older (DPDPA 2023 / COPPA). '
          'Parent or guardian consent is required for children under 18.',
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, height: 1.5),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Your age',
            prefixIcon: Icon(Icons.cake_rounded),
          ),
          onChanged: (v) {
            final parsed = int.tryParse(v);
            setState(() {
              _age = parsed;
              _ageVerified = parsed != null && parsed >= 13;
            });
          },
        ),
        if (_age != null && !_ageVerified)
          Padding(
            padding: const EdgeInsets.only(top: DesignTokens.spacingSm),
            child: Text(
              'You must be 13 or older to use Guardian Plus.',
              style: TextStyle(fontSize: 12, color: AppColors.errorRed),
            ),
          ),
      ],
    );
  }

  Widget _buildConsentCheckbox() {
    return CheckboxListTile(
      value: _consentGiven,
      onChanged: (v) => setState(() => _consentGiven = v ?? false),
      title: const Text(
        'I have read and understand how Guardian Plus uses my data. '
        'I consent to the use described above.',
        style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, height: 1.5),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.cyberBlue,
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _consentGiven &&
        (widget.role != UserRole.parent && widget.role != UserRole.child || _ageVerified);

    return ElevatedButton(
      onPressed: canContinue
          ? () async {
              await ref.read(authServiceProvider).setDirectSession(ref, widget.role);
              if (mounted) {
                if (widget.role == UserRole.child) {
                  context.go(Routes.childHome);
                } else {
                  context.go(Routes.guardianHome);
                }
              }
            }
          : null,
      child: const Text('Agree & Enter Guardian Plus'),
    );
  }
}

class _DisclosureItem {
  const _DisclosureItem({required this.icon, required this.text, required this.allowed});
  final IconData icon;
  final String text;
  final bool allowed;
}
