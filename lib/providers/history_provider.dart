import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/history_entry.dart';

class HistoryProvider extends ChangeNotifier {
  List<HistoryEntry> _entries = [];
  bool _isLoading = true;
  static const String _fileName = 'plant_history.json';

  List<HistoryEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  HistoryProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString) as List;
        
        _entries = jsonData
            .map((item) => HistoryEntry.fromJson(item))
            .toList()
            .where((entry) => entry.imageExists) // Filter out entries with missing images
            .toList();
        
        // Sort by timestamp (newest first)
        _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      final jsonData = _entries.map((entry) => entry.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  Future<void> addEntry(HistoryEntry entry) async {
    _entries.insert(0, entry); // Add to the beginning of the list
    notifyListeners();
    await _saveEntries();
  }

  Future<void> removeEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
    await _saveEntries();
  }

  Future<void> clearHistory() async {
    _entries.clear();
    notifyListeners();
    await _saveEntries();
  }
}
