import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'schedule.dart'; // Import model Schedule
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditSchedulePage extends StatefulWidget {
  final Schedule schedule;
  final String productId; 

  EditSchedulePage({required this.schedule, required this.productId});

  @override
  _EditSchedulePageState createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  late TimeOfDay _selectedTime;
  late List<bool> _selectedDays;
  late bool _isOn;
  late List<bool> _relaySelections;
  late Schedule _updatedSchedule; 
  bool _isLoading = false;  // Trạng thái để hiển thị loading khi cập nhật

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay(
      hour: int.parse(widget.schedule.time.split(':')[0]),
      minute: int.parse(widget.schedule.time.split(':')[1].split(' ')[0]),
    );
    _selectedDays = List<bool>.from(widget.schedule.days);
    _isOn = widget.schedule.action == "on";
    _relaySelections = List<bool>.from(widget.schedule.relays);
    _updatedSchedule = widget.schedule;
  }

  Map<String, String> convertScheduleToTaskData(Schedule schedule) {
    String time = schedule.time; // Dữ liệu time
    List<bool> days = schedule.days; // Các ngày trong tuần
    String action = schedule.action; // Hành động "on"/"off"
    bool isOn = schedule.isOn; // Trạng thái
    List<bool> relays = schedule.relays; // Trạng thái các relay
    bool isOnAction = schedule.isOnAction; // Lặp lại hay không

    List<String> code = List.filled(13, '0');

    code[0] = isOn ? '1' : '0';
    code[1] = action == 'on' ? '1' : '0';
    for (int i = 0; i < 3; i++) {
      code[2 + i] = (i < relays.length && relays[i]) ? '1' : '0';
    }

    code[5] = isOnAction ? '1' : '0';
    for (int i = 0; i < 7; i++) {
      code[6 + i] = (i < days.length && days[i]) ? '1' : '0';
    }

    String codeString = code.join('');
    return {'productId': widget.productId, 'time': time, 'code': codeString};
  }

  Future<void> updateSchedule(Schedule schedule) async {
    setState(() {
      _isLoading = true;  // Bật trạng thái loading
    });

    try {
      final response = await http.patch(
        Uri.parse(
            '${Config.baseUrl}/api/v1/schedules/' + (schedule.id ?? "")),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(convertScheduleToTaskData(schedule)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Cập nhật thành công: ${response.body}');
      } else {
        print('Cập nhật thất bại: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi gửi yêu cầu: $e');
    }

    setState(() {
      _isLoading = false;  // Tắt trạng thái loading
    });
  }

  void _updateSchedule() {
    final newSchedule = Schedule(
      id: widget.schedule.id,
      time: _selectedTime.format(context),
      days: _selectedDays,
      action: _isOn ? 'on' : 'off', 
      isOn: widget.schedule.isOn,
      relays: _relaySelections,
      isOnAction: true, // Giả lập giá trị
    );

    setState(() {
      _updatedSchedule = newSchedule;
    });

    updateSchedule(newSchedule).then((_) {
      if (_isLoading == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lịch trình đã được cập nhật thành công!')),
        );
        Navigator.pop(context, true); // Trả về true để thông báo có thay đổi
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa Lịch Trình'),
        actions: [
          _isLoading
              ? CircularProgressIndicator() // Hiển thị loading khi đang cập nhật
              : TextButton(
                  onPressed: _updateSchedule,
                  child: Text(
                    'Cập nhật',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        initialTime: _selectedTime,
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
              Text('Lặp lại vào các ngày'),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: List.generate(7, (index) {
                  return ChoiceChip(
                    label:
                        Text(['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][index]),
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
              Text('Hành động'),
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
              Text('Relay'),
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
