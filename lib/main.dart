import 'package:flutter/material.dart';
import 'package:formulario_eleicao/screens/formulario_page.dart';
import 'screens/login_page.dart';
import 'services/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await TokenService.getToken();
  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  
  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Pesquisa eleitoral',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: initialToken != null ? FormularioPage() : LoginPage(),
    );
  }
}