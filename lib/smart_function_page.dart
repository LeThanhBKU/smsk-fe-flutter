// smart_function_page.dart
import 'package:flutter/material.dart';
import 'voice_control_page.dart'; // Thêm dòng này để nhập VoiceControlPage

class SmartFunctionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chức năng thông minh'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.mic, size: 40.0),
            title: Text('Điều khiển bằng giọng nói', style: TextStyle(fontSize: 18)),
            onTap: () {
              // Điều hướng đến trang VoiceControlPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VoiceControlPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.child_care, size: 40.0),
            title: Text('Children mode', style: TextStyle(fontSize: 18)),
            onTap: () {
              // Điều hướng hoặc xử lý logic cho Children mode
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SmartSchedulePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Tạo trang SmartSchedulePage
class SmartSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Children mode'),
      ),
      body: Center(
        child: Text('Children mode', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
