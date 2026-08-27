import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_detector/data/models/daily_step_record.dart';
import 'package:step_detector/data/models/workout_session.dart';



class ActivityController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<WorkoutSession> _workoutHistory = [];
  List<DailyStepRecord> _monthlyStepHistory = [];

  DailyStepRecord? _todayRecord;

  List<WorkoutSession> get workoutHistory => _workoutHistory;
  List<DailyStepRecord> get monthlyStepHistory => _monthlyStepHistory;
  DailyStepRecord? get todayRecord => _todayRecord;

  String get _todayDocId => DateFormat('yyyy-MM-dd').format(DateTime.now());


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
          .limit(20)
          .get();

      _workoutHistory = snapshot.docs
          .map((doc) => WorkoutSession.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
    }
  }


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
        _todayRecord = DailyStepRecord(
          date: DateTime.now(),
          steps: 0,
          distance: 0.0,
          calories: 0.0,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching today\'s record: $e');
    }
  }

  Future<void> updateTodaySteps(
    int steps,
    double distance,
    double calories,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final record = DailyStepRecord(
      date: DateTime.now(),
      steps: steps,
      distance: distance,
      calories: calories,
    );

    _todayRecord = record;
    notifyListeners();

    try {
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

