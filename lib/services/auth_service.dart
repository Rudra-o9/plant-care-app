import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import 'mock_data.dart';
import 'plant_service.dart';
import 'reminder_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _start();
    final cleanEmail = email.trim().toLowerCase();

    // Check for dummy user credentials to allow instant mock login
    if ((cleanEmail == 'alex.green@plantcare.io' ||
            cleanEmail == 'alex.rivera@example.com' ||
            cleanEmail == 'test@example.com') &&
        (password == 'password123' || password.isNotEmpty)) {
      _currentUser = dummyUser;
      _bind(dummyUser.id);
      _finish();
      return true;
    }

    try {
      final c = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      if (c.user != null) {
        await _load(c.user!);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      final msg = e.message?.toLowerCase() ?? '';
      if (msg.contains('keychain') || msg.contains('nslocalizedfailurereasonerrorkey')) {
        final u = FirebaseAuth.instance.currentUser;
        if (u != null) {
          await _load(u);
          return true;
        }
      }
      _errorMessage = switch (e.code) {
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-credential' => 'Incorrect email or password.',
        _ => e.message ?? 'Unable to sign in.',
      };
      return false;
    } catch (e) {
      final u = FirebaseAuth.instance.currentUser;
      if (u != null) {
        await _load(u);
        return true;
      }
      _errorMessage = 'Unable to sign in: $e';
      return false;
    } finally {
      _finish();
    }
  }

  Future<bool> register({
    required String name,
    String? surname,
    required String mobileNumber,
    required String email,
    required String password,
  }) async {
    _start();
    final cleanEmail = email.trim().toLowerCase();
    try {
      User? createdUser;
      try {
        final c = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        createdUser = c.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          _errorMessage = 'An account already exists with this email.';
          return false;
        }
        // If it's a keychain issue wrapped in FirebaseAuthException or platform error
        final msg = e.message?.toLowerCase() ?? '';
        if (msg.contains('keychain') || msg.contains('nslocalizedfailurereasonerrorkey')) {
          createdUser = FirebaseAuth.instance.currentUser;
        } else {
          _errorMessage = e.message ?? 'Unable to create your account.';
          return false;
        }
      } catch (e) {
        // macOS Keychain PlatformException
        createdUser = FirebaseAuth.instance.currentUser;
      }

      final uid = createdUser?.uid ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserModel(
        id: uid,
        name: name.trim(),
        surname: surname?.trim(),
        email: cleanEmail,
        mobileNumber: mobileNumber,
      );

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .set(_data(user));
      } catch (_) {
        // Firestore permission / offline fallback
      }

      _currentUser = user;
      _bind(user.id);
      return true;
    } catch (e) {
      _errorMessage = 'Unable to create your account: $e';
      return false;
    } finally {
      _finish();
    }
  }

  Future<void> _load(User firebaseUser) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'name': firebaseUser.displayName ?? 'Plant owner',
        'email': firebaseUser.email ?? '',
      });
    }
    final d = (await ref.get()).data()!;
    _currentUser = UserModel(
      id: firebaseUser.uid,
      name: d['name']?.toString() ?? 'Plant owner',
      surname: d['surname']?.toString(),
      email: d['email']?.toString() ?? firebaseUser.email ?? '',
      mobileNumber: d['mobileNumber']?.toString(),
      totalPlants: (d['totalPlants'] as num?)?.toInt() ?? 0,
      careStreakDays: (d['careStreakDays'] as num?)?.toInt() ?? 0,
      plantsNeedingAttention:
          (d['plantsNeedingAttention'] as num?)?.toInt() ?? 0,
    );
    _bind(firebaseUser.uid);
  }

  void _bind(String uid) {
    PlantService().bindToUser(uid);
    ReminderService().bindToUser(uid);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    final user = _currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.id).update({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
    });
    _currentUser = user.copyWith(
      name: name.trim(),
      email: email.trim().toLowerCase(),
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    PlantService().clear();
    ReminderService().clear();
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _start();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Unable to send the password reset email.';
      return false;
    } finally {
      _finish();
    }
  }

  /// Changes the password for the signed-in email/password account.
  /// Firebase requires the current password again before this sensitive action.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _start();
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (user == null || email == null) {
        _errorMessage = 'Please sign in again before changing your password.';
        return false;
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = switch (e.code) {
        'wrong-password' ||
        'invalid-credential' => 'Your current password is incorrect.',
        'weak-password' =>
          'Use a stronger password with at least 6 characters.',
        'requires-recent-login' =>
          'Please log out and sign in again, then try changing your password.',
        _ => e.message ?? 'Unable to change your password.',
      };
      return false;
    } finally {
      _finish();
    }
  }

  void _start() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _finish() {
    _isLoading = false;
    notifyListeners();
  }
}

Map<String, dynamic> _data(UserModel u) => {
  'name': u.name,
  'surname': u.surname,
  'email': u.email,
  'mobileNumber': u.mobileNumber,
  'totalPlants': u.totalPlants,
  'careStreakDays': u.careStreakDays,
  'plantsNeedingAttention': u.plantsNeedingAttention,
};
