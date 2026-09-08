import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Current device area weather model
class DeviceWeather {
  const DeviceWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
    required this.condition,
    required this.emoji,
    required this.areaName,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.isLiveGps,
  });

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;
  final String condition;
  final String emoji;
  final String areaName;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final bool isLiveGps;

  /// Default Amazon rainforest fallback state while loading
  factory DeviceWeather.initial() {
    return DeviceWeather(
      temperature: 28.0,
      feelsLike: 30.0,
      humidity: 78,
      windSpeed: 10.0,
      precipitation: 0.0,
      weatherCode: 1,
      condition: 'Rainforest Ambient',
      emoji: '🌿',
      areaName: 'Detecting Location...',
      latitude: -3.4653,
      longitude: -62.2159,
      lastUpdated: DateTime.now(),
      isLiveGps: false,
    );
  }
}

class WeatherService {
  WeatherService();

  /// Fetches the live device area weather using device GPS + Open-Meteo API
  Future<DeviceWeather> fetchCurrentDeviceWeather() async {
    double lat = 19.0760; // Default fallback latitude
    double lon = 72.8777; // Default fallback longitude
    bool isGps = false;
    String areaName = 'Local Device Area';

    try {
      // 1. Check and request location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 6),
          );
          lat = position.latitude;
          lon = position.longitude;
          isGps = true;
          areaName = 'Live Device Location';
        }
      }
    } catch (_) {
      // Graceful fallback to default/cached coordinates if GPS timed out
    }

    // 2. Fetch live weather from Open-Meteo (free, no API key required)
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&timezone=auto',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>? ?? {};

        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 27.0;
        final feelsLike = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
        final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 70;
        final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 12.0;
        final precip = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
        final code = (current['weather_code'] as num?)?.toInt() ?? 0;

        final weatherInfo = _mapWeatherCode(code);

        // Try to get city name if GPS is active
        if (isGps) {
          areaName = '${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°';
        }

        return DeviceWeather(
          temperature: temp,
          feelsLike: feelsLike,
          humidity: humidity,
          windSpeed: wind,
          precipitation: precip,
          weatherCode: code,
          condition: weatherInfo.condition,
          emoji: weatherInfo.emoji,
          areaName: areaName,
          latitude: lat,
          longitude: lon,
          lastUpdated: DateTime.now(),
          isLiveGps: isGps,
        );
      }
    } catch (_) {
      // Fallback on network error
    }

    return DeviceWeather(
      temperature: 28.5,
      feelsLike: 31.0,
      humidity: 76,
      windSpeed: 11.5,
      precipitation: 0.1,
      weatherCode: 2,
      condition: 'Rainforest Breeze',
      emoji: '🌿',
      areaName: isGps ? 'Device Location' : 'Amazon Forest Mode',
      latitude: lat,
      longitude: lon,
      lastUpdated: DateTime.now(),
      isLiveGps: isGps,
    );
  }

  static ({String condition, String emoji}) _mapWeatherCode(int code) {
    switch (code) {
      case 0:
        return (condition: 'Clear Amazon Sky', emoji: '☀️');
      case 1:
      case 2:
        return (condition: 'Canopy Sun & Clouds', emoji: '⛅');
      case 3:
        return (condition: 'Overcast Forest', emoji: '☁️');
      case 45:
      case 48:
        return (condition: 'Rainforest Mist & Fog', emoji: '🌫️');
      case 51:
      case 53:
      case 55:
        return (condition: 'Tropical Drizzle', emoji: '🌦️');
      case 61:
      case 63:
      case 65:
        return (condition: 'Amazon Showers', emoji: '🌧️');
      case 71:
      case 73:
      case 75:
        return (condition: 'Mountain Snow', emoji: '❄️');
      case 80:
      case 81:
      case 82:
        return (condition: 'Heavy Rainforest Rain', emoji: '🌧️');
      case 95:
      case 96:
      case 99:
        return (condition: 'Amazon Thunderstorm', emoji: '⛈️');
      default:
        return (condition: 'Rainforest Climate', emoji: '🌿');
    }
  }
}
