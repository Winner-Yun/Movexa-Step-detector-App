import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:step_detector/data/models/user_settings.dart';

class SettingsController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserSettings _settings = const UserSettings();
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
        _settings = const UserSettings();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _settings = newSettings;
    notifyListeners();

    try {
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

  Future<void> updateStepGoal(int newGoal) async {
    final updated = _settings.copyWith(dailyStepGoal: newGoal);
    await updateSettings(updated);
  }
}
