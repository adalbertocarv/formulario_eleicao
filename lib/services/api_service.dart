import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<bool> enviarFormulario(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('http://SEU_BACKEND/api/formulario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }
}
