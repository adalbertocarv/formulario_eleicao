// form_wizard.dart - versão estilizada e com fonte Poppins moderna aplicada
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import 'form_controller.dart';
import 'perguntas.dart';

class FormWizard extends StatefulWidget {
  @override
  _FormWizardState createState() => _FormWizardState();
}

class _FormWizardState extends State<FormWizard> {
  final PageController _controller = PageController();
  final FormularioData _dados = FormularioData();
  int _paginaAtual = 0;

  final int totalPerguntas = 15;

  @override
  void initState() {
    super.initState();
    _carregarLocalizacao();
  }

  void _paginaAnterior() {
    if (_paginaAtual > 0) {
      setState(() => _paginaAtual--);
      _controller.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _carregarLocalizacao() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      _dados.latitude = pos.latitude;
      _dados.longitude = pos.longitude;
      _dados.dataHora = DateTime.now();
    }
  }

  void _proximaPagina() {
    if (_paginaAtual < totalPerguntas - 1) {
      setState(() => _paginaAtual++);
      _controller.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _enviarFormulario();
    }
  }

  Future<void> _enviarFormulario() async {
    final sucesso = await ApiService.enviarFormulario(_dados.toJson());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          sucesso ? 'Sucesso' : 'Erro',
          style: TextStyle(
            color: sucesso ? Colors.green[800] : Colors.red[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          sucesso
              ? 'Formulário enviado com sucesso.'
              : 'Falha ao enviar formulário.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (sucesso) Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.indigo)),
          )
        ],
      ),
    );
  }

  List<Widget> _paginas() {
    final List<Map<String, String>> politicos = [
      {
        'nome': 'ALBERTO FRAGA',
        'partido': 'PL - DF',
        'imagem':
            'https://storage-download.googleapis.com/politicos-bucket-org/a3f7959c-c4c6-4acd-9dd8-fa36b21fb4b3.jpg'
      },
      {
        'nome': 'BIA KICIS',
        'partido': 'PL - DF',
        'imagem':
            'https://storage-download.googleapis.com/politicos-bucket-org/a675cbda-8d82-46f7-942e-b900a6ad7295.jpg'
      },
      {
        'nome': 'PROF. REGINALDO VERAS',
        'partido': 'PV - DF',
        'imagem':
            'https://storage-download.googleapis.com/politicos-bucket-org/57b291a4-e55e-4a59-8bca-2ab8072ac2e7.jpg'
      },
      {
        'nome': 'FRED LINHARES',
        'partido': 'REPUBLICANOS - DF',
        'imagem':
            'https://storage-download.googleapis.com/politicos-bucket-org/5e1779b7-c6ba-409e-937c-642b986ca692.jpg'
      },
      {
        'nome': 'RAFAEL PRUDENTE',
        'partido': 'MDB - DF',
        'imagem':
            'https://storage-download.googleapis.com/politicos-bucket-org/3c1834a3-a3e9-46dd-8da9-11ab182bb014.jpg'
      },
      {
        'nome': 'GILVAN MAXIMO',
        'partido': 'REPUBLICANOS - DF',
        'imagem':
            'https://storage-download.googleapis.com/politicos-bucket-org/932d8442-8431-44df-aabb-084d833034fb.jpg'
      },
      {
        'nome': 'JULIO CESAR RIBEIRO',
        'partido': 'REPUBLICANOS - DF',
        'imagem':
            'https://storage-download.googleapis.com/politicos-bucket-org/b6da8e4d-5b2f-4747-8587-01ed6de993ab.jpg'
      },
    ];

    return [
      PerguntaPage(
        pergunta: 'Qual seu sexo?',
        resposta: Column(
          children: ['Masculino', 'Feminino', 'Outro', 'Prefere não responder']
              .map((e) => RadioListTile(
                    title: Text(e, style: TextStyle(fontSize: 18)),
                    activeColor: Colors.indigo,
                    value: e,
                    groupValue: _dados.sexo,
                    onChanged: (val) => setState(() => _dados.sexo = val),
                  ))
              .toList(),
        ),
        atual: 1,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
      ),
      PerguntaPage(
        pergunta: 'Qual sua idade?',
        resposta: TextFormField(
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Digite sua idade',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          onChanged: (val) => _dados.idade = int.tryParse(val),
        ),
        atual: 2,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Faixa de renda mensal:',
        resposta: Column(
          children: [
            'Até 1 salário mínimo',
            '1 a 3 salários mínimos',
            '3 a 5 salários mínimos',
            'Mais de 5 salários mínimos',
            'Prefere não responder'
          ]
              .map((e) => RadioListTile(
                    title: Text(e),
                    value: e,
                    groupValue: _dados.renda,
                    onChanged: (val) => setState(() => _dados.renda = val),
                  ))
              .toList(),
        ),
        atual: 3,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Escolaridade:',
        resposta: Column(
          children: [
            'Ensino Fundamental incompleto',
            'Ensino Fundamental completo',
            'Ensino Médio completo',
            'Ensino Superior incompleto',
            'Ensino Superior completo',
            'Pós-graduação',
            'Prefere não responder'
          ]
              .map((e) => RadioListTile(
                    title: Text(e),
                    value: e,
                    groupValue: _dados.escolaridade,
                    onChanged: (val) =>
                        setState(() => _dados.escolaridade = val),
                  ))
              .toList(),
        ),
        atual: 4,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Você se identifica com alguma religião?',
        resposta: Column(
          children: [
            RadioListTile(
              title: Text('Sim'),
              value: 'Sim',
              groupValue: _dados.religiao,
              onChanged: (val) => setState(() => _dados.religiao = val),
            ),
            RadioListTile(
              title: Text('Não'),
              value: 'Não',
              groupValue: _dados.religiao,
              onChanged: (val) => setState(() => _dados.religiao = val),
            ),
            if (_dados.religiao == 'Sim')
              TextFormField(
                decoration: InputDecoration(labelText: 'Qual?'),
                onChanged: (val) => _dados.religiaoTipo = val,
              )
          ],
        ),
        atual: 5,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta:
            'Você está satisfeito com os serviços públicos na sua região?',
        resposta: Column(
          children: ['Sim', 'Não', 'Parcialmente']
              .map((e) => RadioListTile(
                    title: Text(e),
                    value: e,
                    groupValue: _dados.satisfacaoServicos,
                    onChanged: (val) =>
                        setState(() => _dados.satisfacaoServicos = val),
                  ))
              .toList(),
        ),
        atual: 6,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Quais áreas são mais problemáticas na sua região?',
        resposta: Column(
          children: [
            ...[
              'Saúde',
              'Educação',
              'Segurança',
              'Transporte',
              'Infraestrutura',
              'Meio ambiente',
            ].map((e) => CheckboxListTile(
                  title: Text(e),
                  value: _dados.problemas.contains(e),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _dados.problemas.add(e);
                      } else {
                        _dados.problemas.remove(e);
                      }
                    });
                  },
                )),
            TextFormField(
              decoration: InputDecoration(labelText: 'Outro (opcional)'),
              onChanged: (val) {
                setState(() {
                  if (val.isNotEmpty && !_dados.problemas.contains(val)) {
                    _dados.problemas.add(val);
                  }
                });
              },
            ),
          ],
        ),
        atual: 7,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Você conhece os políticos da sua região?',
        resposta: Column(
          children: ['Sim', 'Não', 'Mais ou menos']
              .map((e) => RadioListTile(
                    title: Text(e),
                    value: e,
                    groupValue: _dados.conhecePoliticos,
                    onChanged: (val) =>
                        setState(() => _dados.conhecePoliticos = val),
                  ))
              .toList(),
        ),
        atual: 8,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Você confia nos políticos eleitos atualmente?',
        resposta: Slider(
          value: _dados.confianca ?? 5,
          min: 0,
          max: 10,
          divisions: 10,
          label: '${_dados.confianca ?? 5}',
          onChanged: (val) => setState(() => _dados.confianca = val),
        ),
        atual: 9,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Quais políticos do DF você conhece?',
        resposta: TextFormField(
          decoration: InputDecoration(hintText: 'Separe por vírgula'),
          onChanged: (val) => _dados.politicosConhecidos =
              val.split(',').map((e) => e.trim()).toList(),
        ),
        atual: 10,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Você vota na próxima eleição?',
        resposta: Column(
          children: ['Sim', 'Não', 'Não sei ainda']
              .map((e) => RadioListTile(
                    title: Text(e),
                    value: e,
                    groupValue: _dados.vaiVotar,
                    onChanged: (val) => setState(() => _dados.vaiVotar = val),
                  ))
              .toList(),
        ),
        atual: 11,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'O que mais influencia seu voto?',
        resposta: Column(
          children: [
            ...[
              'Propostas',
              'Experiência',
              'Reputação / Honestidade',
              'Influência da família ou amigos',
              'Benefícios diretos para a comunidade',
              'Outro'
            ].map((e) => RadioListTile(
                  title: Text(e),
                  value: e,
                  groupValue: _dados.influenciaVoto,
                  onChanged: (val) =>
                      setState(() => _dados.influenciaVoto = val),
                )),
            if (_dados.influenciaVoto == 'Outro')
              TextFormField(
                decoration: const InputDecoration(labelText: 'Especifique'),
                onChanged: (val) => _dados.influenciaOutro = val,
              ),
          ],
        ),
        atual: 12,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'De 0 a 10, qual seu interesse por política?',
        resposta: Slider(
          value: _dados.interesse ?? 5,
          min: 0,
          max: 10,
          divisions: 10,
          label: '${_dados.interesse ?? 5}',
          onChanged: (val) => setState(() => _dados.interesse = val),
        ),
        atual: 13,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Deixe sua opinião livre sobre política no DF:',
        resposta: TextFormField(
          maxLines: 5,
          decoration: InputDecoration(hintText: 'Escreva aqui...'),
          onChanged: (val) => _dados.opiniaoLivre = val,
        ),
        atual: 14,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      ),
      PerguntaPage(
        pergunta: 'Você conhece algum desses políticos?',
        resposta: SizedBox(
          height: 350,
          child: PageView.builder(
            itemCount: politicos.length,
            controller: PageController(viewportFraction: 0.85),
            itemBuilder: (context, index) {
              final p = politicos[index];
              final selecionado =
                  _dados.politicosConhecidos?.contains(p['nome']) ?? false;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _dados.politicosConhecidos ??= [];
                    if (selecionado) {
                      _dados.politicosConhecidos!.remove(p['nome']!);
                    } else {
                      _dados.politicosConhecidos!.add(p['nome']!);
                    }
                  });
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 6,
                  color: selecionado ? Colors.indigo[50] : Colors.white,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          p['imagem']!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['nome']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              p['partido']!,
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  selecionado
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: selecionado
                                      ? Colors.greenAccent
                                      : Colors.white70,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  selecionado
                                      ? 'Selecionado'
                                      : 'Toque para selecionar',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        atual: totalPerguntas,
        total: totalPerguntas,
        onAvancar: _proximaPagina,
        onVoltar: _paginaAnterior,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: NeverScrollableScrollPhysics(),
      children: _paginas(),
    );
  }
}
