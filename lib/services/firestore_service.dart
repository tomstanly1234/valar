// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ── Age helper ─────────────────────────────────────────────────────────────

  /// Calculate age in complete months from DOB to today.
  static int ageInMonthsFromDob(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months.clamp(0, 216);
  }

  // ── Children ───────────────────────────────────────────────────────────────

  /// Live stream of the current user's children.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getChildren() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Add a new child. DOB is optional — only used for vaccine tracking.
  static Future<void> addChild(
      String name, String gender, DateTime? dob) async {
    final data = <String, dynamic>{
      'name':      name,
      'gender':    gender,
      'createdAt': Timestamp.now(),
    };
    if (dob != null) data['dob'] = Timestamp.fromDate(dob);
    await _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .add(data);
  }

  /// Update child name, gender and/or DOB.
  static Future<void> updateChild(
      String childId, String name, String gender, DateTime? dob) async {
    final data = <String, dynamic>{
      'name':   name,
      'gender': gender,
    };
    if (dob != null) {
      data['dob'] = Timestamp.fromDate(dob);
    } else {
      data['dob'] = FieldValue.delete();
    }
    await _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId)
        .update(data);
  }

  /// Delete a child and all their sub-collections.
  static Future<void> deleteChild(String childId) async {
    final base = _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId);

    // Delete all growth records
    final records = await base.collection('growthRecords').get();
    for (final doc in records.docs) {
      await doc.reference.delete();
    }

    // Delete all vaccination records
    final vaccinations = await base.collection('vaccinations').get();
    for (final doc in vaccinations.docs) {
      await doc.reference.delete();
    }

    // Delete the child document
    await base.delete();
  }

  // ── Growth Records ─────────────────────────────────────────────────────────

  /// Save (or overwrite) a growth record for a given month.
  static Future<void> saveGrowthRecord(
    String childId,
    int month,
    double weight,
    double height,
  ) async {
    final base = _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId);

    await base.collection('growthRecords').doc(month.toString()).set({
      'month':      month,
      'weight':     weight,
      'height':     height,
      'recordedAt': Timestamp.now(),
    });

    // Keep lastAgeMonths updated as fallback when no DOB is stored
    await base.update({'lastAgeMonths': month});
  }

  /// Update weight and height for an existing growth record.
  static Future<void> updateGrowthRecord(
      String childId, int month, double weight, double height) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId)
        .collection('growthRecords')
        .doc(month.toString())
        .update({
      'weight':     weight,
      'height':     height,
      'recordedAt': Timestamp.now(),
    });
  }

  /// Delete a single growth record by month.
  static Future<void> deleteGrowthRecord(
      String childId, int month) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId)
        .collection('growthRecords')
        .doc(month.toString())
        .delete();
  }

  /// Fetch all growth records for a child (one-time read).
  static Future<QuerySnapshot<Map<String, dynamic>>> getGrowthRecords(
      String childId) async {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId)
        .collection('growthRecords')
        .get();
  }
}