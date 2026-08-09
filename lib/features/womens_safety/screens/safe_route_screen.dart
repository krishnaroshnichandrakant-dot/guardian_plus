import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  State<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen> {
  final _originCtrl = TextEditingController(text: 'Current Location');
  final _destinationCtrl = TextEditingController();

  int _selectedRouteIndex = 0;

  static const _routes = [
    _RouteInfo(
      title: 'Safest Route (Main Roads)',
      distance: '3.4 km',
      estimatedTime: '12 min',
      safetyScore: 94,
      wellLitPercentage: 92,
      openStoresCount: 8,
      policeStationsCount: 1,
    ),
    _RouteInfo(
      title: 'Fastest Route',
      distance: '2.8 km',
      estimatedTime: '9 min',
      safetyScore: 71,
      wellLitPercentage: 65,
      openStoresCount: 3,
      policeStationsCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Safe Route Planner'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search box
          Container(
            padding: const EdgeInsets.all(DesignTokens.screenPadding),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _originCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Start point',
                    prefixIcon: Icon(Icons.my_location_rounded, color: AppColors.cyberBlue),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: _destinationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Where to?',
                    prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.errorRed),
                  ),
                ),
              ],
            ),
          ),

          // Route choices
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.screenPadding),
              itemCount: _routes.length,
              itemBuilder: (context, i) {
                final route = _routes[i];
                final isSelected = _selectedRouteIndex == i;

                return GestureDetector(
                  onTap: () => setState(() => _selectedRouteIndex = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: DesignTokens.spacingMd),
                    padding: const EdgeInsets.all(DesignTokens.screenPadding),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                      border: Border.all(
                        color: isSelected ? AppColors.emeraldGreen : AppColors.outlineVariant,
                        width: isSelected ? 2 : 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                route.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                              ),
                              child: Text(
                                '${route.safetyScore}/100 Safe',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emeraldGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spacingSm),
                        Text(
                          '${route.distance} • ${route.estimatedTime}',
                          style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted),
                        ),
                        const SizedBox(height: DesignTokens.spacingMd),
                        Row(
                          children: [
                            _RouteFeatureChip(
                              icon: Icons.lightbulb_outline_rounded,
                              label: '${route.wellLitPercentage}% Well-lit',
                            ),
                            const SizedBox(width: 8),
                            _RouteFeatureChip(
                              icon: Icons.storefront_rounded,
                              label: '${route.openStoresCount} Open stores',
                            ),
                            const SizedBox(width: 8),
                            if (route.policeStationsCount > 0)
                              _RouteFeatureChip(
                                icon: Icons.local_police_rounded,
                                label: '${route.policeStationsCount} Police stn',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (i * 100).ms, duration: DesignTokens.animNormal),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteInfo {
  const _RouteInfo({
    required this.title,
    required this.distance,
    required this.estimatedTime,
    required this.safetyScore,
    required this.wellLitPercentage,
    required this.openStoresCount,
    required this.policeStationsCount,
  });

  final String title;
  final String distance;
  final String estimatedTime;
  final int safetyScore;
  final int wellLitPercentage;
  final int openStoresCount;
  final int policeStationsCount;
}

class _RouteFeatureChip extends StatelessWidget {
  const _RouteFeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.onSurfaceMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted)),
        ],
      ),
    );
  }
}
