import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());

/// Live weather provider that fetches current device area weather
final currentDeviceWeatherProvider =
    AsyncNotifierProvider<DeviceWeatherNotifier, DeviceWeather>(() {
  return DeviceWeatherNotifier();
});

class DeviceWeatherNotifier extends AsyncNotifier<DeviceWeather> {
  @override
  Future<DeviceWeather> build() async {
    final service = ref.read(weatherServiceProvider);
    return await service.fetchCurrentDeviceWeather();
  }

  /// Manually refresh current device area weather
  Future<void> refreshWeather() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(weatherServiceProvider);
      return await service.fetchCurrentDeviceWeather();
    });
  }
}
