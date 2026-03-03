class GrowthRecord {
  final int month;
  final double weight;
  final double height;

  GrowthRecord({
    required this.month,
    required this.weight,
    required this.height,
  });

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'weight': weight,
      'height': height,
    };
  }

  factory GrowthRecord.fromMap(Map<String, dynamic> map) {
    return GrowthRecord(
      month: (map['month'] as num).toInt(),
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
    );
  }
}