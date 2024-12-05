import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'voice_control_provider.dart';
import 'schedule_page.dart';
import 'Countdownpage.dart';
import 'more_options_page.dart';

class VoiceControlListener extends StatelessWidget {
  final Widget child;

  VoiceControlListener({required this.child});

  @override
  Widget build(BuildContext context) {
    final voiceControlProvider = Provider.of<VoiceControlProvider>(context);

    // Kiểm tra nếu voice control đang bật và bắt đầu lắng nghe
    if (voiceControlProvider.isVoiceControlEnabled && !voiceControlProvider.isListening) {
      voiceControlProvider.startListening();
    }

    // Điều hướng khi có lệnh, đảm bảo chỉ thực thi một lần duy nhất
    if (voiceControlProvider.navigationCommand != null) {
      Future.microtask(() {
        switch (voiceControlProvider.navigationCommand) {
          case 'schedule':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SchedulePage(productId: "222",)),
            );
            break;
          case 'countdown':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CountdownPage()),
            );
            break;
          case 'moreOptions':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MoreOptionsPage()),
            );
            break;
        }
        voiceControlProvider.clearNavigationCommand(); // Xoá lệnh sau khi thực thi
      });
    }

    return Stack(
      children: [
        child,
        if (voiceControlProvider.isVoiceControlEnabled)
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: voiceControlProvider.isListening
                  ? voiceControlProvider.stopListening
                  : voiceControlProvider.startListening,
              child: Icon(
                voiceControlProvider.isListening ? Icons.stop : Icons.mic,
                size: 50,
                color: voiceControlProvider.isListening ? Colors.red : Colors.blue,
              ),
            ),
          ),
      ],
    );
  }
}
