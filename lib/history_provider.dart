import 'package:flutter/material.dart';

class HistoryProvider with ChangeNotifier {
  List<String> _history = [];

  List<String> get history => _history;

  void addEvent(String event) {
    _history.add(event);
    notifyListeners(); // Thông báo cho các widget khác về sự thay đổi
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
