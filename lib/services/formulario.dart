import 'package:http/http.dart' as http;
import 'dart:convert';

class Formulario {
  static Future<bool> enviarFormulario(
      Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse('https://servidor.shark-newton.ts.net/pesquisas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      print('Formulário enviado com sucesso!');
      return true;
    } else {
      print('Erro ao enviar formulário: ${response.statusCode}');
      print(response.body);
      return false;
    }
  }
}
