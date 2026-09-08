import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/providers/weather_provider.dart';
import '../../../shared/services/weather_service.dart';

/// Amazon Forest Live Device Weather Card
class AmazonWeatherCard extends ConsumerWidget {
  const AmazonWeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentDeviceWeatherProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradientWeather,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.outlineVariant, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGreen.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background rainforest leaf glow decorative shape
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emeraldGreen.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: weatherAsync.when(
              loading: () => _buildLoadingState(),
              error: (err, _) => _buildWeatherContent(
                context,
                ref,
                DeviceWeather.initial(),
                isError: true,
              ),
              data: (weather) => _buildWeatherContent(context, ref, weather),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.04, end: 0);
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('🌿', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'CURRENT DEVICE AREA WEATHER',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.emeraldGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Connecting to live device GPS...',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherContent(
    BuildContext context,
    WidgetRef ref,
    DeviceWeather weather, {
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Badge & Refresh
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: weather.isLiveGps ? AppColors.emeraldGreen : AppColors.scamAmber,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (weather.isLiveGps ? AppColors.emeraldGreen : AppColors.scamAmber)
                            .withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'DEVICE AREA WEATHER',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighest,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Text(
                    weather.areaName,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.onSurfaceMuted,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref.read(currentDeviceWeatherProvider.notifier).refreshWeather();
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Temperature & Emoji Condition
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${weather.temperature.round()}°',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -1.5,
                height: 1,
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Text(weather.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.condition,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Feels like ${weather.feelsLike.round()}°C • Amazon Forest Mode',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.emeraldGreenLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Metrics Row: Humidity, Wind, Moisture
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('💧 Humidity', '${weather.humidity}%'),
              Container(width: 1, height: 24, color: AppColors.outline),
              _buildMetric('💨 Wind', '${weather.windSpeed.round()} km/h'),
              Container(width: 1, height: 24, color: AppColors.outline),
              _buildMetric('🌧️ Rain', '${weather.precipitation} mm'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
