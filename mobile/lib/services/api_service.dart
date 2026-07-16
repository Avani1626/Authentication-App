import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// android emulator maps host localhost to 10.0.2.2
const baseUrl = 'http://10.0.2.2:3000';

class ApiService {
  const ApiService();

  Future<num> calculate(String operation, num a, num b) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw ApiException('You must be signed in.');
    final token = await user.getIdToken();

    final res = await http.post(
      Uri.parse('$baseUrl/api/calculate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'operation': operation, 'a': a, 'b': b}),
    );

    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['result'] as num;
    }
    throw ApiException('Request failed (${res.statusCode})');
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
