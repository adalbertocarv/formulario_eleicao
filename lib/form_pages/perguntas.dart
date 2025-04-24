import 'package:flutter/material.dart';

class PerguntaPage extends StatelessWidget {
  final String pergunta;
  final Widget resposta;
  final int atual;
  final int total;
  final VoidCallback onAvancar;
  final VoidCallback? onVoltar;

  const PerguntaPage({
    required this.pergunta,
    required this.resposta,
    required this.atual,
    required this.total,
    required this.onAvancar,
    this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pergunta $atual de $total')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(value: atual / total),
            SizedBox(height: 20),
            Text(pergunta, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            resposta,
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onVoltar != null)
                  OutlinedButton(
                    onPressed: onVoltar,
                    child: const Text('Voltar'),
                  ),
                ElevatedButton(
                  onPressed: onAvancar,
                  child: Text(atual == total ? 'Enviar' : 'Próximo'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
