import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'formulario_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _carregando = false;
  bool _mostrarSenha = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _senhaController.text.trim().isEmpty) {
      _mostrarErro('Por favor, preencha todos os campos.');
      return;
    }

    setState(() => _carregando = true);

    try {
      final response = await http.post(
        Uri.parse('https://servidor.shark-newton.ts.net/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'senha': _senhaController.text.trim(),
        }),
      );

      setState(() => _carregando = false);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        final nome = body['nome']; 

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('nomeUsuario', nome); 

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FormularioPage()),
        );
      } else {
        _mostrarErro('Falha ao fazer login. Verifique suas credenciais.');
      }
    } catch (e) {
      setState(() => _carregando = false);
      _mostrarErro(
          'Erro de conexão. Verifique sua internet e tente novamente.');
    }
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              Icons.error,
              color: Color(0xFFF44336),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: GoogleFonts.poppins(
                color: Color(0xFFC62828),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          mensagem,
          style: GoogleFonts.poppins(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[300],
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
        actionsPadding: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF9F8FF)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo ou ícone
                      Container(
                        height: 120,
                        width: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6C63FF).withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 64,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      SizedBox(height: 40),

                      // Título
                      Text(
                        'Bem-vindo',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Faça login para continuar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Divider(
                        color: Color(0xFF6C63FF),
                        thickness: 3,
                        indent: MediaQuery.of(context).size.width * 0.35,
                        endIndent: MediaQuery.of(context).size.width * 0.35,
                      ),
                      SizedBox(height: 40),

                      // Campo de email
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Digite seu email',
                            labelText: 'Email',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                            ),
                            labelStyle: GoogleFonts.poppins(
                              color: Color(0xFF6C63FF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 2.0,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Color(0xFF6C63FF),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),

                      // Campo de senha
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: TextFormField(
                          controller: _senhaController,
                          obscureText: !_mostrarSenha,
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Digite sua senha',
                            labelText: 'Senha',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                            ),
                            labelStyle: GoogleFonts.poppins(
                              color: Color(0xFF6C63FF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 2.0,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color(0xFF6C63FF),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mostrarSenha
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Color(0xFF6C63FF),
                              ),
                              onPressed: () {
                                setState(() {
                                  _mostrarSenha = !_mostrarSenha;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),

                      // Botão de login
                      Container(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _carregando ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            disabledBackgroundColor:
                                Color(0xFF6C63FF).withOpacity(0.6),
                          ),
                          child: _carregando
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Entrar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded),
                                  ],
                                ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Link de recuperação de senha
                      TextButton(
                        onPressed: () {
                          // Implementar recuperação de senha
                        },
                        child: Text(
                          'Esqueceu a senha?',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
