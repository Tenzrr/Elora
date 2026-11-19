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

/// Notifier managing the currently selected farming location name.
class SelectedLocationNotifier extends Notifier<String> {
  @override
  String build() => 'Colombo';

  void setLocation(String location) {
    state = location;
  }
}

/// Holds the currently selected farming location name.
final selectedLocationProvider =
    NotifierProvider<SelectedLocationNotifier, String>(
  SelectedLocationNotifier.new,
);

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
