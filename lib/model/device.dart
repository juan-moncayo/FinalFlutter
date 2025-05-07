class Device {
  final String id;
  final String name;
  final String uniqueCode;
  final String apiKey;
  final String userId;
  final DateTime createdAt;

  Device({
    required this.id,
    required this.name,
    required this.uniqueCode,
    required this.apiKey,
    required this.userId,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? json['id'],
      name: json['name'],
      uniqueCode: json['unique_code'],
      apiKey: json['api_key'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unique_code': uniqueCode,
      'api_key': apiKey,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
