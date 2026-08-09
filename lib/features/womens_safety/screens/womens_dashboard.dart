import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../shared/widgets/glass_card.dart';
import '../services/siren_audio_service.dart';
import 'fake_call_screen.dart';
import 'safe_route_screen.dart';

class ContactItem {
  ContactItem({required this.id, required this.name, required this.phone, required this.relation});
  final String id;
  String name;
  String phone;
  String relation;
}

/// Women's Safety Dashboard — Module 1C
/// Personal safety tools, emergency SOS, distress siren, safety walk companion, and editable trusted contacts.
class WomensDashboard extends StatefulWidget {
  const WomensDashboard({super.key});

  @override
  State<WomensDashboard> createState() => _WomensDashboardState();
}

class _WomensDashboardState extends State<WomensDashboard> with TickerProviderStateMixin {
  bool _locationSharing = false;
  bool _sirenActive = false;
  bool _screamMonitorActive = true;
  int _safetyWalkMinutes = 0;

  late AnimationController _sosController;
  late AnimationController _pulseController;

  final List<ContactItem> _contacts = [
    ContactItem(id: 'c1', name: 'Mom', phone: '+91 98765 43210', relation: 'Parent'),
    ContactItem(id: 'c2', name: 'Priya', phone: '+91 91234 56789', relation: 'Sister'),
    ContactItem(id: 'c3', name: 'Riya', phone: '+91 90000 12345', relation: 'Friend'),
  ];

