import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

enum FakeCallStage { setup, ringing, activeCall }

/// Scheduled Fake Call Generator & Incoming Call UI Simulation.
/// Allows setting custom timer delays (e.g. 10s, 1 min, 5 min, 10 min, or user-set minutes)
/// with customizable caller identities.
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({
    super.key,
    this.initialCallerName = 'Mom',
    this.initialCallerNumber = '+91 98765 43210',
    this.autoStartRinging = false,
  });

  final String initialCallerName;
  final String initialCallerNumber;
  final bool autoStartRinging;

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  FakeCallStage _stage = FakeCallStage.setup;

  // Caller State
  late String _callerName;
  late String _callerNumber;
  final _customNameCtrl = TextEditingController();
  final _customNumberCtrl = TextEditingController();

  // Scheduled Timer State
  int _selectedDelayMinutes = 10; // Default 10 minutes as requested
  int _customDelaySeconds = 0;
  bool _isTimerArmed = false;
  int _remainingCountdownSeconds = 0;
  Timer? _countdownTimer;

  // Active Call Talk Timer
  int _talkSeconds = 0;
  Timer? _talkTimer;

  // Audio / Speaker Mute Toggles
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  @override
  void initState() {
    super.initState();
    _callerName = widget.initialCallerName;
    _callerNumber = widget.initialCallerNumber;
    _customNameCtrl.text = _callerName;
    _customNumberCtrl.text = _callerNumber;

    if (widget.autoStartRinging) {
      _stage = FakeCallStage.ringing;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _talkTimer?.cancel();
    _customNameCtrl.dispose();
    _customNumberCtrl.dispose();
    super.dispose();
  }

  void _armScheduledTimer() {
    final totalSeconds = (_selectedDelayMinutes * 60) + _customDelaySeconds;
    if (totalSeconds <= 0) {
      _triggerRingingNow();
      return;
    }

    _countdownTimer?.cancel();
    setState(() {
      _isTimerArmed = true;
      _remainingCountdownSeconds = totalSeconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingCountdownSeconds <= 1) {
        timer.cancel();
        _triggerRingingNow();
      } else {
        if (mounted) {
          setState(() {
            _remainingCountdownSeconds--;
          });
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⏱️ Fake call scheduled! Phone will ring in ${_formatTime(_remainingCountdownSeconds)}.'),
        backgroundColor: AppColors.neonPurple,
      ),
    );
  }

  void _cancelScheduledTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerArmed = false;
      _remainingCountdownSeconds = 0;
    });
  }

  void _triggerRingingNow() {
    _countdownTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _stage = FakeCallStage.ringing;
      _isTimerArmed = false;
    });
  }

  void _answerCall() {
    HapticFeedback.heavyImpact();
    _talkTimer?.cancel();
    _talkSeconds = 0;
    setState(() {
      _stage = FakeCallStage.activeCall;
    });

    _talkTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _talkSeconds++;
        });
      }
    });
  }

  void _endCall() {
    _talkTimer?.cancel();
    _countdownTimer?.cancel();
    if (widget.autoStartRinging) {
      Navigator.pop(context);
    } else {
      setState(() {
        _stage = FakeCallStage.setup;
        _talkSeconds = 0;
      });
    }
  }

  String _formatTime(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case FakeCallStage.setup:
        return _buildSetupScreen();
      case FakeCallStage.ringing:
        return _buildRingingScreen();
      case FakeCallStage.activeCall:
        return _buildActiveCallScreen();
    }
  }

  // ── 1. SETUP & TIMER SELECTION SCREEN ─────────────────────────────────────

  Widget _buildSetupScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scheduled Fake Call',
          style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                  border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.neonPurple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_callback_rounded, color: AppColors.neonPurple, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Escape Uncomfortable Situations',
                            style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Schedule a realistic incoming phone call at your exact desired timer.',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Active Armed Timer Banner
              if (_isTimerArmed) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neonPurple, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_rounded, color: AppColors.neonPurple, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⏱️ Fake Call Timer Armed!',
                              style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.neonPurple),
                            ),
                            Text(
                              'Ringing in ${_formatTime(_remainingCountdownSeconds)} ... Keep phone ready',
                              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _cancelScheduledTimer,
                        child: Text('Cancel', style: GoogleFonts.spaceGrotesk(color: AppColors.safetyPink, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Section 1: Select Caller Identity
              Text(
                '1. Select Caller Identity:',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCallerPresetChip('Mom', '+91 98765 43210', Icons.person_rounded),
                  _buildCallerPresetChip('Dad', '+91 98765 43211', Icons.face_rounded),
                  _buildCallerPresetChip('Boss / Office', '+91 98123 45678', Icons.work_rounded),
                  _buildCallerPresetChip('Police (112)', '112', Icons.local_police_rounded),
                  _buildCallerPresetChip('Doctor', '+91 98989 00112', Icons.medical_services_rounded),
                ],
              ),
              const SizedBox(height: 14),

              // Custom Name & Phone Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customNameCtrl,
                      style: GoogleFonts.inter(fontSize: 12.5),
                      decoration: const InputDecoration(
                        labelText: 'Caller Name',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                      ),
                      onChanged: (val) => setState(() => _callerName = val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _customNumberCtrl,
                      style: GoogleFonts.inter(fontSize: 12.5),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, size: 18),
                      ),
                      onChanged: (val) => setState(() => _callerNumber = val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section 2: Customizable Timer Selection
              Text(
                '2. Set Call Timer Delay:',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTimerPresetChip('⚡ Immediate', 0),
                  _buildTimerPresetChip('⏱️ 10 Sec', 0, customSecs: 10),
                  _buildTimerPresetChip('⏱️ 1 Min', 1),
                  _buildTimerPresetChip('⏱️ 5 Min', 5),
                  _buildTimerPresetChip('⏱️ 10 Min (Default)', 10),
                  _buildTimerPresetChip('⏱️ 15 Min', 15),
                  _buildTimerPresetChip('⏱️ 30 Min', 30),
                ],
              ),

              const SizedBox(height: 18),

              // Custom Slider for User Custom Minute Control
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Custom Timer Duration:',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        ),
                        Text(
                          '$_selectedDelayMinutes Minutes',
                          style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.neonPurple),
                        ),
                      ],
                    ),
                    Slider(
                      value: _selectedDelayMinutes.toDouble().clamp(1.0, 60.0),
                      min: 1.0,
                      max: 60.0,
                      divisions: 59,
                      activeColor: AppColors.neonPurple,
                      inactiveColor: AppColors.surfaceElevated,
                      label: '$_selectedDelayMinutes min',
                      onChanged: (val) {
                        setState(() {
                          _selectedDelayMinutes = val.toInt();
                          _customDelaySeconds = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _triggerRingingNow,
                      icon: const Icon(Icons.flash_on_rounded, color: AppColors.safetyPink),
                      label: const Text('Call Right Now'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.safetyPink,
                        side: const BorderSide(color: AppColors.safetyPink),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _armScheduledTimer,
                      icon: const Icon(Icons.timer_rounded, color: Colors.white),
                      label: Text(
                        _selectedDelayMinutes == 0 && _customDelaySeconds == 10
                            ? 'Arm (10 Sec)'
                            : 'Arm ($_selectedDelayMinutes Min)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
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

  Widget _buildCallerPresetChip(String name, String number, IconData icon) {
    final isSel = _callerName == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _callerName = name;
          _callerNumber = number;
          _customNameCtrl.text = name;
          _customNumberCtrl.text = number;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.neonPurple.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSel ? AppColors.neonPurple : AppColors.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSel ? AppColors.neonPurple : AppColors.onSurfaceMuted),
            const SizedBox(width: 6),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                color: isSel ? AppColors.neonPurple : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerPresetChip(String label, int mins, {int customSecs = 0}) {
    final isSel = _selectedDelayMinutes == mins && _customDelaySeconds == customSecs;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDelayMinutes = mins;
          _customDelaySeconds = customSecs;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.cyberBlue.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSel ? AppColors.cyberBlue : AppColors.outline),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
            color: isSel ? AppColors.cyberBlue : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  // ── 2. INCOMING RINGING CALL SCREEN (Native Phone Call UI Simulation) ─────

  Widget _buildRingingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                'Incoming call...',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // Animated Pulsing Avatar
              CircleAvatar(
                radius: 54,
                backgroundColor: AppColors.cyberBlue.withValues(alpha: 0.25),
                child: Text(
                  _callerName.isNotEmpty ? _callerName[0].toUpperCase() : 'C',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cyberBlue,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.06, 1.06),
                    duration: 900.ms,
                  ),
              const SizedBox(height: 24),

              Text(
                _callerName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _callerNumber,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
              ),

              const Spacer(),

              // Native Ringing Call Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Decline Button (Red)
                  GestureDetector(
                    onTap: _endCall,
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 34),
                        ),
                        const SizedBox(height: 10),
                        Text('Decline', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),

                  // Accept Button (Green)
                  GestureDetector(
                    onTap: _answerCall,
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.emeraldGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.call_rounded, color: Colors.white, size: 34),
                        ),
                        const SizedBox(height: 10),
                        Text('Answer', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. ACTIVE CALL TALK SCREEN (In-Call Controls & Talk Timer) ─────────────

  Widget _buildActiveCallScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                _callerName,
                style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(_talkSeconds),
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.emeraldGreen, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 30),

              CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.emeraldGreen.withValues(alpha: 0.2),
                child: Text(
                  _callerName.isNotEmpty ? _callerName[0].toUpperCase() : 'C',
                  style: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.emeraldGreen),
                ),
              ),

              const Spacer(),

              // In-Call Grid Controls
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildInCallButton(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    isActive: _isMuted,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _buildInCallButton(
                    icon: Icons.dialpad_rounded,
                    label: 'Keypad',
                    isActive: false,
                    onTap: () {},
                  ),
                  _buildInCallButton(
                    icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                    label: _isSpeakerOn ? 'Speaker ON' : 'Speaker',
                    isActive: _isSpeakerOn,
                    onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                  ),
                  _buildInCallButton(
                    icon: Icons.add_call,
                    label: 'Add Call',
                    isActive: false,
                    onTap: () {},
                  ),
                  _buildInCallButton(
                    icon: Icons.videocam_rounded,
                    label: 'FaceTime',
                    isActive: false,
                    onTap: () {},
                  ),
                  _buildInCallButton(
                    icon: Icons.account_box_rounded,
                    label: 'Contacts',
                    isActive: false,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // End Call Button (Red)
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInCallButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}

