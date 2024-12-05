import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'history_provider.dart'; // Import HistoryProvider

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Xóa toàn bộ lịch sử
              historyProvider.clearHistory();
            },
          ),
        ],
      ),
      body: historyProvider.history.isEmpty
          ? Center(child: Text('Không có sự kiện nào.'))
          : ListView.builder(
              itemCount: historyProvider.history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(historyProvider.history[index]),
                );
              },
            ),
    );
  }
}
