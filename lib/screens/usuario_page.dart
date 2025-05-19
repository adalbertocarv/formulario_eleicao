import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioPage extends StatelessWidget {
  const UsuarioPage({super.key, required String nomeUsuario});

  Future<String> _buscarNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nomeUsuario') ?? 'Usuário';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados do Usuário')),
      body: FutureBuilder<String>(
        future: _buscarNome(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return Center(
            child: Text('Olá, ${snapshot.data}!', style: const TextStyle(fontSize: 24)),
          );
        },
      ),
    );
  }
}
