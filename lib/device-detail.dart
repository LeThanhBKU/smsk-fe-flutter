import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'schedule_page.dart';
import 'more_options_page.dart';
import 'CountDownPage.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String productId;

  DeviceDetailScreen({required this.productId});

  @override
  _DeviceDetailScreenState createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  List<dynamic> relays = []; // Danh sách relay từ API
  bool isLoading = true; // Trạng thái đang tải
  String errorMessage = ''; // Thông báo lỗi
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _fetchRelays(widget.productId); // Lấy dữ liệu từ API
    _connectWebSocket(); // Kết nối WebSocket
  }

  // Kết nối WebSocket
  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://172.20.10.3:8080/websocket'));

      // Gửi yêu cầu đăng ký sự kiện
      _channel?.sink.add(jsonEncode({
        'event': 'register',
        'productId': '24082000',
        'events': ['notifyRelay'],
      }));

      // Lắng nghe sự kiện từ WebSocket
      _channel?.stream.listen((message) {
        print('Received WebSocket message: $message');
        final data = jsonDecode(message);

        if (data.containsKey('id') && data.containsKey('status')) {
          _updateRelayStatusInUI(data);
        }
      }, onError: (error) {
        print('WebSocket error: $error');
        setState(() {
          errorMessage = 'WebSocket error: $error';
        });
      }, onDone: () {
        print('WebSocket connection closed');
      });
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      setState(() {
        errorMessage = 'Error connecting to WebSocket: $e';
      });
    }
  }

  // Lấy danh sách relay từ API
  Future<void> _fetchRelays(String productId) async {
    try {
      final response =
          await http.get(Uri.parse('http://172.20.10.3:8080/api/v1/relays/$productId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          relays = data ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load relays: ${response.statusCode}';
          isLoading = false;
        });
        print('Failed to load relays: ${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching relays: $e';
        isLoading = false;
      });
      print('Error fetching relays: $e');
    }
  }

  // Cập nhật trạng thái relay qua giao diện
  void _updateRelayStatusInUI(dynamic newRelay) {
    setState(() {
      relays = relays.map((relay) {
        if (relay['id'] == newRelay["id"]) {
          relay['status'] = newRelay["status"] == 1;
        }
        return relay;
      }).toList();
    });
  }

  // Cập nhật trạng thái relay qua API với retry logic
  Future<void> _updateRelayStatus(dynamic relay) async {
    while (true) {
      try {
        // Cập nhật giao diện tạm thời
        // _updateRelayStatusInUI(relay);

        final response = await http.patch(
          Uri.parse('http://172.20.10.3:8080/api/v1/relays/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': relay["id"],
            'status': !relay["status"],
            'deviceId':relay["deviceId"],
            'relayNumber':relay["relayNumber"]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['code'] == 200) {
            // Thành công, dừng vòng lặp
            break;
          } else {
            throw Exception(data['message']);
          }
        } else {
          throw Exception('HTTP error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error updating relay status: $e');
        // Trì hoãn 2 giây trước khi thử lại
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  void dispose() {
    _channel?.sink.close(); // Đóng kết nối WebSocket khi không dùng
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Device Details: ${widget.productId}'),
          backgroundColor: Colors.blue,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                : relays.isEmpty
                    ? Center(child: Text('No relays available'))
                    : SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var relay in relays)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blueAccent,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.flash_on,
                                        color: relay['status']
                                            ? Colors.yellow
                                            : Colors.grey,
                                      ),
                                      iconSize: 80.0,
                                      onPressed: () async {
                                        await _updateRelayStatus( relay);
                                      },
                                    ),
                                  ),
                                ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFeatureButton(
                                    context,
                                    icon: Icons.schedule,
                                    label: 'Lập lịch',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SchedulePage(productId: widget.productId)),
                                      );
                                    },
                                  ),
                                  _buildFeatureButton(
                                    context,
                                    icon: Icons.timer,
                                    label: 'Đếm ngược',
                                    onTap: () {
                                       Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CountdownPage()),
                                      );
                                    },
                                  ),
                                  _buildFeatureButton(
                                    context,
                                    icon: Icons.apps,
                                    label: 'Nhiều hơn',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MoreOptionsPage(productId: widget.productId)),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 40.0, color: Colors.black),
          onPressed: onTap,
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 14.0)),
      ],
    );
  }
}
