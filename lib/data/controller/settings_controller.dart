import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:step_detector/data/models/user_settings.dart';

class SettingsController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserSettings _settings = const UserSettings(); // Default settings
  final bool _isLoading = false;

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> fetchSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('default')
          .get();

      if (doc.exists) {
        _settings = UserSettings.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      } else {
        // First login: persist the defaults so a settings doc always
        // exists for this user, instead of only ever living in memory.
        await updateSettings(const UserSettings());
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _settings = newSettings;
    notifyListeners(); // Update UI immediately for snappy feel

    try {
      // Sync to Firebase in the background
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('default')
          .set(newSettings.toMap());
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Quick helper specifically for the step goal dialog
  Future<void> updateStepGoal(int newGoal) async {
    final updated = _settings.copyWith(dailyStepGoal: newGoal);
    await updateSettings(updated);
  }
}
