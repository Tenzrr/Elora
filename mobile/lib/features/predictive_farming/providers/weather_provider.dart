import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/weather_data.dart';

/// Supported preset locations for manual selection without GPS (REQ-3.1).
const List<String> presetFarmingLocations = [
  'Colombo',
  'Kandy',
  'Gampaha',
  'Jaffna',
  'Matara',
];

/// Holds the currently selected farming location name.
final selectedLocationProvider = StateProvider<String>((ref) => 'Colombo');

/// Asynchronously fetches live weather and explainable advisory for the selected location.
final farmingWeatherProvider =
    FutureProvider<WeatherForecastResponse>((ref) async {
  final api = ref.watch(apiProvider);
  final location = ref.watch(selectedLocationProvider);

  final response = await api.request(
    'GET',
    '/farming/weather?location=$location',
  );

  return WeatherForecastResponse.fromJson(
    Map<String, dynamic>.from(response as Map),
  );
});
