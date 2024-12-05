import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class CountdownPage extends StatefulWidget {
  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  int selectedHours = 0;
  int selectedMinutes = 0;
  int remainingSeconds = 0;
  bool isCountingDown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn thời gian đếm ngược'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiển thị thời gian còn lại
          Text(
            formatTime(remainingSeconds),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Picker cho giờ và phút (chỉ hiển thị khi chưa bắt đầu đếm ngược)
          if (!isCountingDown)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberPicker(
                  minValue: 0,
                  maxValue: 23,
                  value: selectedHours,
                  onChanged: (value) {
                    setState(() {
                      selectedHours = value;
                    });
                  },
                ),
                Text(':'),
                NumberPicker(
                  minValue: 0,
                  maxValue: 59,
                  value: selectedMinutes,
                  onChanged: (value) {
                    setState(() {
                      selectedMinutes = value;
                    });
                  },
                ),
              ],
            ),

          SizedBox(height: 20),

          // Nút xác nhận (chỉ hiển thị khi chưa bắt đầu đếm ngược)
          if (!isCountingDown)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  remainingSeconds = (selectedHours * 3600) + (selectedMinutes * 60);
                  isCountingDown = true;
                });
                startCountdown();
              },
              child: Text('Xác nhận'),
            ),

          // Nút hủy đếm ngược (chỉ hiển thị khi đang đếm ngược)
          if (isCountingDown)
            ElevatedButton(
              onPressed: cancelCountdown,
              child: Text('Hủy đếm ngược'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  // Hàm định dạng thời gian
  String formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Hàm bắt đầu đếm ngược
  void startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (remainingSeconds > 0 && isCountingDown) {
        setState(() {
          remainingSeconds--;
        });
        startCountdown();
      } else {
        setState(() {
          isCountingDown = false;
        });
      }
    });
  }

  // Hàm hủy đếm ngược
  void cancelCountdown() {
    setState(() {
      isCountingDown = false;
      remainingSeconds = 0;
    });
  }
}
