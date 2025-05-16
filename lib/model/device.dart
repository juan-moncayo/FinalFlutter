class Device {
  final String id;
  final String name;
  final String deviceCode;
  final String apiKey;
  final String userId;
  final String? status;
  final String? location;
  final String? description;
  final String? imageId;
  final DateTime? lastReading;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Device({
    required this.id,
    required this.name,
    required this.deviceCode,
    required this.apiKey,
    required this.userId,
    this.status,
    this.location,
    this.description,
    this.imageId,
    this.lastReading,
    required this.createdAt,
    this.updatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? json['\$id'], // Corregido: Escapar el símbolo $ con \$
      name: json['name'],
      deviceCode: json['deviceCode'],
      apiKey: json['apiKey'],
      userId: json['userId'],
      status: json['status'],
      location: json['location'],
      description: json['description'],
      imageId: json['imageId'],
      lastReading: json['lastReading'] != null
          ? DateTime.parse(json['lastReading'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceCode': deviceCode,
      'apiKey': apiKey,
      'userId': userId,
      'status': status,
      'location': location,
      'description': description,
      'imageId': imageId,
      'lastReading': lastReading?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
