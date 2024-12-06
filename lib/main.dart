import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home.dart'; // Import SmartConfigScreen
import 'device.dart'; // Import DeviceScreen

void main() {
  // await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartConfig Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chính'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(30),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SmartConfigScreen()),
                );
              },
              child: Text(
                '+',
                style: TextStyle(fontSize: 40),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeviceInfoScreen()),
                );
              },
              child: Text('Xem thông tin thiết bị'),
            ),
          ],
        ),
      ),
    );
  }
}
