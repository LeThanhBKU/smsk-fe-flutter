import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'voice_control_provider.dart';

class VoiceControlPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final voiceControlProvider = Provider.of<VoiceControlProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Điều khiển bằng giọng nói'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sử dụng giọng nói để điều khiển',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text(
                voiceControlProvider.isVoiceControlEnabled ? 'Đã bật' : 'Đã tắt',
                style: TextStyle(fontSize: 16),
              ),
              value: voiceControlProvider.isVoiceControlEnabled,
              onChanged: (bool value) {
                voiceControlProvider.toggleVoiceControl(value);
              },
              secondary: Icon(
                voiceControlProvider.isVoiceControlEnabled ? Icons.mic : Icons.mic_off,
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            Text(
              voiceControlProvider.text,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
