import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'schedule_list_page.dart';
import 'schedule.dart'; // Import model Schedule
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulePage extends StatefulWidget {
  final String productId;

  SchedulePage({required this.productId});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<bool> _selectedDays = [false, false, true, false, false, false, false];
  bool _isOn = false; // Trạng thái BẬT/TẮT
  List<bool> _relaySelections = [true, true, true];
  List<Schedule> _schedules = []; // Danh sách lịch trình lưu cục bộ

  Future<void> addSchedule(Schedule newSchedule) async {
    try {
      // Gửi yêu cầu POST
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/v1/schedules'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(convertScheduleToTaskData(newSchedule)),
      );

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Add Schedule thành công: ${response.body}');
      } else {
        print(
            'Add Schedule thất bại: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi gửi yêu cầu: $e');
    }
  }

  Map<String,String> convertScheduleToTaskData(Schedule schedule) {
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
    return  {'productId': widget.productId ,'time': time, 'code': codeString};
  }

  bool selectedDayCheck(List<bool> days){
    for (int i = 0;i < days.length ;i ++){
      if (days[i] == true ){
        return true;
      }
    }
    return false;
  }
  // Hàm lưu lịch trình
  void _saveSchedule() {
    final newSchedule = Schedule(
      time: _selectedTime.format(context),
      days: _selectedDays,
      action: _isOn ? 'on' : 'off', // Hành động
      isOn: true, // Trạng thái mặc định là TẮT
      relays: _relaySelections,
      isOnAction: selectedDayCheck(_selectedDays), // Giả lập giá trị
    );
    addSchedule(newSchedule);
    // Thêm lịch trình vào danh sách
    setState(() {
      _schedules.add(newSchedule);
    });

    // Hiển thị thông báo lưu thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lịch trình đã được lưu thành công!')),
    );

    // Chuyển hướng đến trang danh sách lịch trình
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleListPage(productId: widget.productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Thêm Lịch Trình'),
        actions: [
          TextButton(
            onPressed: _saveSchedule,
            child: Text(
              'Lưu',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Hủy',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedTime.period == DayPeriod.am ? 'SA' : 'CH',
                    style: TextStyle(fontSize: 32),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '${_selectedTime.hourOfPeriod.toString().padLeft(2, '0')} : ${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 32),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedTime = pickedTime;
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Repeat Day Selection
              Text('Lặp lại vào các ngày'),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: List.generate(7, (index) {
                  return ChoiceChip(
                    label: Text(
                      ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][index],
                    ),
                    selected: _selectedDays[index],
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedDays[index] = selected;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),
              // Action ON/OFF
              Text('Hành động'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text('BẬT'),
                    selected: _isOn,
                    onSelected: (bool selected) {
                      setState(() {
                        _isOn = true;
                      });
                    },
                  ),
                  SizedBox(width: 20),
                  ChoiceChip(
                    label: Text('TẮT'),
                    selected: !_isOn,
                    onSelected: (bool selected) {
                      setState(() {
                        _isOn = false;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Relay Selection
              Text('Relay'),
              SizedBox(height: 10),
              Column(
                children: List.generate(3, (index) {
                  return CheckboxListTile(
                    title: Text('Relay $index'),
                    value: _relaySelections[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _relaySelections[index] = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
