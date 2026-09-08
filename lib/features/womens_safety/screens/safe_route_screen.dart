import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../services/real_routing_service.dart';

/// Safe Route (PS #22) — Real OpenStreetMap & OSRM Engine.
class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  State<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen>
    with SingleTickerProviderStateMixin {
  int _selectedRouteIndex = 0; // 0 = Route A (Safe), 1 = Route B (Closest/Fastest), 2 = Route C (Shortcut)
  String _selectedFilter = 'Recommended';
  bool _isNavigating = false;
  bool _isLoadingGps = false;
  bool _isCalculatingRoute = false;
  int _navStep = 0;
  Timer? _navTimer;

  // Real GPS Coordinates (Default: Noida Sector 62 -> Sector 18 Metro)
  double _originLat = 28.6280;
  double _originLng = 77.3649;
  double _destLat = 28.5708;
  double _destLng = 77.3261;

  final TextEditingController _originCtrl =
      TextEditingController(text: 'Sector 62, Noida, UP');
  final TextEditingController _destCtrl =
      TextEditingController(text: 'Metro Station, Sector 18, Noida');

  List<RealRouteData> _calculatedRoutes = [];

  @override
  void initState() {
    super.initState();
    _fetchLiveGpsAndAddress();
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  /// Get real user location & real reverse-geocoded address
  Future<void> _fetchLiveGpsAndAddress() async {
    setState(() => _isLoadingGps = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 4),
      );

      _originLat = pos.latitude;
      _originLng = pos.longitude;

      // Reverse geocode to exact real address
      final address = await RealRoutingService.getRealAddressFromCoords(
        _originLat,
        _originLng,
      );

      if (mounted) {
        setState(() {
          _originCtrl.text = address;
          _isLoadingGps = false;
        });
        await _recalculateRealRoutes();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingGps = false);
        _recalculateRealRoutes();
      }
    }
  }

  /// Calculate real road distance & duration using Open Source Routing Machine (OSRM)
  Future<void> _recalculateRealRoutes() async {
    if (_isCalculatingRoute) return;
    setState(() => _isCalculatingRoute = true);

    try {
      final routes = await RealRoutingService.fetchRealRoutes(
        originLat: _originLat,
        originLng: _originLng,
        destLat: _destLat,
        destLng: _destLng,
        destName: _destCtrl.text,
      );

      if (mounted) {
        setState(() {
          _calculatedRoutes = routes;
          _isCalculatingRoute = false;
          _selectedRouteIndex = 0;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCalculatingRoute = false);
      }
    }
  }

  void _toggleNavigation() {
    HapticFeedback.heavyImpact();
    if (_calculatedRoutes.isEmpty) return;

    final activeRoute = _calculatedRoutes[_selectedRouteIndex.clamp(0, _calculatedRoutes.length - 1)];

    setState(() {
      _isNavigating = !_isNavigating;
      _navStep = 0;
    });

    if (_isNavigating) {
      _navTimer?.cancel();
      _navTimer = Timer.periodic(const Duration(seconds: 4), (t) {
        if (!mounted) return;
        setState(() {
          _navStep = (_navStep + 1) % activeRoute.turnInstructions.length;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🧭 Real GPS Navigation Active on ${activeRoute.name} (${activeRoute.distanceKm} km · ${activeRoute.durationMins} mins). Guardian SOS Active.',
          ),
          backgroundColor: activeRoute.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      _navTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safe Navigation Session Ended.'),
          backgroundColor: AppColors.surfaceHighest,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeRoute = _calculatedRoutes.isEmpty
        ? null
        : _calculatedRoutes[_selectedRouteIndex.clamp(0, _calculatedRoutes.length - 1)];

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
              'Real OSRM Distance & OpenStreetMap Intel',
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
            tooltip: 'Swap Locations',
            onPressed: () {
              HapticFeedback.selectionClick();
              final tempText = _originCtrl.text;
              _originCtrl.text = _destCtrl.text;
              _destCtrl.text = tempText;

              final tempLat = _originLat;
              final tempLng = _originLng;
              _originLat = _destLat;
              _originLng = _destLng;
              _destLat = tempLat;
              _destLng = tempLng;

              _recalculateRealRoutes();
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
                    if (_isNavigating && activeRoute != null)
                      _buildLiveNavigationCard(activeRoute),
                    const SizedBox(height: 12),
                    _buildInteractiveMapCanvas(activeRoute),
                    const SizedBox(height: 18),
                    if (_isCalculatingRoute)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: AppColors.emeraldGreen),
                        ),
                      )
                    else ...[
                      _buildRouteComparisonCards(),
                      const SizedBox(height: 18),
                      if (activeRoute != null) _buildSafeHavenPills(activeRoute),
                    ],
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

  // ── Location Input Box with Live GPS & Nominatim Search ───────────────────

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
                    hintText: 'Starting location in India',
                  ),
                  onSubmitted: (val) {
                    _searchAndSetOrigin(val);
                  },
                ),
              ),
              _isLoadingGps
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.my_location_rounded, size: 18, color: AppColors.emeraldGreen),
                      tooltip: 'Detect Exact GPS Location',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _fetchLiveGpsAndAddress();
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
                    hintText: 'Destination address / landmark',
                  ),
                  onSubmitted: (val) {
                    _searchAndSetDestination(val);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 18, color: AppColors.onSurfaceMuted),
                tooltip: 'Search Real OpenStreetMap Places',
                onPressed: () {
                  _showRealSearchModal(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _searchAndSetOrigin(String query) async {
    if (query.trim().isEmpty) return;
    final results = await RealRoutingService.searchRealLocations(query);
    if (results.isNotEmpty && mounted) {
      setState(() {
        _originCtrl.text = results[0].displayName;
        _originLat = results[0].lat;
        _originLng = results[0].lng;
      });
      _recalculateRealRoutes();
    }
  }

  Future<void> _searchAndSetDestination(String query) async {
    if (query.trim().isEmpty) return;
    final results = await RealRoutingService.searchRealLocations(query);
    if (results.isNotEmpty && mounted) {
      setState(() {
        _destCtrl.text = results[0].displayName;
        _destLat = results[0].lat;
        _destLng = results[0].lng;
      });
      _recalculateRealRoutes();
    }
  }

  // ── Filter Pills ──────────────────────────────────────────────────────────

  Widget _buildFilterPills() {
    final filters = ['Recommended', 'Closest & Fastest', 'Maximum CCTV', 'Well-Lit Only'];
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
                setState(() {
                  _selectedFilter = f;
                  if (f == 'Closest & Fastest') {
                    _selectedRouteIndex = 1;
                  } else if (f == 'Maximum CCTV' || f == 'Recommended') {
                    _selectedRouteIndex = 0;
                  }
                });
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

  // ── Live Turn-by-Turn Navigation HUD ──────────────────────────────────────

  Widget _buildLiveNavigationCard(RealRouteData activeRoute) {
    final instructions = activeRoute.turnInstructions;
    final currentInstruction = instructions.isEmpty
        ? 'Head towards destination'
        : instructions[_navStep.clamp(0, instructions.length - 1)].instruction;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: activeRoute.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (activeRoute.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber).withValues(alpha: 0.15),
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
              color: (activeRoute.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.navigation_rounded, color: activeRoute.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber, size: 24),
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
                      decoration: BoxDecoration(
                        color: activeRoute.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'REAL GPS NAVIGATION (${activeRoute.distanceKm} KM · ${activeRoute.durationMins} MINS)',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: activeRoute.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currentInstruction,
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

  // ── Real Interactive OpenStreetMap Map Canvas ──────────────────────────────

  Widget _buildInteractiveMapCanvas(RealRouteData? activeRoute) {
    return _RealOsmInteractiveMap(
      originLat: _originLat,
      originLng: _originLng,
      destLat: _destLat,
      destLng: _destLng,
      selectedRoute: _selectedRouteIndex,
      isNavigating: _isNavigating,
      routeData: activeRoute,
      onRecenter: () {
        HapticFeedback.selectionClick();
        _fetchLiveGpsAndAddress();
      },
      onSelectRoute: (idx) {
        setState(() => _selectedRouteIndex = idx);
      },
    );
  }

  // ── 3 Real Route Comparison Cards ─────────────────────────────────────────

  Widget _buildRouteComparisonCards() {
    return Column(
      children: [
        Row(
          children: _calculatedRoutes.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            final isSel = _selectedRouteIndex == i;
            final isClosest = i == 1;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _calculatedRoutes.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedRouteIndex = i);
                  },
                  child: AnimatedContainer(
                    duration: DesignTokens.animFast,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSel ? (r.safetyScore > 80 ? AppColors.emeraldGreen.withValues(alpha: 0.1) : AppColors.warningAmber.withValues(alpha: 0.1)) : AppColors.surface,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                      border: Border.all(
                        color: isSel ? (r.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber) : AppColors.outline,
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                r.name,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isClosest)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.cyberBlue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CLOSEST',
                                  style: GoogleFonts.spaceGrotesk(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.cyberBlue),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${r.distanceKm} km · ${r.durationMins} min',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: (r.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Safety Score: ${r.safetyScore}%',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: r.safetyScore > 80 ? AppColors.emeraldGreen : AppColors.warningAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Safe Haven Highlights ─────────────────────────────────────────────────

  Widget _buildSafeHavenPills(RealRouteData activeRoute) {
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
            'En-Route Real Safe Havens & CCTV Grid',
            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          if (activeRoute.safeHavens.isNotEmpty)
            Row(
              children: activeRoute.safeHavens.map((sh) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, size: 16, color: AppColors.emeraldGreen),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              sh.name,
                              style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              '⚠️ Shortcut Route: Low camera density. Use Route A (Safety Corridor) for 24/7 CCTV.',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.warningAmber, fontWeight: FontWeight.w600),
            ),
        ],
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
        label: Text(_isNavigating ? 'End Safe Navigation Session' : 'Start Real Safe Navigation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isNavigating ? AppColors.safetyPink : AppColors.emeraldGreen,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, DesignTokens.buttonHeightLg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        ),
      ),
    );
  }

  // ── OpenStreetMap Nominatim Live Search Modal ──────────────────────────────

  void _showRealSearchModal(BuildContext context) {
    final searchCtrl = TextEditingController();
    List<RealLocationResult> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Any Address or Landmark in India',
                    style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Type address (e.g. Indiranagar, Connaught Place, BKC)...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: isSearching ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (query) async {
                      if (query.length < 3) return;
                      setModalState(() => isSearching = true);
                      final results = await RealRoutingService.searchRealLocations(query);
                      setModalState(() {
                        searchResults = results;
                        isSearching = false;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final item = searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on_rounded, color: AppColors.emeraldGreen),
                          title: Text(item.displayName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                          onTap: () {
                            setState(() {
                              _destCtrl.text = item.displayName;
                              _destLat = item.lat;
                              _destLng = item.lng;
                            });
                            Navigator.pop(ctx);
                            _recalculateRealRoutes();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── OpenStreetMap Cartographic Tile Engine & Road Polyline Renderer ────────────

class _RealOsmInteractiveMap extends StatelessWidget {
  const _RealOsmInteractiveMap({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.selectedRoute,
    required this.isNavigating,
    required this.routeData,
    required this.onRecenter,
    required this.onSelectRoute,
  });

  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final int selectedRoute;
  final bool isNavigating;
  final RealRouteData? routeData;
  final VoidCallback onRecenter;
  final ValueChanged<int> onSelectRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEE9),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            final coords = routeData?.geoCoordinates ?? [];

            // Center lat/lng
            final centerLat = (originLat + destLat) / 2;
            final centerLng = (originLng + destLng) / 2;

            // Zoom calculation
            double minLat = originLat < destLat ? originLat : destLat;
            double maxLat = originLat > destLat ? originLat : destLat;
            double minLng = originLng < destLng ? originLng : destLng;
            double maxLng = originLng > destLng ? originLng : destLng;

            for (final pt in coords) {
              if (pt[0] < minLat) minLat = pt[0];
              if (pt[0] > maxLat) maxLat = pt[0];
              if (pt[1] < minLng) minLng = pt[1];
              if (pt[1] > maxLng) maxLng = pt[1];
            }

            final latDiff = (maxLat - minLat).abs();
            final lngDiff = (maxLng - minLng).abs();
            final maxSpan = math.max(latDiff, lngDiff);

            int zoom = 13;
            if (maxSpan > 0.4) {
              zoom = 10;
            } else if (maxSpan > 0.2) {
              zoom = 11;
            } else if (maxSpan > 0.08) {
              zoom = 12;
            } else if (maxSpan > 0.03) {
              zoom = 13;
            } else if (maxSpan > 0.01) {
              zoom = 14;
            } else {
              zoom = 15;
            }

            // Mercator projection helpers
            double lngToPx(double lng) {
              final n = math.pow(2.0, zoom);
              return ((lng + 180.0) / 360.0) * 256.0 * n;
            }

            double latToPx(double lat) {
              final rad = lat * math.pi / 180.0;
              final n = math.pow(2.0, zoom);
              return (1.0 - (math.log(math.tan(rad) + (1.0 / math.cos(rad))) / math.pi)) / 2.0 * 256.0 * n;
            }

            final centerPxX = lngToPx(centerLng);
            final centerPxY = latToPx(centerLat);

            Offset toOffset(double lat, double lng) {
              final x = w / 2 + (lngToPx(lng) - centerPxX);
              final y = h / 2 + (latToPx(lat) - centerPxY);
              return Offset(x, y);
            }

            // OpenStreetMap tile math
            final numTiles = math.pow(2, zoom).toInt();
            final centerTileX = ((centerLng + 180.0) / 360.0 * numTiles).floor();
            final latRad = centerLat * math.pi / 180.0;
            final centerTileY = ((1.0 - (math.log(math.tan(latRad) + (1.0 / math.cos(latRad))) / math.pi)) / 2.0 * numTiles).floor();

            List<Widget> tileWidgets = [];
            for (int dx = -2; dx <= 2; dx++) {
              for (int dy = -2; dy <= 2; dy++) {
                final tx = (centerTileX + dx) % numTiles;
                final ty = centerTileY + dy;
                if (ty < 0 || ty >= numTiles) continue;

                final tileGlobalX = (centerTileX + dx) * 256.0;
                final tileGlobalY = (centerTileY + dy) * 256.0;

                final tileScreenX = w / 2 + (tileGlobalX - centerPxX);
                final tileScreenY = h / 2 + (tileGlobalY - centerPxY);

                final tileUrl = 'https://tile.openstreetmap.org/$zoom/$tx/$ty.png';

                tileWidgets.add(
                  Positioned(
                    left: tileScreenX,
                    top: tileScreenY,
                    width: 256,
                    height: 256,
                    child: Image.network(
                      tileUrl,
                      headers: const {'User-Agent': 'GuardianPlusSafetyApp/1.0'},
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE5EEE9),
                          child: const Center(
                            child: Icon(Icons.map_outlined, color: Colors.black26),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            }

            final originOffset = toOffset(originLat, originLng);
            final destOffset = toOffset(destLat, destLng);

            return Stack(
              children: [
                // 1. Real OpenStreetMap Cartographic Tile Layer
                ...tileWidgets,

                // 2. Real Road Polyline Drawer (OSRM exact coordinates)
                CustomPaint(
                  size: Size(w, h),
                  painter: _OsmPolylinePainter(
                    coords: coords,
                    toOffset: toOffset,
                    selectedRoute: selectedRoute,
                    isNavigating: isNavigating,
                  ),
                ),

                // 3. Origin Pin (Green Pulse)
                Positioned(
                  left: originOffset.dx - 16,
                  top: originOffset.dy - 32,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.emeraldGreen,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.emeraldGreen, blurRadius: 10)],
                        ),
                        child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 16),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Text(
                          'START',
                          style: GoogleFonts.spaceGrotesk(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.emeraldGreen),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Destination Pin (Pink Badge)
                Positioned(
                  left: destOffset.dx - 16,
                  top: destOffset.dy - 32,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.safetyPink,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.safetyPink, blurRadius: 10)],
                        ),
                        child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Text(
                          'DESTINATION',
                          style: GoogleFonts.spaceGrotesk(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.safetyPink),
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. En-Route Safe Haven Pins
                if (routeData != null && routeData!.safeHavens.isNotEmpty) ...[
                  if (coords.length > 5)
                    Positioned(
                      left: toOffset(coords[coords.length ~/ 3][0], coords[coords.length ~/ 3][1]).dx - 10,
                      top: toOffset(coords[coords.length ~/ 3][0], coords[coords.length ~/ 3][1]).dy - 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cyberBlue, width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_police_rounded, size: 11, color: AppColors.cyberBlue),
                            const SizedBox(width: 3),
                            Text(
                              routeData!.safeHavens[0].name,
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (routeData!.safeHavens.length > 1 && coords.length > 10)
                    Positioned(
                      left: toOffset(coords[(coords.length * 2) ~/ 3][0], coords[(coords.length * 2) ~/ 3][1]).dx - 10,
                      top: toOffset(coords[(coords.length * 2) ~/ 3][0], coords[(coords.length * 2) ~/ 3][1]).dy - 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.emeraldGreen, width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_pharmacy_rounded, size: 11, color: AppColors.emeraldGreen),
                            const SizedBox(width: 3),
                            Text(
                              routeData!.safeHavens[1].name,
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                // 6. Recenter GPS Button
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: onRecenter,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: const Icon(Icons.my_location_rounded, color: AppColors.emeraldGreen, size: 20),
                    ),
                  ),
                ),

                // 7. OpenStreetMap Watermark / Attribution
                Positioned(
                  right: 8,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '© OpenStreetMap contributors',
                      style: GoogleFonts.inter(fontSize: 8.5, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OsmPolylinePainter extends CustomPainter {
  const _OsmPolylinePainter({
    required this.coords,
    required this.toOffset,
    required this.selectedRoute,
    required this.isNavigating,
  });

  final List<List<double>> coords;
  final Offset Function(double lat, double lng) toOffset;
  final int selectedRoute;
  final bool isNavigating;

  @override
  void paint(Canvas canvas, Size size) {
    if (coords.isEmpty) return;

    final points = coords.map((c) => toOffset(c[0], c[1])).toList();

    // 1. Path Glow
    final glowPaint = Paint()
      ..color = (selectedRoute == 0 ? AppColors.emeraldGreen : AppColors.warningAmber).withValues(alpha: 0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, glowPaint);

    // 2. Main Road Polyline
    final polylinePaint = Paint()
      ..color = selectedRoute == 0 ? AppColors.emeraldGreen : AppColors.warningAmber
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, polylinePaint);

    // 3. Waypoint dots along the actual turns
    final dotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < points.length; i += math.max(1, (points.length / 8).round())) {
      canvas.drawCircle(points[i], 3, dotPaint);
    }

    // 4. Navigation vehicle/user indicator moving along the exact polyline
    if (isNavigating && points.isNotEmpty) {
      final navIndex = (points.length * 0.4).round().clamp(0, points.length - 1);
      final navPos = points[navIndex];

      final navGlow = Paint()..color = AppColors.emeraldGreen.withValues(alpha: 0.35);
      final navDot = Paint()..color = AppColors.emeraldGreen;
      final navCore = Paint()..color = Colors.white;

      canvas.drawCircle(navPos, 14, navGlow);
      canvas.drawCircle(navPos, 8, navDot);
      canvas.drawCircle(navPos, 4, navCore);
    }
  }

  @override
  bool shouldRepaint(covariant _OsmPolylinePainter oldDelegate) => true;
}

