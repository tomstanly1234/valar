class GrowthRecord {
  final int ageMonths;
  final double weight;
  final double height;
  final double wfaZ;
  final double hfaZ;
  final double wfhZ;

  GrowthRecord({
    required this.ageMonths,
    required this.weight,
    required this.height,
    required this.wfaZ,
    required this.hfaZ,
    required this.wfhZ,
  });

  Map<String, dynamic> toJson() => {
        "ageMonths": ageMonths,
        "weight": weight,
        "height": height,
        "wfaZ": wfaZ,
        "hfaZ": hfaZ,
        "wfhZ": wfhZ,
      };

  factory GrowthRecord.fromJson(Map<String, dynamic> json) {
    return GrowthRecord(
      ageMonths: json["ageMonths"],
      weight: json["weight"],
      height: json["height"],
      wfaZ: json["wfaZ"],
      hfaZ: json["hfaZ"],
      wfhZ: json["wfhZ"],
    );
  }
}
