// lib/services/vaccination_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VaccinationService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static CollectionReference<Map<String, dynamic>> _vaccinationsRef(
      String childId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId)
        .collection('vaccinations');
  }

  /// Fetch all vaccination records for a child as a map of vaccineId → done
  static Future<Map<String, bool>> getVaccinationStatus(
      String childId) async {
    final snapshot = await _vaccinationsRef(childId).get();
    final Map<String, bool> status = {};
    for (final doc in snapshot.docs) {
      status[doc.id] = doc.data()['done'] == true;
    }
    return status;
  }

  /// Mark a vaccine as done or not done
  static Future<void> setVaccineDone(
      String childId, String vaccineId, bool done) async {
    await _vaccinationsRef(childId).doc(vaccineId).set({
      'done': done,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}