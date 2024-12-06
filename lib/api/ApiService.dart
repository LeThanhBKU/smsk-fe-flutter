// import 'dart:convert';
// import 'package:flutter_application_1/config/config.dart';
// import 'package:http/http.dart' as http;

// class ApiService {
//   // Hàm GET request
//   Future<Map<String, dynamic>> get(String endpoint) async {
//     try {
//       final response = await http.get(Uri.parse('${Config.baseUrl}$endpoint'));

//       if (response.statusCode == 200) {
//         // Chuyển đổi response thành JSON
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Hàm POST request
//   Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${Config.baseUrl}$endpoint'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(body),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to post data');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Hàm PUT request
//   Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
//     try {
//       final response = await http.put(
//         Uri.parse('${Config.baseUrl}$endpoint'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(body),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to update data');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Hàm DELETE request
//   Future<Map<String, dynamic>> delete(String endpoint) async {
//     try {
//       final response = await http.delete(Uri.parse('${Config.baseUrl}$endpoint'));

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to delete data');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
