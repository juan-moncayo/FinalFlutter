class Reading {
  final String id;
  final String deviceId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  Reading({
    required this.id,
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'] ?? json['id'],
      deviceId: json['device_id'],
      temperature: double.parse(json['temperature'].toString()),
      humidity: double.parse(json['humidity'].toString()),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
