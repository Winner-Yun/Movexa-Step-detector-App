import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_detector/shared/models/daily_step_record.dart';
import 'package:step_detector/shared/models/workout_session.dart';

// import your models here

class ActivityController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data lists for the History UI
  List<WorkoutSession> _workoutHistory = [];
  List<DailyStepRecord> _monthlyStepHistory = [];

  // Current Day Live Data
  DailyStepRecord? _todayRecord;

  List<WorkoutSession> get workoutHistory => _workoutHistory;
  List<DailyStepRecord> get monthlyStepHistory => _monthlyStepHistory;
  DailyStepRecord? get todayRecord => _todayRecord;

  // Generate a standard date string for document IDs (e.g., "2026-03-24")
  String get _todayDocId => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // --- WORKOUT SESSIONS (History View) ---

  Future<void> saveWorkoutSession(WorkoutSession session) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(session.id)
          .set(session.toMap());

      // Add to local list and update UI
      _workoutHistory.insert(0, session);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving workout: $e');
    }
  }

  Future<void> fetchWorkoutHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('startTime', descending: true)
          .limit(20) // Only get the last 20 for performance
          .get();

      _workoutHistory = snapshot.docs
          .map((doc) => WorkoutSession.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
    }
  }

  // --- DAILY STEPS (Dashboard & Bar Chart) ---

  // Load today's already-saved progress so a restarted app (or a
  // background detector resuming) doesn't reset the count to zero.
  // If no record exists yet (first login, or first time opening the app
  // today), create a zeroed one so the document always exists.
  Future<void> fetchTodayRecord({int dailyGoal = 10000}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .doc(_todayDocId)
          .get();

      if (doc.exists) {
        _todayRecord = DailyStepRecord.fromMap(doc.data()!);
        notifyListeners();
      } else {
        await updateTodaySteps(0, dailyGoal, 0.0, 0.0);
      }
    } catch (e) {
      debugPrint('Error fetching today\'s record: $e');
    }
  }

  // Call this periodically when your pedometer detects steps
  Future<void> updateTodaySteps(
    int steps,
    int target,
    double distance,
    double calories,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final record = DailyStepRecord(
      date: DateTime.now(),
      steps: steps,
      target: target,
      distance: distance,
      calories: calories,
    );

    _todayRecord = record;
    notifyListeners();

    try {
      // Use merge: true so we just overwrite today's stats continuously
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .doc(_todayDocId)
          .set(record.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing steps: $e');
    }
  }

  Future<void> fetchMonthlyStepHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Get date 30 days ago
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .where(
            'date',
            isGreaterThanOrEqualTo: thirtyDaysAgo.millisecondsSinceEpoch,
          )
          .orderBy('date', descending: true)
          .get();

      _monthlyStepHistory = snapshot.docs
          .map((doc) => DailyStepRecord.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching monthly steps: $e');
    }
  }
}
