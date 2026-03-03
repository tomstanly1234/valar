import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

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

  /// Add a new child under the current user.
  static Future<void> addChild(String name, String gender) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .add({
      'name': name,
      'gender': gender,
      'createdAt': Timestamp.now(),
    });
  }

  // ── Growth Records ─────────────────────────────────────────────────────────

  /// Save (or overwrite) a growth record for a given month.
  /// Using month as the document ID prevents duplicate entries.
  static Future<void> saveGrowthRecord(
    String childId,
    int month,
    double weight,
    double height,
  ) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId)
        .collection('growthRecords')
        .doc(month.toString())
        .set({
      'month': month,
      'weight': weight,
      'height': height,
      'recordedAt': Timestamp.now(),
    });
  }

  /// Fetch all growth records for a child (one-time read).
  static Future<QuerySnapshot<Map<String, dynamic>>> getGrowthRecords(
    String childId,
  ) async {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('children')
        .doc(childId)
        .collection('growthRecords')
        .get();
  }
}