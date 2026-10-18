import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/reminder_model.dart';
import 'mock_data.dart';

class ReminderService extends ChangeNotifier {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();
  List<ReminderModel> _reminders = [];
  StreamSubscription? _subscription;
  String? _uid;
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  List<ReminderModel> get todayReminders => _reminders.where((r) {
    final n = DateTime.now(), d = r.scheduledTime;
    return !r.isCompleted &&
        d.year == n.year &&
        d.month == n.month &&
        d.day == n.day;
  }).toList();
  List<ReminderModel> get upcomingReminders => _reminders
      .where(
        (r) =>
            !r.isCompleted &&
            r.scheduledTime.isAfter(
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                23,
                59,
                59,
              ),
            ),
      )
      .toList();
  List<ReminderModel> get completedReminders =>
      _reminders.where((r) => r.isCompleted).toList();
  void bindToUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();

    if (uid == dummyUser.id) {
      _reminders = activeDummyReminders;
      notifyListeners();
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .snapshots()
        .listen((s) {
          _reminders = s.docs.map((d) => _fromMap(d.id, d.data())).toList();
          notifyListeners();
        }, onError: (_) {
          // ignore or fallback
        });
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _uid = null;
    _reminders = [];
    notifyListeners();
  }

  Future<void> toggleComplete(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final complete = !_reminders[idx].isCompleted;
    _reminders[idx] = _reminders[idx].copyWith(
      isCompleted: complete,
      completedAt: complete ? DateTime.now() : null,
    );
    notifyListeners();
    // Skip Firestore for the offline demo / dummy user
    if (_uid == null || _uid == 'usr_dummy_98765') return;
    await _update(id, {
      'isCompleted': complete,
      'completedAt': complete ? Timestamp.now() : FieldValue.delete(),
    });
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    if (_uid == null || _uid == 'usr_dummy_98765') return;
    await _collection.doc(id).delete();
  }

  /// Removes reminders belonging to a plant that has been deleted.
  Future<void> deleteForPlant(String plantId) async {
    _reminders.removeWhere((r) => r.plantId == plantId);
    notifyListeners();
    if (_uid == null || _uid == 'usr_dummy_98765') return;
    final reminders = await _collection
        .where('plantId', isEqualTo: plantId)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final reminder in reminders.docs) {
      batch.delete(reminder.reference);
    }
    await batch.commit();
  }

  Future<void> addReminder(ReminderModel r) async {
    if (_uid == 'usr_dummy_98765') {
      _reminders.add(r);
      notifyListeners();
      return;
    }
    if (_uid != null) await _collection.doc(r.id).set(_toMap(r));
  }

  Future<void> _update(String id, Map<String, dynamic> m) async {
    if (_uid != null) await _collection.doc(id).update(m);
  }

  CollectionReference<Map<String, dynamic>> get _collection => FirebaseFirestore
      .instance
      .collection('users')
      .doc(_uid)
      .collection('reminders');
}

Map<String, dynamic> _toMap(ReminderModel r) => {
  'plantId': r.plantId,
  'plantName': r.plantName,
  'plantImageUrl': r.plantImageUrl,
  'taskType': r.taskType.name,
  'scheduledTime': Timestamp.fromDate(r.scheduledTime),
  'isCompleted': r.isCompleted,
  if (r.completedAt != null) 'completedAt': Timestamp.fromDate(r.completedAt!),
  'repeatFrequency': r.repeatFrequency,
};
ReminderModel _fromMap(String id, Map<String, dynamic> d) => ReminderModel(
  id: id,
  plantId: d['plantId'] ?? '',
  plantName: d['plantName'] ?? '',
  plantImageUrl: d['plantImageUrl'] ?? '',
  taskType: TaskType.values.firstWhere(
    (t) => t.name == d['taskType'],
    orElse: () => TaskType.watering,
  ),
  scheduledTime: (d['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
  isCompleted: d['isCompleted'] ?? false,
  completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
  repeatFrequency: d['repeatFrequency'] ?? '',
);
