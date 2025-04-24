import 'package:flutter/material.dart';
import '../form_pages/form_wizard.dart';

class FormularioPage extends StatelessWidget {
  const FormularioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisa de Opinião Pública - DF'),
        centerTitle: true,
      ),
      body: FormWizard(),
    );
  }
}
