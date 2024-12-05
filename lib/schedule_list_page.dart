import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'schedule.dart'; // Import model Schedule
import 'edit_schedule_page.dart'; // Import trang chỉnh sửa
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleListPage extends StatefulWidget {
  final String productId; // Danh sách lịch trình được truyền từ màn hình khác

  ScheduleListPage({required this.productId}); // Constructor nhận danh sách lịch trình

  @override
  _ScheduleListPageState createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  late List<Schedule> schedules = []; // Danh sách lịch trình trong State
  WebSocketChannel? _channel;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchSchedules();
    _connectWebSocket();
  }

  Map<String, String> convertScheduleToTaskData(Schedule schedule) {
    // Lấy các giá trị từ biến schedule
    String time = schedule.time; // Dữ liệu time
    List<bool> days = schedule.days; // Các ngày trong tuần
    String action = schedule.action; // Hành động "on"/"off"
    bool isOn = schedule.isOn; // Trạng thái
    List<bool> relays = schedule.relays; // Trạng thái các relay
    bool isOnAction = schedule.isOnAction; // Lặp lại hay không

    // Tạo chuỗi code với các giá trị mặc định là '0'
    List<String> code = List.filled(13, '0');

    // Số thứ nhất: Trạng thái isOn (0: inactive, 1: active)
    code[0] = isOn ? '1' : '0';

    // Số thứ hai: Hành động (0: close, 1: open)
    code[1] = action == 'on' ? '1' : '0';

    // Số thứ ba đến năm: Trạng thái các relay (0: not chosen, 1: chosen)
    for (int i = 0; i < 3; i++) {
      code[2 + i] = (i < relays.length && relays[i]) ? '1' : '0';
    }

    // Số thứ sáu: Lặp lại (0: once, 1: weekend)
    code[5] = isOnAction ? '1' : '0';

    // Số thứ bảy đến mười ba: Các ngày trong tuần (0: not chosen, 1: chosen)
    for (int i = 0; i < 7; i++) {
      code[6 + i] = (i < days.length && days[i]) ? '1' : '0';
    }

    // Chuyển code thành chuỗi
    String codeString = code.join('');

    // Kết quả cuối cùng
    return {'productId': widget.productId, 'time': time, 'code': codeString};
  }

  // Hàm chuyển trạng thái ON/OFF của lịch trình
  void _toggleSwitch(int index, bool value) {
    setState(() {
      schedules[index].isOn = value;
      updateSchedule(schedules[index]);
    });
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://172.20.10.3:8080/websocket'));

      // Gửi yêu cầu đăng ký sự kiện
      _channel?.sink.add(jsonEncode({
        'event': 'register',
        'productId': widget.productId,
        'events': ['notifyUpdateSchedule'],
      }));

      // Lắng nghe sự kiện từ WebSocket
      _channel?.stream.listen((message) {
        print('Received WebSocket message: $message');
        final data = jsonDecode(message);

        // Nếu nhận được thông báo về relay, cập nhật lại trạng thái
        if (data.containsKey('id')) {
          setState(() {
            schedules = schedules.map((schedule) {
              if (schedule.id == data['id']) {
                schedule.isOn = !schedule.isOn;
              }
              return schedule;
            }).toList();
          });
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

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      // Gửi yêu cầu PATCH
      final response = await http.patch(
        Uri.parse('http://172.20.10.3:8080/api/v1/schedules/' + (schedule.id ?? "")),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(convertScheduleToTaskData(schedule)),
      );

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Update Schedule thành công: ${response.body}');
      } else {
        print('Update Schedule thất bại: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi gửi yêu cầu: $e');
    }
  }

  // Hàm xóa lịch trình
  void _deleteSchedule(Schedule schedule) {
    deleteSchedule(schedule.id ?? "");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lịch trình đã được xóa thành công!')),
    );
  }

  Future<void> deleteSchedule(String id) async {
    final url = Uri.parse('http://172.20.10.3:8080/api/v1/schedules/' + id);
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          schedules = schedules.where((s) => s.id != id).toList();
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete schedule: $e');
    }
  }

  // Hàm tạo chuỗi hiển thị các ngày được chọn
  String _getDaysString(List<bool> days) {
    const daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> selectedDays = [];
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        selectedDays.add(daysOfWeek[i]);
      }
    }
    return selectedDays.join(', ');
  }

  Schedule convertTaskDataToSchedule(ScheduleG schedules) {
    // Kiểm tra độ dài của code phải đủ 13 ký tự
    if (schedules.code.length != 13) {
      throw ArgumentError('Code phải có độ dài chính xác là 13 ký tự');
    }

    // Tách các giá trị từ chuỗi code
    bool isOn = schedules.code[0] == '1'; // Số thứ nhất: trạng thái (0: inactive, 1: active)
    String action = schedules.code[1] == '1' ? 'on' : 'off'; // Số thứ hai: hành động (0: close, 1: open)

    // Số thứ ba đến năm: trạng thái các relay
    List<bool> relays = [
      schedules.code[2] == '1', // R0
      schedules.code[3] == '1', // R1
      schedules.code[4] == '1', // R2
    ];

    // Số thứ sáu: lặp lại (0: once, 1: weekend)
    bool isOnAction = schedules.code[5] == '1';

    // Số thứ bảy đến mười ba: các ngày trong tuần
    List<bool> days = [
      schedules.code[6] == '1', // Thứ Hai
      schedules.code[7] == '1', // Thứ Ba
      schedules.code[8] == '1', // Thứ Tư
      schedules.code[9] == '1', // Thứ Năm
      schedules.code[10] == '1', // Thứ Sáu
      schedules.code[11] == '1', // Thứ Bảy
      schedules.code[12] == '1', // Chủ Nhật
    ];

    // Tạo đối tượng schedule từ các giá trị
    return Schedule(
        id: schedules.id,
        time: schedules.time,
        days: days,
        action: action,
        isOn: isOn,
        relays: relays,
        isOnAction: isOnAction);
  }

  Future<void> fetchSchedules() async {
    final url = Uri.parse('http://172.20.10.3:8080/api/v1/schedules/' + widget.productId);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> jsonList = json.decode(response.body);
          schedules = jsonList
              .map((json) => convertTaskDataToSchedule(ScheduleG.fromJson(json)))
              .toList();
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch schedules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách lịch trình'),
      ),
      body: schedules.isEmpty
          ? Center(child: Text('Không có lịch trình nào.'))
          : ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return GestureDetector(
                  onTap: () async {
                    // Chuyển đến EditSchedulePage và đợi kết quả
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditSchedulePage(
                            schedule: schedule, productId: widget.productId),
                      ),
                    ).then((result) {
                      fetchSchedules();
                    });
                    if (result == true) {
                      setState(() {}); // Làm mới danh sách nếu có thay đổi
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.time,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _getDaysString(schedule.days),
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              schedule.action == 'on'
                                  ? 'Action: open'
                                  : 'Action: close',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: schedule.isOn,
                              onChanged: (value) {
                                _toggleSwitch(index, value);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteSchedule(schedule);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
