import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// Safe Route (PS #22) — Screen 4 from reference mockups.
class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  State<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen>
    with SingleTickerProviderStateMixin {
  int _selectedRouteIndex = 0; // 0 = Route A, 1 = Route B, 2 = Route C
  String _selectedFilter = 'Recommended';
  bool _isNavigating = false;
  int _navStep = 0;
  Timer? _navTimer;

  final TextEditingController _originCtrl =
      TextEditingController(text: 'Current Location (Home)');
  final TextEditingController _destCtrl =
      TextEditingController(text: 'Metro Station, Sector 18');

  final List<String> _navInstructions = [
    'Head North on Palm Avenue (Well-lit, CCTV active)',
    'In 200m, turn right onto Gandhi Marg (Police Booth nearby)',
    'Continue straight past 24/7 Apollo Pharmacy (Safe Haven)',
    'Arriving at Metro Station, Sector 18 Gate 2 in 3 mins',
  ];

  @override
  void dispose() {
    _navTimer?.cancel();
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  void _toggleNavigation() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isNavigating = !_isNavigating;
      _navStep = 0;
    });

    if (_isNavigating) {
      _navTimer?.cancel();
      _navTimer = Timer.periodic(const Duration(seconds: 4), (t) {
        if (!mounted) return;
        setState(() {
          _navStep = (_navStep + 1) % _navInstructions.length;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🧭 Live Safe Navigation Active on Route ${_selectedRouteIndex == 0 ? "A (85% Safe)" : _selectedRouteIndex == 1 ? "B (62% Safe)" : "C"}. Guardian Live Tracking is on.',
          ),
          backgroundColor: AppColors.emeraldGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      _navTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safe Navigation stopped.'),
          backgroundColor: AppColors.surfaceHighest,
        ),
      );
    }
  }

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
              'Safe Route Navigation',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'AI Well-Lit & CCTV Monitored Paths',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.emeraldGreen,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert_rounded, color: AppColors.emeraldGreen),
            tooltip: 'Swap locations',
            onPressed: () {
              HapticFeedback.selectionClick();
              final temp = _originCtrl.text;
              _originCtrl.text = _destCtrl.text;
              _destCtrl.text = temp;
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(DesignTokens.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationInputCard(),
                    const SizedBox(height: 14),
                    _buildFilterPills(),
                    const SizedBox(height: 16),
                    if (_isNavigating) _buildLiveNavigationCard(),
                    const SizedBox(height: 12),
                    _buildInteractiveMapCanvas(),
                    const SizedBox(height: 18),
                    _buildRouteComparisonCards(),
                    const SizedBox(height: 18),
                    _buildSafeHavenPills(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigationButton(context),
          ],
        ),
      ),
    );
  }

  // ── Location Input Box ────────────────────────────────────────────────────

  Widget _buildLocationInputCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.emeraldGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _originCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Starting point',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.my_location_rounded, size: 18, color: AppColors.emeraldGreen),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _originCtrl.text = 'Current GPS Location';
                  setState(() {});
                },
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 12,
                child: VerticalDivider(color: AppColors.outlineVariant, thickness: 2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.safetyPink,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _destCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Destination',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 18, color: AppColors.onSurfaceMuted),
                onPressed: () {
                  _showDestinationSearchModal(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter Pills: Recommended / Faster / Shorter ──────────────────────────

  Widget _buildFilterPills() {
    final filters = ['Recommended', 'Maximum CCTV', 'Well-Lit Only', 'Faster'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSel = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = f);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.emeraldGreen : AppColors.surface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(
                    color: isSel ? AppColors.emeraldGreen : AppColors.outline,
                  ),
                ),
                child: Text(
                  f,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSel ? AppColors.onPrimary : AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Live Navigation HUD ───────────────────────────────────────────────────

  Widget _buildLiveNavigationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.emeraldGreen, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGreen.withValues(alpha: 0.15),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.emeraldGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.turn_right_rounded, color: AppColors.emeraldGreen, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.emeraldGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE NAVIGATION ACTIVE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emeraldGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _navInstructions[_navStep],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  // ── Interactive Map Canvas ────────────────────────────────────────────────

  Widget _buildInteractiveMapCanvas() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEE9), // Light modern cartographic background
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        child: Stack(
          children: [
            // Custom Map Route Vector Canvas (Light Theme)
            CustomPaint(
              size: const Size(double.infinity, 250),
              painter: _MapRoutePainter(selectedRoute: _selectedRouteIndex, isNavigating: _isNavigating),
            ),

            // Safe Haven Point Markers
            Positioned(
              left: 110,
              top: 70,
              child: _buildSafeHavenMapPin('Police Station', Icons.local_police_rounded, AppColors.cyberBlue),
            ),
            Positioned(
              right: 120,
              top: 130,
              child: _buildSafeHavenMapPin('24/7 Apollo Pharmacy', Icons.local_pharmacy_rounded, AppColors.emeraldGreen),
            ),

            // Start and End Pins
            Positioned(
              left: 30,
              top: 30,
              child: _buildPin(Icons.my_location_rounded, AppColors.emeraldGreen, 'Start (Home)'),
            ),
            Positioned(
              right: 35,
              bottom: 35,
              child: _buildPin(Icons.location_on_rounded, AppColors.safetyPink, 'Metro Station'),
            ),

            // Floating Route Tags on Map
            Positioned(
              left: 90,
              top: 45,
              child: _buildRouteMapTag(
                'Route A · 85% Safe',
                AppColors.emeraldGreen,
                isSelected: _selectedRouteIndex == 0,
                onTap: () => setState(() => _selectedRouteIndex = 0),
              ),
            ),
            Positioned(
              right: 80,
              top: 95,
              child: _buildRouteMapTag(
                'Route B · 62% Safe',
                AppColors.warningAmber,
                isSelected: _selectedRouteIndex == 1,
                onTap: () => setState(() => _selectedRouteIndex = 1),
              ),
            ),
            Positioned(
              right: 40,
              bottom: 95,
              child: _buildRouteMapTag(
                'Route C · 48% Risk',
                AppColors.safetyPink,
                isSelected: _selectedRouteIndex == 2,
                onTap: () => setState(() => _selectedRouteIndex = 2),
              ),
            ),

            // Live Compass / Recenter Button
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.explore_rounded, color: AppColors.emeraldGreen, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPin(IconData icon, Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _buildSafeHavenMapPin(String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Safe Haven: $name (Open 24/7)'),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              name,
              style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteMapTag(String text, Color color, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? color : Colors.black).withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  // ── 3 Route Comparison Cards ──────────────────────────────────────────────

  Widget _buildRouteComparisonCards() {
    final routes = [
      _RouteOption(
        name: 'Route A (Safe)',
        time: '23 min',
        distance: '5.1 km',
        safetyScore: 85,
        rating: 'Well-Lit & CCTV',
        color: AppColors.emeraldGreen,
      ),
      _RouteOption(
        name: 'Route B (Main)',
        time: '18 min',
        distance: '4.3 km',
        safetyScore: 62,
        rating: 'Moderate Light',
        color: AppColors.warningAmber,
      ),
      _RouteOption(
        name: 'Route C (Alley)',
        time: '16 min',
        distance: '4.0 km',
        safetyScore: 48,
        rating: 'Dimly-Lit Cut',
        color: AppColors.safetyPink,
      ),
    ];

    return Row(
      children: routes.asMap().entries.map((entry) {
        final i = entry.key;
        final r = entry.value;
        final isSel = _selectedRouteIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedRouteIndex = i);
              },
              child: AnimatedContainer(
                duration: DesignTokens.animFast,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSel ? r.color.withValues(alpha: 0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  border: Border.all(
                    color: isSel ? r.color : AppColors.outline,
                    width: isSel ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSel ? r.color.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${r.time} · ${r.distance}',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: r.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Score: ${r.safetyScore}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: r.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.rating,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: r.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Safe Haven Highlights ─────────────────────────────────────────────────

  Widget _buildSafeHavenPills() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En-Route Safe Havens',
            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSafeHavenChip(Icons.local_police_rounded, 'Police Booth (400m)', AppColors.cyberBlue),
              const SizedBox(width: 8),
              _buildSafeHavenChip(Icons.local_pharmacy_rounded, 'Apollo 24/7 (1.2km)', AppColors.emeraldGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafeHavenChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Start Navigation CTA ───────────────────────────────────────────

  Widget _buildBottomNavigationButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      child: ElevatedButton.icon(
        onPressed: _toggleNavigation,
        icon: Icon(_isNavigating ? Icons.stop_rounded : Icons.navigation_rounded, color: AppColors.onPrimary),
        label: Text(_isNavigating ? 'End Safe Navigation' : 'Start Live Safe Route Navigation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isNavigating ? AppColors.safetyPink : AppColors.emeraldGreen,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, DesignTokens.buttonHeightLg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        ),
      ),
    );
  }

  void _showDestinationSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Destination',
                  style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.subway_rounded, color: AppColors.emeraldGreen),
                  title: const Text('Metro Station, Sector 18'),
                  subtitle: const Text('5.1 km · 85% Safe Route Available'),
                  onTap: () {
                    _destCtrl.text = 'Metro Station, Sector 18';
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_rounded, color: AppColors.cyberBlue),
                  title: const Text('Mall of India, Sector 18'),
                  subtitle: const Text('6.3 km · Well-lit Corridor'),
                  onTap: () {
                    _destCtrl.text = 'Mall of India, Sector 18';
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_hospital_rounded, color: AppColors.safetyPink),
                  title: const Text('City Hospital, Block C'),
                  subtitle: const Text('3.8 km · 24/7 Emergency Route'),
                  onTap: () {
                    _destCtrl.text = 'City Hospital, Block C';
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RouteOption {
  const _RouteOption({
    required this.name,
    required this.time,
    required this.distance,
    required this.safetyScore,
    required this.rating,
    required this.color,
  });
  final String name;
  final String time;
  final String distance;
  final int safetyScore;
  final String rating;
  final Color color;
}

class _MapRoutePainter extends CustomPainter {
  const _MapRoutePainter({required this.selectedRoute, required this.isNavigating});
  final int selectedRoute;
  final bool isNavigating;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Light map street grid / avenues
    final streetPaint = Paint()
      ..color = const Color(0xFFD6E4DC)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Background road network lines
    canvas.drawLine(Offset(0, h * 0.35), Offset(w, h * 0.35), streetPaint);
    canvas.drawLine(Offset(0, h * 0.7), Offset(w, h * 0.7), streetPaint);
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.3, h), streetPaint);
    canvas.drawLine(Offset(w * 0.75, 0), Offset(w * 0.75, h), streetPaint);

    // Park area green patch
    final parkPaint = Paint()..color = const Color(0xFFC7DFD3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.4, h * 0.1, w * 0.25, h * 0.35), const Radius.circular(8)),
      parkPaint,
    );

    // Route A (Green Curve - Safer)
    final routeAPath = Path()
      ..moveTo(40, 45)
      ..cubicTo(w * 0.2, h * 0.15, w * 0.5, h * 0.35, w * 0.65, h * 0.6)
      ..cubicTo(w * 0.75, h * 0.75, w * 0.85, h * 0.85, w - 45, h - 45);

    final routeAPaint = Paint()
      ..color = AppColors.emeraldGreen.withValues(alpha: selectedRoute == 0 ? 1.0 : 0.4)
      ..strokeWidth = selectedRoute == 0 ? 6 : 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(routeAPath, routeAPaint);

    // Route B (Yellow Curve - Moderate)
    final routeBPath = Path()
      ..moveTo(40, 45)
      ..cubicTo(w * 0.35, h * 0.45, w * 0.55, h * 0.25, w * 0.75, h * 0.5)
      ..lineTo(w - 45, h - 45);

    final routeBPaint = Paint()
      ..color = AppColors.warningAmber.withValues(alpha: selectedRoute == 1 ? 1.0 : 0.4)
      ..strokeWidth = selectedRoute == 1 ? 6 : 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(routeBPath, routeBPaint);

    // Route C (Red Direct - Faster/High Risk)
    final routeCPath = Path()
      ..moveTo(40, 45)
      ..lineTo(w * 0.45, h * 0.65)
      ..lineTo(w - 45, h - 45);

    final routeCPaint = Paint()
      ..color = AppColors.safetyPink.withValues(alpha: selectedRoute == 2 ? 1.0 : 0.4)
      ..strokeWidth = selectedRoute == 2 ? 6 : 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(routeCPath, routeCPaint);

    // Active Navigation User Marker
    if (isNavigating) {
      final navMarkerPaint = Paint()..color = AppColors.emeraldGreen;
      final navGlowPaint = Paint()..color = AppColors.emeraldGreen.withValues(alpha: 0.3);

      final navPos = selectedRoute == 0
          ? Offset(w * 0.45, h * 0.38)
          : selectedRoute == 1
              ? Offset(w * 0.55, h * 0.35)
              : Offset(w * 0.45, h * 0.65);

      canvas.drawCircle(navPos, 14, navGlowPaint);
      canvas.drawCircle(navPos, 8, navMarkerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapRoutePainter oldDelegate) =>
      oldDelegate.selectedRoute != selectedRoute || oldDelegate.isNavigating != isNavigating;
}
