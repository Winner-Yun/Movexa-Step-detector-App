import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:step_detector/data/local/database_helper.dart';
import 'package:step_detector/data/models/user_settings.dart';

class SettingsController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserSettings _settings = const UserSettings();
  final bool _isLoading = false;

  SettingsController() {
    _initLocalSettings();
  }

  Future<void> _initLocalSettings() async {
    final db = DatabaseHelper.instance;
    final isDarkStr = await db.getSetting('darkModeEnabled');
    final lang = await db.getSetting('language');
    final stepGoalStr = await db.getSetting('dailyStepGoal');
    final bgTrackingStr = await db.getSetting('runTrackingInBackground');
    final notifsStr = await db.getSetting('notificationsEnabled');

    final lineSizeStr = await db.getSetting('mapLineSize');
    final markerSizeStr = await db.getSetting('mapMarkerSize');
    final tabModeStr = await db.getSetting('defaultTabMode');

    _settings = _settings.copyWith(
      darkModeEnabled: isDarkStr == 'true',
      language: lang ?? 'km',
      dailyStepGoal: stepGoalStr != null ? int.tryParse(stepGoalStr) : null,
      runTrackingInBackground: bgTrackingStr != null
          ? bgTrackingStr == 'true'
          : null,
      notificationsEnabled: notifsStr != null ? notifsStr == 'true' : null,
      mapLineSize: lineSizeStr != null ? double.tryParse(lineSizeStr) : null,
      mapMarkerSize: markerSizeStr != null ? double.tryParse(markerSizeStr) : null,
      defaultTabMode: tabModeStr != null ? int.tryParse(tabModeStr) : null,
    );
    notifyListeners();
  }

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> fetchSettings() async {
    // Also trigger a local fetch to ensure we have the latest local data
    await _initLocalSettings();

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
        final firestoreSettings = UserSettings.fromMap(doc.data() as Map<String, dynamic>);
        _settings = firestoreSettings.copyWith(
          mapLineSize: _settings.mapLineSize,
          mapMarkerSize: _settings.mapMarkerSize,
          defaultTabMode: _settings.defaultTabMode,
        );
        notifyListeners();
        // Sync fetched firestore settings to local db
        final db = DatabaseHelper.instance;
        await db.saveSetting(
          'darkModeEnabled',
          _settings.darkModeEnabled.toString(),
        );
        await db.saveSetting('language', _settings.language);
        await db.saveSetting(
          'dailyStepGoal',
          _settings.dailyStepGoal.toString(),
        );
        await db.saveSetting(
          'runTrackingInBackground',
          _settings.runTrackingInBackground.toString(),
        );
        await db.saveSetting(
          'notificationsEnabled',
          _settings.notificationsEnabled.toString(),
        );
      } else {
        _settings = UserSettings(
          mapLineSize: _settings.mapLineSize,
          mapMarkerSize: _settings.mapMarkerSize,
          defaultTabMode: _settings.defaultTabMode,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();

    // Save locally
    final db = DatabaseHelper.instance;
    await db.saveSetting(
      'darkModeEnabled',
      newSettings.darkModeEnabled.toString(),
    );
    await db.saveSetting('language', newSettings.language);
    await db.saveSetting('dailyStepGoal', newSettings.dailyStepGoal.toString());
    await db.saveSetting(
      'runTrackingInBackground',
      newSettings.runTrackingInBackground.toString(),
    );
    await db.saveSetting(
      'notificationsEnabled',
      newSettings.notificationsEnabled.toString(),
    );
    await db.saveSetting('mapLineSize', newSettings.mapLineSize.toString());
    await db.saveSetting('mapMarkerSize', newSettings.mapMarkerSize.toString());
    await db.saveSetting('defaultTabMode', newSettings.defaultTabMode.toString());

    final user = _auth.currentUser;
    if (user == null) return;

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
