import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:step_detector/data/models/user_profile.dart';


class ProfileController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProfile? _currentProfile;
  bool _isLoading = false;

  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _currentProfile = UserProfile.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      } else {
        _currentProfile = UserProfile(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          bio: '',
          age: 0,
          weight: 0,
          height: 0,
          avatarUrl: user.photoURL,
        );
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(user.uid).set(profile.toMap());
      _currentProfile = profile;
      return true;
    } catch (e) {
      debugPrint('Error saving profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
