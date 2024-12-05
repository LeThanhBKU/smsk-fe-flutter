import 'package:flutter/material.dart';
import 'schedule_list_page.dart'; // Import trang ScheduleListPage
import 'history_page.dart'; // Import trang HistoryPage
import 'smart_function_page.dart'; // Import trang SmartFunctionPage

class MoreOptionsPage extends StatelessWidget {
  final String productId;

  const MoreOptionsPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhiều hơn'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap:
                      true, // Cho phép GridView điều chỉnh chiều cao tự động
                  physics:
                      NeverScrollableScrollPhysics(), // Ngăn GridView tự cuộn
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Hai cột
                    crossAxisSpacing: 16.0, // Khoảng cách ngang giữa các ô
                    mainAxisSpacing: 16.0, // Khoảng cách dọc giữa các ô
                    childAspectRatio: 1.0, // Tỉ lệ khung hình của mỗi ô (vuông)
                  ),
                  itemCount: 4, // Số lượng ô
                  itemBuilder: (context, index) {
                    // Danh sách các mục trong lưới
                    final options = [
                      {
                        'icon': Icons.history,
                        'label': 'Lịch sử',
                        'onTap': () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryPage()),
                          );
                        },
                      },
                      {
                        'icon': Icons.smart_toy,
                        'label': 'Chức năng thông minh',
                        'onTap': () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SmartFunctionPage()),
                          );
                        },
                      },
                      {
                        'icon': Icons.electric_bolt,
                        'label': 'Lịch sử tiêu thụ điện năng',
                        'onTap': () {
                          // Xử lý cho mục này
                          print('Chức năng đang được phát triển!');
                        },
                      },
                      {
                        'icon': Icons.event_note,
                        'label': 'Lịch sử đặt lịch',
                        'onTap': () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleListPage(
                                productId: productId // Truyền danh sách lịch trình
                              ),
                            ),
                          );
                        },
                      },
                    ];

                    // Tạo từng ô trong lưới
                    return GestureDetector(
                      onTap: options[index]['onTap'] as void Function(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            options[index]['icon'] as IconData,
                            size: 70.0, // Kích thước biểu tượng
                          ),
                          SizedBox(height: 10),
                          Text(
                            options[index]['label'] as String,
                            style:
                                TextStyle(fontSize: 16), // Cỡ chữ nhỏ gọn hơn
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
