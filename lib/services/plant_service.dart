import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/plant_model.dart';
import '../models/plant_journal_entry.dart';
import 'mock_data.dart';

class PlantService extends ChangeNotifier {
  static final PlantService _instance = PlantService._internal();
  factory PlantService() => _instance;
  PlantService._internal();
  List<PlantModel> _plants = [];
  StreamSubscription? _subscription;
  String? _uid;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<PlantModel> get plants => _plants
      .where(
        (p) =>
            (p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.scientificName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                )) &&
            (_selectedCategory == 'All' ||
                _selectedCategory != 'Favorites' ||
                p.isFavorite) &&
            (_selectedCategory != 'Easy Care' ||
                p.careLevel.toLowerCase() == 'easy'),
      )
      .toList();
  List<PlantModel> get allPlants => List.unmodifiable(_plants);
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  void bindToUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();

    if (uid == dummyUser.id) {
      _plants = activeDummyPlants;
      notifyListeners();
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('plants')
        .snapshots()
        .listen((s) {
          _plants = s.docs.map((d) => _fromMap(d.id, d.data())).toList();
          notifyListeners();
        }, onError: (e) {
          if (_plants.isEmpty) {
            _plants = List.from(dummyPlants);
            notifyListeners();
          }
        });
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _uid = null;
    _plants = [];
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategory(String c) {
    _selectedCategory = c;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _plants.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final updated = _plants[idx].copyWith(isFavorite: !_plants[idx].isFavorite);
      _plants[idx] = updated;
      notifyListeners();
    }
    if (_uid != null && _uid != dummyUser.id) {
      await _update(id, {
        'isFavorite': _plants.firstWhere((p) => p.id == id).isFavorite,
      });
    }
  }

  Future<void> addPlant(PlantModel p) async {
    if (_uid == dummyUser.id) {
      _plants.insert(0, p);
      notifyListeners();
      return;
    }
    if (_uid != null) await _collection.doc(p.id).set(_toMap(p));
  }

  Future<void> updatePlant(PlantModel p) async {
    final idx = _plants.indexWhere((item) => item.id == p.id);
    if (idx != -1) {
      _plants[idx] = p;
      notifyListeners();
    }
    if (_uid != null && _uid != dummyUser.id) await _collection.doc(p.id).set(_toMap(p));
  }

  /// Permanently removes this plant from the signed-in user's collection.
  Future<void> deletePlant(String id) async {
    _plants.removeWhere((p) => p.id == id);
    notifyListeners();
    if (_uid != null && _uid != dummyUser.id) await _collection.doc(id).delete();
  }

  Future<void> markWatered(String id) async {
    final now = DateTime.now();
    final idx = _plants.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final plant = _plants[idx];
      final newDates = List<String>.from(plant.careActivityDates)..add(_dateKey(now));
      _plants[idx] = plant.copyWith(
        lastWatered: now,
        careActivityDates: newDates,
      );
      notifyListeners();
    }
    if (_uid != null && _uid != dummyUser.id) {
      await _update(id, {
        'lastWatered': Timestamp.fromDate(now),
        'careActivityDates': FieldValue.arrayUnion([_dateKey(now)]),
      });
    }
  }

  Future<void> _update(String id, Map<String, dynamic> m) async {
    if (_uid != null) await _collection.doc(id).update(m);
  }

  CollectionReference<Map<String, dynamic>> get _collection => FirebaseFirestore
      .instance
      .collection('users')
      .doc(_uid)
      .collection('plants');
}

Map<String, dynamic> _toMap(PlantModel p) => {
  'name': p.name,
  'scientificName': p.scientificName,
  'description': p.description,
  'imageUrl': p.imageUrl,
  'careLevel': p.careLevel,
  'wateringFrequencyDays': p.wateringFrequencyDays,
  'sunlight': p.sunlight,
  'temperature': p.temperature,
  'soilType': p.soilType,
  'lastWatered': Timestamp.fromDate(p.lastWatered),
  'careActivityDates': p.careActivityDates,
  'journalEntries': p.journalEntries.map((entry) => entry.toMap()).toList(),
  'isFavorite': p.isFavorite,
  'customNotes': p.customNotes,
  'matchConfidence': p.matchConfidence,
};
PlantModel _fromMap(String id, Map<String, dynamic> d) => PlantModel(
  id: id,
  name: d['name'] ?? '',
  scientificName: d['scientificName'] ?? '',
  description: d['description'] ?? '',
  imageUrl: d['imageUrl'] ?? '',
  careLevel: d['careLevel'] ?? 'Medium',
  wateringFrequencyDays: (d['wateringFrequencyDays'] as num?)?.toInt() ?? 7,
  sunlight: d['sunlight'] ?? '',
  temperature: d['temperature'] ?? '',
  soilType: d['soilType'] ?? '',
  lastWatered: (d['lastWatered'] as Timestamp?)?.toDate() ?? DateTime.now(),
  careActivityDates: List<String>.from(d['careActivityDates'] ?? const []),
  journalEntries: (d['journalEntries'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(PlantJournalEntry.fromMap)
      .toList(),
  isFavorite: d['isFavorite'] ?? false,
  customNotes: d['customNotes'] ?? '',
  matchConfidence: (d['matchConfidence'] as num?)?.toDouble() ?? 0,
);

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
