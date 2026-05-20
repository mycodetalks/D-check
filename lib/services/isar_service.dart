import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  static const String _complaintBoxName = 'complaintDrafts';
  bool _initialized = false;

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_complaintBoxName);
    _initialized = true;
  }

  Future<void> saveComplaintDraft(String draft) async {
    _ensureInitialized();
    final box = Hive.box<String>(_complaintBoxName);
    await box.add(draft);
  }

  Future<String?> loadLatestComplaintDraft() async {
    _ensureInitialized();
    final box = Hive.box<String>(_complaintBoxName);
    if (box.isEmpty) return null;
    return box.getAt(box.length - 1);
  }

  Future<List<String>> loadComplaintDrafts() async {
    _ensureInitialized();
    final box = Hive.box<String>(_complaintBoxName);
    return List.unmodifiable(box.values.toList(growable: false));
  }

  Future<void> clearDrafts() async {
    _ensureInitialized();
    final box = Hive.box<String>(_complaintBoxName);
    await box.clear();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('IsarService has not been initialized.');
    }
  }
}
