import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather_cup/models/user_model.dart';
import 'package:weather_cup/models/daily_intake.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User Profile ───────────────────────────────────────────

  Future<void> saveUserProfile(String uid, UserModel user) async {
    await _db.collection('users').doc(uid).set({
      'name': user.name,
      'gender': user.gender,
      'weight': user.weight,
      'height': user.height,
      'wakeTime': user.wakeTime,
      'sleepTime': user.sleepTime,
      'country': user.country,
      'city': user.city,
      'profileSetupComplete': true,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<bool> isProfileSetupComplete(String uid) async {
    final data = await getUserProfile(uid);
    return data?['profileSetupComplete'] == true;
  }

  // ─── Hydration Data ─────────────────────────────────────────

  Future<void> saveHydrationData(String uid, DailyIntake intake) async {
    final dateKey = _formatDate(intake.date);
    await _db
        .collection('users')
        .doc(uid)
        .collection('hydration')
        .doc(dateKey)
        .set(intake.toFirestoreMap(), SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getHydrationData(
      String uid, DateTime date) async {
    final dateKey = _formatDate(date);
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('hydration')
        .doc(dateKey)
        .get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Map<String, dynamic>>> getHydrationHistory(
      String uid, int days) async {
    final results = <Map<String, dynamic>>[];
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final data = await getHydrationData(uid, date);
      if (data != null) results.add(data);
    }
    return results;
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}