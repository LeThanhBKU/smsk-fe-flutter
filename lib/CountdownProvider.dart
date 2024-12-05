import 'dart:async';
import 'package:flutter/material.dart';

class CountdownProvider with ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;

  int get remainingSeconds => _remainingSeconds;

  void startCountdown(int seconds) {
    _remainingSeconds = seconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void cancelCountdown() {
    if (_timer != null) {
      _timer!.cancel();
      _remainingSeconds = 0;
      notifyListeners();
    }
  }
}
