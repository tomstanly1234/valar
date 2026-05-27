// lib/models/vaccine_model.dart
// Full IAP (Indian Academy of Pediatrics) vaccination schedule
// Birth → 18 years (216 months)

class VaccineModel {
  final String id;
  final String name;
  final String fullName;
  final int    dueAtMonth;
  final String dose;
  final String description;
  final String consequence;
  final bool   girlsOnly; // e.g. HPV

  const VaccineModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.dueAtMonth,
    required this.dose,
    required this.description,
    required this.consequence,
    this.girlsOnly = false,
  });
}

// ── Status ─────────────────────────────────────────────────────────────────

enum VaccineStatus { done, overdue, dueNow, upcoming }

VaccineStatus getVaccineStatus({
  required int  childAgeMonths,
  required int  dueAtMonth,
  required bool isDone,
}) {
  if (isDone) return VaccineStatus.done;
  if (childAgeMonths > dueAtMonth) return VaccineStatus.overdue;
  if (childAgeMonths == dueAtMonth) return VaccineStatus.dueNow;
  return VaccineStatus.upcoming;
}

// ── Full IAP Schedule — Birth to 18 Years ─────────────────────────────────

const List<VaccineModel> iapVaccineSchedule = [

  // ════════════════════════════════════════
  // BIRTH (0 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "bcg_0", name: "BCG",
    fullName: "Bacillus Calmette–Guérin",
    dueAtMonth: 0, dose: "Birth Dose",
    description: "Protects against tuberculosis (TB), including TB meningitis and miliary TB.",
    consequence: "Increased risk of severe tuberculosis including TB meningitis which can be fatal in infants. Consult your doctor for catch-up vaccination immediately.",
  ),
  VaccineModel(
    id: "opv_0", name: "OPV 0",
    fullName: "Oral Polio Vaccine — Birth Dose",
    dueAtMonth: 0, dose: "Birth Dose",
    description: "Protects against poliomyelitis which can cause permanent paralysis.",
    consequence: "Unprotected against polio virus. Risk of polio-related paralysis. Consult your doctor immediately.",
  ),
  VaccineModel(
    id: "hepb_1", name: "Hep B 1",
    fullName: "Hepatitis B — Dose 1",
    dueAtMonth: 0, dose: "Dose 1 of 3",
    description: "Protects against Hepatitis B, a serious liver infection that can become chronic and lead to liver cancer.",
    consequence: "Incomplete Hepatitis B protection. Chronic Hepatitis B in infants can lead to liver cirrhosis and cancer in adulthood.",
  ),

  // ════════════════════════════════════════
  // 6 WEEKS (~2 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "dtwp_1", name: "DTwP/DTaP 1",
    fullName: "Diphtheria, Tetanus & Pertussis — Dose 1",
    dueAtMonth: 2, dose: "Dose 1 of 3",
    description: "Protects against diphtheria (throat infection), tetanus (lockjaw), and pertussis (whooping cough).",
    consequence: "Risk of whooping cough which is life-threatening in infants under 6 months. Risk of diphtheria causing airway blockage.",
  ),
  VaccineModel(
    id: "ipv_1", name: "IPV 1",
    fullName: "Inactivated Polio Vaccine — Dose 1",
    dueAtMonth: 2, dose: "Dose 1 of 3",
    description: "Inactivated polio vaccine providing stronger immunity against all three types of poliovirus.",
    consequence: "Incomplete polio protection. Risk of polio infection causing permanent paralysis.",
  ),
  VaccineModel(
    id: "hib_1", name: "Hib 1",
    fullName: "Haemophilus Influenzae type b — Dose 1",
    dueAtMonth: 2, dose: "Dose 1 of 3",
    description: "Protects against Hib bacteria causing meningitis, pneumonia, and epiglottitis.",
    consequence: "Risk of Hib meningitis which can cause brain damage, hearing loss, or death in infants.",
  ),
  VaccineModel(
    id: "hepb_2", name: "Hep B 2",
    fullName: "Hepatitis B — Dose 2",
    dueAtMonth: 2, dose: "Dose 2 of 3",
    description: "Second dose of Hepatitis B vaccine.",
    consequence: "Incomplete Hepatitis B series. Risk of chronic liver infection.",
  ),
  VaccineModel(
    id: "pcv_1", name: "PCV 1",
    fullName: "Pneumococcal Conjugate Vaccine — Dose 1",
    dueAtMonth: 2, dose: "Dose 1 of 3",
    description: "Protects against Streptococcus pneumoniae causing pneumonia, meningitis, and sepsis.",
    consequence: "Risk of pneumococcal meningitis and severe pneumonia — leading cause of death in children under 5.",
  ),
  VaccineModel(
    id: "rotavirus_1", name: "Rotavirus 1",
    fullName: "Rotavirus Vaccine — Dose 1",
    dueAtMonth: 2, dose: "Dose 1 of 3",
    description: "Protects against rotavirus, the most common cause of severe diarrhoea and dehydration in infants.",
    consequence: "Risk of severe rotavirus diarrhoea causing dangerous dehydration. Note: catch-up has a strict age limit.",
  ),

  // ════════════════════════════════════════
  // 10 WEEKS (~3 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "dtwp_2", name: "DTwP/DTaP 2",
    fullName: "Diphtheria, Tetanus & Pertussis — Dose 2",
    dueAtMonth: 3, dose: "Dose 2 of 3",
    description: "Second dose strengthening protection against diphtheria, tetanus, and whooping cough.",
    consequence: "Incomplete DTP protection. Whooping cough remains life-threatening for unvaccinated infants.",
  ),
  VaccineModel(
    id: "ipv_2", name: "IPV 2",
    fullName: "Inactivated Polio Vaccine — Dose 2",
    dueAtMonth: 3, dose: "Dose 2 of 3",
    description: "Second IPV dose building stronger immunity against poliovirus.",
    consequence: "Incomplete polio protection. Continue the series immediately.",
  ),
  VaccineModel(
    id: "hib_2", name: "Hib 2",
    fullName: "Haemophilus Influenzae type b — Dose 2",
    dueAtMonth: 3, dose: "Dose 2 of 3",
    description: "Second dose of Hib vaccine.",
    consequence: "Incomplete Hib protection. Risk of meningitis remains.",
  ),
  VaccineModel(
    id: "rotavirus_2", name: "Rotavirus 2",
    fullName: "Rotavirus Vaccine — Dose 2",
    dueAtMonth: 3, dose: "Dose 2 of 3",
    description: "Second rotavirus dose.",
    consequence: "Incomplete rotavirus protection. High risk of severe diarrhoea and dehydration.",
  ),

  // ════════════════════════════════════════
  // 14 WEEKS (~4 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "dtwp_3", name: "DTwP/DTaP 3",
    fullName: "Diphtheria, Tetanus & Pertussis — Dose 3",
    dueAtMonth: 4, dose: "Dose 3 of 3",
    description: "Third dose completing primary DTP series.",
    consequence: "Primary DTP series incomplete. Significantly reduced protection against whooping cough, diphtheria, and tetanus.",
  ),
  VaccineModel(
    id: "ipv_3", name: "IPV 3",
    fullName: "Inactivated Polio Vaccine — Dose 3",
    dueAtMonth: 4, dose: "Dose 3 of 3",
    description: "Third IPV dose completing primary polio vaccination series.",
    consequence: "Primary polio series incomplete. Risk of polio paralysis.",
  ),
  VaccineModel(
    id: "hib_3", name: "Hib 3",
    fullName: "Haemophilus Influenzae type b — Dose 3",
    dueAtMonth: 4, dose: "Dose 3 of 3",
    description: "Third dose completing primary Hib series.",
    consequence: "Primary Hib series incomplete. Elevated risk of Hib meningitis.",
  ),
  VaccineModel(
    id: "hepb_3", name: "Hep B 3",
    fullName: "Hepatitis B — Dose 3",
    dueAtMonth: 4, dose: "Dose 3 of 3",
    description: "Third and final dose completing Hepatitis B vaccination.",
    consequence: "Hepatitis B series incomplete. Long-term risk of chronic liver disease and liver cancer.",
  ),
  VaccineModel(
    id: "pcv_2", name: "PCV 2",
    fullName: "Pneumococcal Conjugate Vaccine — Dose 2",
    dueAtMonth: 4, dose: "Dose 2 of 3",
    description: "Second PCV dose.",
    consequence: "Incomplete pneumococcal protection. Risk of severe pneumonia and meningitis.",
  ),
  VaccineModel(
    id: "rotavirus_3", name: "Rotavirus 3",
    fullName: "Rotavirus Vaccine — Dose 3",
    dueAtMonth: 4, dose: "Dose 3 of 3",
    description: "Third and final rotavirus dose completing primary series.",
    consequence: "Rotavirus primary series incomplete. Note: this vaccine has a strict age cut-off and may no longer be given after 8 months.",
  ),

  // ════════════════════════════════════════
  // 6 MONTHS
  // ════════════════════════════════════════
  VaccineModel(
    id: "opv_1", name: "OPV 1",
    fullName: "Oral Polio Vaccine — Dose 1",
    dueAtMonth: 6, dose: "Dose 1",
    description: "Oral polio booster reinforcing gut immunity against poliovirus.",
    consequence: "Reduced intestinal immunity against polio.",
  ),
  VaccineModel(
    id: "influenza_1", name: "Influenza 1",
    fullName: "Influenza (Flu) Vaccine — Dose 1",
    dueAtMonth: 6, dose: "Dose 1 of 2 (first year)",
    description: "Protects against seasonal influenza which can cause severe respiratory illness in young children.",
    consequence: "Unprotected against seasonal influenza. Children under 2 are at high risk of flu complications including pneumonia.",
  ),

  // ════════════════════════════════════════
  // 7 MONTHS
  // ════════════════════════════════════════
  VaccineModel(
    id: "influenza_2", name: "Influenza 2",
    fullName: "Influenza Vaccine — Dose 2 (first year only)",
    dueAtMonth: 7, dose: "Dose 2 of 2 (first year)",
    description: "Second influenza dose required only in the first year of flu vaccination.",
    consequence: "Incomplete influenza immunity in first year. Higher risk of severe flu infection.",
  ),

  // ════════════════════════════════════════
  // 9 MONTHS
  // ════════════════════════════════════════
  VaccineModel(
    id: "mmr_1", name: "MMR 1",
    fullName: "Measles, Mumps & Rubella — Dose 1",
    dueAtMonth: 9, dose: "Dose 1 of 2",
    description: "Protects against measles (highly contagious, can cause brain damage), mumps, and rubella.",
    consequence: "Unprotected against measles which is highly contagious and can cause pneumonia, brain damage, and death. Measles outbreaks occur regularly in India.",
  ),
  VaccineModel(
    id: "opv_2", name: "OPV 2",
    fullName: "Oral Polio Vaccine — Dose 2",
    dueAtMonth: 9, dose: "Dose 2",
    description: "Second OPV dose reinforcing intestinal immunity.",
    consequence: "Incomplete oral polio protection.",
  ),

  // ════════════════════════════════════════
  // 12 MONTHS
  // ════════════════════════════════════════
  VaccineModel(
    id: "hepa_1", name: "Hep A 1",
    fullName: "Hepatitis A — Dose 1",
    dueAtMonth: 12, dose: "Dose 1 of 2",
    description: "Protects against Hepatitis A, common in India via contaminated food and water.",
    consequence: "Unprotected against Hepatitis A which is common in India. Can cause severe jaundice and liver failure.",
  ),
  VaccineModel(
    id: "pcv_booster", name: "PCV Booster",
    fullName: "Pneumococcal Conjugate Vaccine — Booster",
    dueAtMonth: 12, dose: "Booster",
    description: "Booster dose to maintain protection against pneumococcal pneumonia and meningitis.",
    consequence: "Waning pneumococcal immunity. Risk of pneumococcal disease increases.",
  ),

  // ════════════════════════════════════════
  // 15 MONTHS
  // ════════════════════════════════════════
  VaccineModel(
    id: "mmr_2", name: "MMR 2",
    fullName: "Measles, Mumps & Rubella — Dose 2",
    dueAtMonth: 15, dose: "Dose 2 of 2",
    description: "Second MMR dose providing long-term immunity. Required for school entry in many states.",
    consequence: "Without second MMR dose, 5–10% of children remain susceptible to measles.",
  ),
  VaccineModel(
    id: "varicella_1", name: "Varicella 1",
    fullName: "Varicella (Chickenpox) Vaccine — Dose 1",
    dueAtMonth: 15, dose: "Dose 1 of 2",
    description: "Protects against chickenpox which can cause severe skin infections, pneumonia, and brain inflammation.",
    consequence: "Unprotected against chickenpox. Also increases risk of shingles later in life.",
  ),

  // ════════════════════════════════════════
  // 16–18 MONTHS
  // ════════════════════════════════════════
  VaccineModel(
    id: "dtwp_b1", name: "DTwP/DTaP B1",
    fullName: "Diphtheria, Tetanus & Pertussis — Booster 1",
    dueAtMonth: 18, dose: "Booster 1",
    description: "First booster as primary series immunity wanes.",
    consequence: "Primary DTP immunity waning. Child becomes increasingly vulnerable to whooping cough and diphtheria.",
  ),
  VaccineModel(
    id: "ipv_b1", name: "IPV B1",
    fullName: "Inactivated Polio Vaccine — Booster 1",
    dueAtMonth: 18, dose: "Booster 1",
    description: "First IPV booster to maintain long-term protection.",
    consequence: "Polio immunity may wane without booster.",
  ),
  VaccineModel(
    id: "hib_b1", name: "Hib B1",
    fullName: "Haemophilus Influenzae type b — Booster 1",
    dueAtMonth: 18, dose: "Booster 1",
    description: "Hib booster to maintain protection against bacterial meningitis beyond infancy.",
    consequence: "Hib immunity declining without booster.",
  ),
  VaccineModel(
    id: "hepa_2", name: "Hep A 2",
    fullName: "Hepatitis A — Dose 2",
    dueAtMonth: 18, dose: "Dose 2 of 2",
    description: "Second and final Hepatitis A dose providing long-term (20+ year) protection.",
    consequence: "Hepatitis A series incomplete. Long-term protection not achieved. Risk from contaminated food/water in India.",
  ),

  // ════════════════════════════════════════
  // 2 YEARS (24 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "typhoid_1", name: "Typhoid",
    fullName: "Typhoid Conjugate Vaccine",
    dueAtMonth: 24, dose: "Dose 1",
    description: "Protects against typhoid fever — a serious bacterial infection endemic in India.",
    consequence: "Unprotected against typhoid which is endemic in India. Can cause severe fever, intestinal perforation, and death if untreated.",
  ),

  // ════════════════════════════════════════
  // 4–5 YEARS (48 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "dtwp_b2", name: "DTwP/DTaP B2",
    fullName: "Diphtheria, Tetanus & Pertussis — Booster 2",
    dueAtMonth: 48, dose: "Booster 2 (pre-school)",
    description: "Pre-school booster before school entry and increased social exposure.",
    consequence: "Without pre-school DTP booster, immunity declines significantly before school age. Required for most school admissions.",
  ),
  VaccineModel(
    id: "opv_3", name: "OPV 3",
    fullName: "Oral Polio Vaccine — Dose 3",
    dueAtMonth: 48, dose: "Dose 3 (pre-school)",
    description: "Pre-school oral polio booster.",
    consequence: "Polio booster missed before school. Administer immediately.",
  ),
  VaccineModel(
    id: "varicella_2", name: "Varicella 2",
    fullName: "Varicella (Chickenpox) Vaccine — Dose 2",
    dueAtMonth: 48, dose: "Dose 2 of 2",
    description: "Second chickenpox dose providing long-term immunity before school entry.",
    consequence: "Without second dose, 15–20% chance of chickenpox despite first dose.",
  ),
  VaccineModel(
    id: "typhoid_b1", name: "Typhoid B1",
    fullName: "Typhoid Vaccine — Booster 1",
    dueAtMonth: 48, dose: "Booster 1",
    description: "Typhoid booster before school entry.",
    consequence: "Waning typhoid immunity. Risk of typhoid fever before school entry.",
  ),

  // ════════════════════════════════════════
  // 10 YEARS (120 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "tdap_10", name: "Tdap/Td",
    fullName: "Tetanus, Diphtheria & Pertussis — Adolescent Booster",
    dueAtMonth: 120, dose: "Adolescent Booster",
    description: "Booster for tetanus, diphtheria, and pertussis at age 10. Protects during adolescence and early adulthood.",
    consequence: "Waning DTP immunity without adolescent booster. Risk of tetanus from injuries and diphtheria increases. Essential before secondary school.",
  ),
  VaccineModel(
    id: "typhoid_b2", name: "Typhoid B2",
    fullName: "Typhoid Vaccine — Booster 2",
    dueAtMonth: 120, dose: "Booster 2",
    description: "Typhoid booster at age 10 — important in India where typhoid is endemic.",
    consequence: "Waning typhoid immunity. Risk of typhoid fever high in school-going children due to food exposure outside home.",
  ),
  VaccineModel(
    id: "hpv_1", name: "HPV 1",
    fullName: "Human Papillomavirus Vaccine — Dose 1",
    dueAtMonth: 120, dose: "Dose 1 of 2–3",
    girlsOnly: true,
    description: "Protects girls against HPV strains causing cervical cancer — the most common cancer in Indian women.",
    consequence: "Unprotected against HPV. Cervical cancer risk significantly higher. Most effective when given before sexual debut. Vaccinate as soon as possible.",
  ),

  // ════════════════════════════════════════
  // 11–12 YEARS (132 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "hpv_2", name: "HPV 2",
    fullName: "Human Papillomavirus Vaccine — Dose 2",
    dueAtMonth: 132, dose: "Dose 2 of 2–3",
    girlsOnly: true,
    description: "Second HPV dose completing the series (2-dose for girls vaccinated at 9–14 years).",
    consequence: "Incomplete HPV protection. Cervical cancer risk remains elevated without completing the series.",
  ),
  VaccineModel(
    id: "meningococcal", name: "Meningococcal",
    fullName: "Meningococcal Vaccine",
    dueAtMonth: 132, dose: "Dose 1",
    description: "Protects against meningococcal meningitis — a rare but rapidly fatal bacterial infection of the brain lining.",
    consequence: "Unprotected against meningococcal disease which can kill within 24 hours. Risk increases in adolescents in crowded settings.",
  ),

  // ════════════════════════════════════════
  // 15–18 YEARS (180–216 months)
  // ════════════════════════════════════════
  VaccineModel(
    id: "td_booster", name: "Td Booster",
    fullName: "Tetanus & Diphtheria — Booster",
    dueAtMonth: 180, dose: "Booster (15 years)",
    description: "Tetanus and diphtheria booster at age 15. Required every 10 years throughout adulthood.",
    consequence: "Waning tetanus immunity. Any injury can become life-threatening if tetanus protection is absent. Administer immediately.",
  ),
  VaccineModel(
    id: "hpv_3", name: "HPV 3",
    fullName: "Human Papillomavirus Vaccine — Dose 3",
    dueAtMonth: 180, dose: "Dose 3 (if 3-dose schedule)",
    girlsOnly: true,
    description: "Third HPV dose required if vaccination started after age 15.",
    consequence: "Incomplete HPV protection if 3-dose schedule was started late. Cervical cancer risk remains.",
  ),
  VaccineModel(
    id: "typhoid_b3", name: "Typhoid B3",
    fullName: "Typhoid Vaccine — Booster 3",
    dueAtMonth: 192, dose: "Booster 3 (16 years)",
    description: "Typhoid booster at 16 years — required every 3 years in endemic areas like India.",
    consequence: "Waning typhoid protection. Risk of typhoid fever high in teenagers and young adults.",
  ),
  VaccineModel(
    id: "meningococcal_b", name: "Meningococcal B",
    fullName: "Meningococcal Vaccine — Booster",
    dueAtMonth: 204, dose: "Booster (17 years)",
    description: "Meningococcal booster before adulthood and college/hostel entry where risk is elevated.",
    consequence: "Waning meningococcal immunity. Risk highest in hostel/dormitory settings. Administer before leaving for college.",
  ),
];

// ── Helpers ────────────────────────────────────────────────────────────────

Map<int, List<VaccineModel>> vaccinesByAge(String gender) {
  final Map<int, List<VaccineModel>> grouped = {};
  for (final v in iapVaccineSchedule) {
    // Skip girls-only vaccines for boys
    if (v.girlsOnly && gender != "Girl") continue;
    grouped.putIfAbsent(v.dueAtMonth, () => []).add(v);
  }
  return Map.fromEntries(
    grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

String ageLabel(int months) {
  if (months == 0)  return "At Birth";
  if (months == 2)  return "6 Weeks";
  if (months == 3)  return "10 Weeks";
  if (months == 4)  return "14 Weeks";
  if (months < 12)  return "$months Months";
  if (months == 12) return "12 Months (1 Year)";
  if (months < 24)  return "$months Months";
  if (months == 24) return "2 Years";
  if (months < 60)  return "${months ~/ 12} Years ${months % 12 > 0 ? '${months % 12} Months' : ''}".trim();
  final y = months ~/ 12;
  final m = months % 12;
  if (m == 0) return "$y Years";
  return "$y Years $m Months";
}