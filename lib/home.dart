import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SmartConfigScreen extends StatefulWidget {
  @override
  _SmartConfigScreenState createState() => _SmartConfigScreenState();
}

class _SmartConfigScreenState extends State<SmartConfigScreen> {
  String ssid = 'Chưa lấy SSID';
  String bssid = 'Chưa lấy BSSID';
  String statusMessage = 'Chưa kết nối';
  String password = '';
  bool isConfigInProgress = false;
  bool isLoading = false;
  Map<String, dynamic>? deviceInfo;

  @override
  void initState() {
    super.initState();
    _checkLocationService();
    _loadDeviceInfo();
  }

  /// Kiểm tra và bật dịch vụ định vị
  Future<void> _checkLocationService() async {
    bool isLocationEnabled = await Permission.location.isGranted;

    if (!isLocationEnabled) {
      PermissionStatus locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        setState(() {
          statusMessage = 'Yêu cầu bật quyền định vị để lấy thông tin Wi-Fi.';
        });
        return;
      }
    }

    _getWiFiInfo(); // Lấy thông tin Wi-Fi sau khi quyền được cấp
  }

  /// Lấy thông tin SSID và BSSID của mạng Wi-Fi
  Future<void> _getWiFiInfo() async {
    try {
      String wifiSsid = await WifiInfo().getWifiName() ?? 'Không có SSID';
      String wifiBssid = await WifiInfo().getWifiBSSID() ?? 'Không có BSSID';

      setState(() {
        ssid = wifiSsid;
        bssid = wifiBssid;
        statusMessage = 'Wi-Fi nhận diện thành công.';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Lỗi khi lấy thông tin Wi-Fi: $e';
      });
    }
  }

  /// Lấy thông tin thiết bị từ SharedPreferences
  Future<void> _loadDeviceInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceInfoJson = prefs.getString('deviceInfo');

    if (deviceInfoJson != null) {
      try {
        setState(() {
          deviceInfo = jsonDecode(deviceInfoJson);
        });
      } catch (e) {
        setState(() {
          statusMessage = 'Lỗi khi giải mã dữ liệu thiết bị: $e';
        });
      }
    } else {
      setState(() {
        statusMessage = 'Không có thông tin thiết bị lưu trữ.';
      });
    }
  }

  /// Lấy thông tin thiết bị từ API và lưu vào SharedPreferences
  Future<void> _getDeviceInfo(String ipAddress) async {
    setState(() {
      isLoading = true;
      statusMessage = 'Đang tải thông tin thiết bị...';
    });

    try {
      final response = await http.get(Uri.parse('http://${ipAddress}/device'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveDeviceInfo(data);
        setState(() {
          deviceInfo = data;
          statusMessage = 'Tải thiết bị thành công.';
        });
      } else {
        setState(() {
          statusMessage = 'Lỗi từ server: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Lỗi khi kết nối thiết bị: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Lưu thông tin thiết bị vào SharedPreferences
  Future<void> _saveDeviceInfo(Map<String, dynamic> deviceInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString('deviceInfo', jsonEncode(deviceInfo));
    if (!success) {
      setState(() {
        statusMessage = 'Lỗi khi lưu thông tin thiết bị.';
      });
    } else {
      print('Thông tin thiết bị đã được lưu thành công!');
    }
  }

  /// Thực hiện SmartConfig
  Future<void> _startSmartConfig() async {
    if (isConfigInProgress) {
      return;
    }

    if (ssid.isNotEmpty && bssid.isNotEmpty) {
      final provisioner = Provisioner.espTouch();

      setState(() {
        isConfigInProgress = true;
        statusMessage = 'Đang thực hiện SmartConfig...';
      });

      provisioner.listen((response) {
        setState(() {
          statusMessage = 'Đã nhận phản hồi từ thiết bị: ${response.ipAddress}';
        });
        _getDeviceInfo(response.ipAddress!.join('.'));
      });

      try {
        await provisioner.start(ProvisioningRequest.fromStrings(
          ssid: ssid,
          bssid: bssid,
          password: password,
        ));

        setState(() {
          statusMessage = 'SmartConfig đang chạy...';
        });
        await Future.delayed(Duration(seconds: 60));
      } catch (e) {
        setState(() {
          statusMessage = 'SmartConfig thất bại: $e';
        });
      } finally {
        provisioner.stop();
        setState(() {
          isConfigInProgress = false;
        });
      }
    } else {
      setState(() {
        statusMessage = 'Thông tin Wi-Fi hoặc mật khẩu không hợp lệ!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartConfig ESP32'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('SSID: $ssid', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('BSSID: $bssid', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Nhập mật khẩu Wi-Fi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConfigInProgress ? null : _startSmartConfig,
              child: Text(isConfigInProgress ? "Đang cấu hình..." : "Bắt đầu SmartConfig"),
            ),
            SizedBox(height: 20),
            Text('Trạng thái: $statusMessage', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (deviceInfo != null) ...[
              Text('Thông tin thiết bị:', style: TextStyle(fontSize: 18)),
              Text(deviceInfo.toString(), style: TextStyle(fontSize: 16)),
            ],
            if (isLoading) ...[
              CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
