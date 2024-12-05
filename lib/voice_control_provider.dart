import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class VoiceControlProvider extends ChangeNotifier {
  bool _isVoiceControlEnabled = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Hãy nhấn để nói...";
  String? _navigationCommand;
  bool _isCommandProcessed = false;
  Timer? _listeningTimer; // Timer để quản lý thời gian nghe

  bool get isVoiceControlEnabled => _isVoiceControlEnabled;
  bool get isListening => _isListening;
  String get text => _text;
  String? get navigationCommand => _navigationCommand;
  bool get isCommandProcessed => _isCommandProcessed;

  set text(String value) {
    _text = value;
    notifyListeners();
  }

  VoiceControlProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _speech = stt.SpeechToText();
    await _loadVoiceControlStatus();
    if (_isVoiceControlEnabled) {
      await _initializeSpeech();
    }
  }

  Future<void> _loadVoiceControlStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isVoiceControlEnabled = prefs.getBool('voiceControl') ?? false;
    notifyListeners();
  }

  Future<void> toggleVoiceControl(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isVoiceControlEnabled = value;
    await prefs.setBool('voiceControl', value);

    if (_isVoiceControlEnabled) {
      await _initializeSpeech();
    } else {
      stopListening();
    }
    notifyListeners();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = false;
      notifyListeners();
    }
  }

  void startListening() async {
    if (_isVoiceControlEnabled && !_isListening) {
      _isListening = true;
      _text = ""; // Reset text trước khi lắng nghe
      notifyListeners();

      // Bắt đầu lắng nghe và đặt thời gian lắng nghe là 3 giây
      _speech.listen(
        onResult: (result) {
          _text = result.recognizedWords;
          notifyListeners();

          // Xử lý lệnh khi hoàn thành và nhận diện đúng lệnh
          if (result.finalResult && !_isCommandProcessed) {
            print('Nhận được câu lệnh: $_text');
            _processNavigationCommand(_text);
          }
        },
        localeId: 'vi_VN',
      );

      // Dừng lắng nghe sau 3 giây
      _listeningTimer = Timer(Duration(seconds: 5), () {
        stopListening();
      });
    }
  }

  void stopListening() {
    if (_isListening) {
      _isListening = false;
      _speech.stop();
      _listeningTimer?.cancel(); // Hủy bỏ timer nếu vẫn còn
      notifyListeners();
    }
  }

  void _processNavigationCommand(String command) {
    if (_isCommandProcessed) return;

    if (command.contains("lập lịch")) {
      _navigationCommand = 'schedule';
    } else if (command.contains("đếm ngược")) {
      _navigationCommand = 'countdown';
    } else if (command.contains("nhiều hơn")) {
      _navigationCommand = 'moreOptions';
    }

    if (_navigationCommand != null) {
      _isCommandProcessed = true;
      notifyListeners();

      // Thực thi lệnh điều hướng sau khi nhận lệnh và chuyển về trạng thái chờ
      Future.delayed(Duration(seconds: 1), () {
        clearNavigationCommand();
        startListening(); // Trở về trạng thái chờ để nhận lệnh tiếp theo
      });
    }
  }

  void navigateTo(BuildContext context) {
    if (_navigationCommand == 'schedule') {
      Navigator.pushNamed(context, '/schedulePage');
    } else if (_navigationCommand == 'countdown') {
      Navigator.pushNamed(context, '/countdownPage');
    } else if (_navigationCommand == 'moreOptions') {
      Navigator.pushNamed(context, '/moreOptionsPage');
    }
    clearNavigationCommand();
  }

  void clearNavigationCommand() {
    _navigationCommand = null;
    _isCommandProcessed = false;
    notifyListeners();
  }
}
