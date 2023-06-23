class GlucoseReading {
  final double value;
  final DateTime dateTime;

  GlucoseReading({required this.value, required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory GlucoseReading.fromMap(Map<String, dynamic> map) {
    return GlucoseReading(
      value: map['value'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}