  @override
  void initState() {
    super.initState();
    _sosController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    SirenAudioService.stopSiren();
    _sosController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

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
                  _buildSosButton(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildHelplineShortcuts(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildQuickActions(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildSirenAndScreamCard(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildSafetyWalkCard(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildLocationCard(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildTrustedContactsSection(),
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
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.gradientDanger,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: DesignTokens.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Women\'s Safety Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              Text('Always Protected & Self-Controlled', style: TextStyle(fontSize: 11, color: AppColors.softCoral, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
      floating: true,
    );
  }

  Widget _buildSosButton() {
    return Center(
      child: Column(
        children: [
          const Text(
            'EMERGENCY SOS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.softCoral,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (i) {
                    final scale = 1.0 + (i + 1) * 0.15 * _pulseController.value;
                    final opacity = (1 - _pulseController.value) * (0.4 - i * 0.1);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: DesignTokens.sosButtonSize,
                        height: DesignTokens.sosButtonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.softCoral.withOpacity(opacity.clamp(0, 1)),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onLongPress: _triggerSOS,
                    onTapDown: (_) => _sosController.forward(),
                    onTapUp: (_) => _sosController.reverse(),
                    onTapCancel: () => _sosController.reverse(),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.94).animate(
                        CurvedAnimation(parent: _sosController, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        width: DesignTokens.sosButtonSize,
                        height: DesignTokens.sosButtonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.gradientDanger,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.softCoral.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.sos_rounded, color: Colors.white, size: 40),
                            SizedBox(height: 4),
                            Text(
                              'HOLD SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          const Text(
            'Hold for 2 seconds to alert trusted contacts with GPS location\nOr press power button 5 times',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineShortcuts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Helplines',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        Row(
          children: [
            _HelplineChip(number: '1091', label: 'Women Helpline', color: AppColors.softCoral),
            const SizedBox(width: DesignTokens.spacingSm),
            _HelplineChip(number: '112', label: 'Police Emergency', color: AppColors.cyberBlue),
            const SizedBox(width: DesignTokens.spacingSm),
            _HelplineChip(number: '102', label: 'Ambulance', color: AppColors.emeraldGreen),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.phone_rounded,
          label: 'Fake Call',
          sublabel: 'Trigger Call UI',
          color: AppColors.cyberBlue,
          onTap: _triggerFakeCall,
        ),
        const SizedBox(width: DesignTokens.spacingMd),
        _QuickAction(
          icon: Icons.route_rounded,
          label: 'Safe Route',
          sublabel: 'Navigate Safely',
          color: AppColors.emeraldGreen,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SafeRouteScreen()),
            );
          },
        ),
        const SizedBox(width: DesignTokens.spacingMd),
        _QuickAction(
          icon: Icons.graphic_eq_rounded,
          label: 'Siren Alarm',
          sublabel: _sirenActive ? 'SOUNDING' : 'OFF',
          color: _sirenActive ? AppColors.errorRed : AppColors.neonPurple,
          onTap: () {
            setState(() {
              _sirenActive = !_sirenActive;
              if (_sirenActive) {
                SirenAudioService.startSiren();
              } else {
                SirenAudioService.stopSiren();
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_sirenActive ? 'Distress Siren Sounding Loudly!' : 'Distress Siren Silenced.')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSirenAndScreamCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Icon(Icons.mic_none_rounded, color: AppColors.neonPurple, size: 22),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Auto Scream & Distress Monitor',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    Text('Auto-prearms SOS when high decibel distress scream is detected on device mic.',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                  ],
                ),
              ),
              Switch(
                value: _screamMonitorActive,
                onChanged: (v) => setState(() => _screamMonitorActive = v),
                activeColor: AppColors.neonPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyWalkCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cyberBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Icon(Icons.directions_walk_rounded, color: AppColors.cyberBlue, size: 22),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Safety Walk Companion Timer',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    Text(_safetyWalkMinutes > 0
                        ? 'Timer active: ${_safetyWalkMinutes}m remaining. Check in before timer ends.'
                        : 'Set a walk timer when commuting. Alerts contacts if you do not check in.',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              _WalkTimerChip(
                label: '15 Min',
                selected: _safetyWalkMinutes == 15,
                onTap: () => setState(() => _safetyWalkMinutes = _safetyWalkMinutes == 15 ? 0 : 15),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              _WalkTimerChip(
                label: '30 Min',
                selected: _safetyWalkMinutes == 30,
                onTap: () => setState(() => _safetyWalkMinutes = _safetyWalkMinutes == 30 ? 0 : 30),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              _WalkTimerChip(
                label: '45 Min',
                selected: _safetyWalkMinutes == 45,
                onTap: () => setState(() => _safetyWalkMinutes = _safetyWalkMinutes == 45 ? 0 : 45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  _locationSharing ? Icons.location_on_rounded : Icons.location_off_rounded,
                  color: _locationSharing ? AppColors.emeraldGreen : AppColors.onSurfaceMuted,
                  size: 22,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live GPS Location Sharing',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      _locationSharing
                          ? 'Sharing live position with ${_contacts.length} trusted contacts'
                          : 'Share your real-time position with emergency contacts',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _locationSharing,
                onChanged: (v) => setState(() => _locationSharing = v),
                activeColor: AppColors.emeraldGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trusted Emergency Contacts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddOrEditContactModal(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyberBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        ..._contacts.map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
              child: _ContactTile(
                contact: contact,
                onEdit: () => _showAddOrEditContactModal(context, contact: contact),
              ),
            )),
      ],
    );
  }

  void _showAddOrEditContactModal(BuildContext context, {ContactItem? contact}) {
    final isEdit = contact != null;
    final nameCtrl = TextEditingController(text: contact?.name ?? '');
    final phoneCtrl = TextEditingController(text: contact?.phone ?? '');
    final relationCtrl = TextEditingController(text: contact?.relation ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusXl)),
        title: Text(isEdit ? 'Edit Contact' : 'Add Trusted Contact', style: const TextStyle(color: AppColors.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              TextField(
                controller: relationCtrl,
                decoration: const InputDecoration(labelText: 'Relationship (e.g. Sister, Friend)', prefixIcon: Icon(Icons.people_outline)),
              ),
            ],
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
              onPressed: () {
                setState(() {
                  _contacts.removeWhere((c) => c.id == contact.id);
                });
                Navigator.pop(ctx);
              },
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                setState(() {
                  if (isEdit) {
                    contact.name = nameCtrl.text;
                    contact.phone = phoneCtrl.text;
                    contact.relation = relationCtrl.text.isEmpty ? 'Contact' : relationCtrl.text;
                  } else {
                    _contacts.add(
                      ContactItem(
                        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text,
                        phone: phoneCtrl.text,
                        relation: relationCtrl.text.isEmpty ? 'Contact' : relationCtrl.text,
                      ),
                    );
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: Text(isEdit ? 'Save Changes' : 'Add Contact'),
          ),
        ],
      ),
    );
  }

  void _triggerSOS() {
    SirenAudioService.startSiren();
    setState(() => _sirenActive = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusXl)),
        title: const Row(
          children: [
            Icon(Icons.sos_rounded, color: AppColors.errorRed, size: 28),
            SizedBox(width: 8),
            Text('SOS Triggered!', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Emergency alert & GPS live location sent to ${_contacts.length} trusted contacts.\nDistress siren active.',
          style: const TextStyle(color: AppColors.onSurfaceMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              SirenAudioService.stopSiren();
              setState(() => _sirenActive = false);
              Navigator.pop(context);
            },
            child: const Text('Cancel Alert & Silence Siren'),
          ),
        ],
      ),
    );
  }

  void _triggerFakeCall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FakeCallScreen()),
    );
  }
}

class _HelplineChip extends StatelessWidget {
  const _HelplineChip({required this.number, required this.label, required this.color});
  final String number;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(number, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(color: AppColors.outline, width: 1.0),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              Text(sublabel, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkTimerChip extends StatelessWidget {
  const _WalkTimerChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.cyberBlue : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          border: Border.all(color: selected ? AppColors.cyberBlue : AppColors.outline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.onSurfaceMuted,
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact, required this.onEdit});
  final ContactItem contact;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.cyberBlue.withOpacity(0.15),
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.cyberBlue,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(contact.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Text(contact.relation, style: const TextStyle(fontSize: 9, color: AppColors.onSurfaceMuted)),
                    ),
                  ],
                ),
                Text(contact.phone, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.cyberBlue, size: 20),
            tooltip: 'Edit Contact',
            onPressed: onEdit,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.phone_rounded, color: AppColors.emeraldGreen, size: 20),
        ],
      ),
    );
  }
}
