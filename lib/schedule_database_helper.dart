
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleDatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'schedules';

  // Method to save schedule to Firestore
  Future<void> saveSchedule(Map<String, dynamic> scheduleData) async {
    try {
      await _firestore.collection(collectionName).add(scheduleData);
      print('Schedule saved successfully.');
    } catch (e) {
      print('Error saving schedule: $e');
    }
  }

  // Method to load schedules from Firestore
  Future<List<Map<String, dynamic>>> loadSchedules() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error loading schedules: $e');
      return [];
    }
  }
}
