class Reading {
  final String id;
  final String deviceId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final bool isAlert;

  Reading({
    required this.id,
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    required this.isAlert,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      // Corregido el manejo del ID
      id: json['\$id'] ?? json['id'] ?? '', // Escapamos el $ con \
      deviceId: json['deviceId'],
      temperature: double.parse(json['temperature'].toString()),
      humidity: double.parse(json['humidity'].toString()),
      timestamp: DateTime.parse(json['timestamp']),
      isAlert: json['isAlert'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.toIso8601String(),
      'isAlert': isAlert,
    };
  }
}
