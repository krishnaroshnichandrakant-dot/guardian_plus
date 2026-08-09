import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// Fresh modern light card widget — replaces glassmorphism with crisp light design,
/// subtle elevation, clean border, and fast touch micro-feedback.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.border,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(DesignTokens.radiusLg);

    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.surface : null,
        gradient: gradient,
        borderRadius: radius,
        border: border ?? Border.all(color: AppColors.outline, width: 1.0),
        boxShadow: gradient == null
            ? const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.cyberBlue.withOpacity(0.08),
          highlightColor: AppColors.cyberBlue.withOpacity(0.04),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(DesignTokens.spacingLg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Secure screen wrapper — applies FLAG_SECURE to prevent screenshots
/// Use on all screens showing risk alerts, location data, SOS status
class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key, required this.child});
  final Widget child;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  static const _channel = MethodChannel('com.guardianplus.security/runtime');

  @override
  void initState() {
    super.initState();
    _setSecure(true);
  }

  @override
  void dispose() {
    _setSecure(false);
    super.dispose();
  }

  Future<void> _setSecure(bool secure) async {
    try {
      await _channel.invokeMethod('setSecureFlag', {'secure': secure});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
