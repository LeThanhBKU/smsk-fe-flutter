import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device-detail.dart'; // Import file device-detail.dart đã sửa

class DeviceInfoScreen extends StatefulWidget {
  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  Map<String, dynamic>? deviceInfo;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  // Lấy thông tin thiết bị từ SharedPreferences
  Future<void> _loadDeviceInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceInfoJson = prefs.getString('deviceInfo');

    if (deviceInfoJson != null) {
      setState(() {
        deviceInfo = jsonDecode(deviceInfoJson);
      });
    }
  }

  // Xóa thông tin thiết bị từ SharedPreferences
  Future<void> _deleteDeviceInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('deviceInfo');
    setState(() {
      deviceInfo = null; // Đặt deviceInfo thành null sau khi xóa
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin thiết bị'),
      ),
      body: deviceInfo == null
          ? Center(child: CircularProgressIndicator()) // Đang tải
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin thiết bị:',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 10),
                  _buildDeviceInfoCard(deviceInfo!),
                  SizedBox(height: 20),
                ElevatedButton(
  onPressed: _deleteDeviceInfo,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red, // Correct parameter name
  ),
  child: Text('Xóa thiết bị'),
),
                ],
              ),
            ),
    );
  }

  // Hàm tạo Card hiển thị thông tin thiết bị
  Widget _buildDeviceInfoCard(Map<String, dynamic> deviceInfo) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: deviceInfo.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: GestureDetector(
                onTap: () {
                  // Chuyển hướng tới DeviceDetailScreen khi nhấn vào thiết bị
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceDetailScreen(productId: "24082000"),
                    ),
                  );
                },
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
