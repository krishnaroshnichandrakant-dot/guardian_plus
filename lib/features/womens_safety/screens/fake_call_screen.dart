import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

/// Simulated incoming phone call UI to help user safely exit uncomfortable situations.
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({
    super.key,
    this.callerName = 'Mom',
    this.callerNumber = '+91 98765 43210',
  });

  final String callerName;
  final String callerNumber;

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _callAnswered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Caller avatar
              CircleAvatar(
                radius: 54,
                backgroundColor: AppColors.cyberBlue.withOpacity(0.2),
                child: Text(
                  widget.callerName[0],
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyberBlue,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.05, 1.05),
                    duration: 1.seconds,
                  ),
              const SizedBox(height: 24),
              Text(
                widget.callerName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _callAnswered ? '00:04' : 'Incoming call...',
                style: TextStyle(
                  fontSize: 16,
                  color: _callAnswered ? AppColors.emeraldGreen : Colors.white60,
                ),
              ),
              const Spacer(),

              // Answer / Decline buttons
              if (!_callAnswered)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Column(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(
                              color: AppColors.errorRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 8),
                          const Text('Decline', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    // Accept
                    GestureDetector(
                      onTap: () => setState(() => _callAnswered = true),
                      child: Column(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(
                              color: AppColors.emeraldGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.call_rounded, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 8),
                          const Text('Answer', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                // End call
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: AppColors.errorRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 8),
                      const Text('End Call', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
