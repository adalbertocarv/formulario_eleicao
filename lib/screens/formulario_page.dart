import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/form_wizard.dart';
import '../services/token_service.dart';
import 'login_page.dart';
import 'usuario_page.dart';

class FormularioPage extends StatelessWidget {
  const FormularioPage({super.key});

  void _logout(BuildContext context) async {
    await TokenService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<String> _getNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nomeUsuario') ?? 'Usuário';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Pesquisa de Opinião Pública'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: FutureBuilder<String>(
          future: _getNomeUsuario(),
          builder: (context, snapshot) {
            final nome = snapshot.data ?? 'Usuário';

            return ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(nome),
                  accountEmail: const Text(''),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 42),
                  ),
                  decoration: const BoxDecoration(color: Colors.deepPurple),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Meu Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UsuarioPage(nomeUsuario: nome),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sair'),
                  onTap: () => _logout(context),
                ),
              ],
            );
          },
        ),
      ),
      body: FormWizard(),
    );
  }
}
