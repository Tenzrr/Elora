class WeatherUnits {
  const WeatherUnits({
    this.temperature = '°C',
    this.precipitation = 'mm',
    this.windSpeed = 'km/h',
    this.humidity = '%',
  });

  final String temperature;
  final String precipitation;
  final String windSpeed;
  final String humidity;

  factory WeatherUnits.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WeatherUnits();
    return WeatherUnits(
      temperature: json['temperature'] as String? ?? '°C',
      precipitation: json['precipitation'] as String? ?? 'mm',
      windSpeed: json['wind_speed'] as String? ?? 'km/h',
      humidity: json['humidity'] as String? ?? '%',
    );
  }
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
  });

  final double temperature;
  final int relativeHumidity;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity'] as num).toInt(),
      windSpeed: (json['wind_speed'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
    );
  }
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationSum,
    required this.weatherCode,
    this.precipitationProbabilityMax,
  });

  final String date;
  final double temperatureMax;
  final double temperatureMin;
  final double precipitationSum;
  final int weatherCode;
  final int? precipitationProbabilityMax;

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] as String,
      temperatureMax: (json['temperature_max'] as num).toDouble(),
      temperatureMin: (json['temperature_min'] as num).toDouble(),
      precipitationSum: (json['precipitation_sum'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      precipitationProbabilityMax:
          (json['precipitation_probability_max'] as num?)?.toInt(),
    );
  }
}

class FarmingAdvisory {
  const FarmingAdvisory({
    required this.action,
    required this.title,
    required this.reasoning,
    required this.precipitationExpectedMm,
    required this.thresholdMm,
    this.missingContextNotice,
  });

  final String action;
  final String title;
  final String reasoning;
  final double precipitationExpectedMm;
  final double thresholdMm;
  final String? missingContextNotice;

  factory FarmingAdvisory.fromJson(Map<String, dynamic> json) {
    return FarmingAdvisory(
      action: json['action'] as String? ?? 'NORMAL_WATERING',
      title: json['title'] as String? ?? 'Irrigation Advisory',
      reasoning: json['reasoning'] as String? ?? '',
      precipitationExpectedMm:
          (json['precipitation_expected_mm'] as num?)?.toDouble() ?? 0.0,
      thresholdMm: (json['threshold_mm'] as num?)?.toDouble() ?? 5.0,
      missingContextNotice: json['missing_context_notice'] as String?,
    );
  }
}

class WeatherForecastResponse {
  const WeatherForecastResponse({
    required this.source,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.retrievalTime,
    required this.forecastTime,
    required this.isStale,
    required this.units,
    required this.current,
    required this.daily,
    required this.advisory,
  });

  final String source;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime retrievalTime;
  final DateTime forecastTime;
  final bool isStale;
  final WeatherUnits units;
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final FarmingAdvisory advisory;

  factory WeatherForecastResponse.fromJson(Map<String, dynamic> json) {
    return WeatherForecastResponse(
      source: json['source'] as String? ?? 'Open-Meteo',
      locationName: json['location_name'] as String? ?? 'Colombo',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      retrievalTime: DateTime.parse(json['retrieval_time'] as String),
      forecastTime: DateTime.parse(json['forecast_time'] as String),
      isStale: json['is_stale'] as bool? ?? false,
      units: WeatherUnits.fromJson(json['units'] as Map<String, dynamic>?),
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: (json['daily'] as List<dynamic>)
          .map((item) => DailyForecast.fromJson(item as Map<String, dynamic>))
          .toList(),
      advisory:
          FarmingAdvisory.fromJson(json['advisory'] as Map<String, dynamic>),
    );
  }
}
