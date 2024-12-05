import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  // Singleton pattern: tạo ra một instance duy nhất của DatabaseHelper
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm hoặc cập nhật các công tắc
  Future<void> saveSwitches(List<bool> switches) async {
    try {
      await _firestore.collection('switches').doc('settings').set({
        'switch1': switches[0],
        'switch2': switches[1],
        'switch3': switches[2],
      });
    } catch (e) {
      print('Error saving switches: $e');
    }
  }

  // Lấy các công tắc từ Firebase Firestore
  Future<List<bool>> loadSwitches() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('switches').doc('settings').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return [
          data['switch1'] ?? false,
          data['switch2'] ?? false,
          data['switch3'] ?? false,
        ];
      } else {
        return [false, false, false]; // Nếu không có dữ liệu, trả về giá trị mặc định
      }
    } catch (e) {
      print('Error loading switches: $e');
      return [false, false, false]; // Nếu có lỗi, trả về giá trị mặc định
    }
  }
}
