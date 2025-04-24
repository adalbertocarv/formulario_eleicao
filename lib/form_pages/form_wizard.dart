import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import 'form_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class FormWizard extends StatefulWidget {
  @override
  _FormWizardState createState() => _FormWizardState();
}

class _FormWizardState extends State<FormWizard> with TickerProviderStateMixin {
  final PageController _controller = PageController();
  final FormularioData _dados = FormularioData();
  int _paginaAtual = 0;
  late AnimationController _animationController;
  final int totalPerguntas = 15;

  @override
  void initState() {
    super.initState();
    _carregarLocalizacao();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _paginaAnterior() {
    if (_paginaAtual > 0) {
      _animationController.reverse().then((_) {
        setState(() => _paginaAtual--);
        _controller.previousPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        _animationController.forward();
      });
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
      _animationController.reverse().then((_) {
        setState(() => _paginaAtual++);
        _controller.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        _animationController.forward();
      });
    } else {
      _enviarFormulario();
    }
  }

  Future<void> _enviarFormulario() async {
    // Mostrar indicador de progresso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6C63FF),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Enviando formulário...',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );

    // Processar envio
    final sucesso = await ApiService.enviarFormulario(_dados.toJson());
    
    // Fechar diálogo de progresso
    Navigator.pop(context);
    
    // Mostrar resultado
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              sucesso ? Icons.check_circle : Icons.error,
              color: sucesso ? Color(0xFF4CAF50) : Color(0xFFF44336),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              sucesso ? 'Sucesso!' : 'Ops! Algo deu errado',
              style: GoogleFonts.poppins(
                color: sucesso ? Color(0xFF2E7D32) : Color(0xFFC62828),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          sucesso
              ? 'Seu formulário foi enviado com sucesso. Agradecemos sua participação!'
              : 'Não foi possível enviar seu formulário. Por favor, tente novamente mais tarde.',
          style: GoogleFonts.poppins(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (sucesso) Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: sucesso ? Color(0xFF6C63FF) : Colors.grey[300],
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: sucesso ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
        actionsPadding: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Pergunta ${_paginaAtual + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C63FF),
                ),
              ),
              Text(
                ' de $totalPerguntas',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_paginaAtual + 1) / totalPerguntas,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF6C63FF),
              ),
            ),
          ),
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
      _buildPage(
        titulo: 'Qual seu sexo?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: ['Masculino', 'Feminino', 'Outro', 'Prefere não responder']
                  .map((e) => _buildRadioOption(
                        title: e,
                        value: e,
                        groupValue: _dados.sexo,
                        onChanged: (val) => setState(() => _dados.sexo = val),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Qual sua idade?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Digite sua idade',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: Color(0xFF6C63FF),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                ),
                onChanged: (val) => _dados.idade = int.tryParse(val),
              ),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Faixa de renda mensal:',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: [
                'Até 1 salário mínimo',
                '1 a 3 salários mínimos',
                '3 a 5 salários mínimos',
                'Mais de 5 salários mínimos',
                'Prefere não responder'
              ]
                  .map((e) => _buildRadioOption(
                        title: e,
                        value: e,
                        groupValue: _dados.renda,
                        onChanged: (val) => setState(() => _dados.renda = val),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Escolaridade:',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: [
                'Ensino Fundamental incompleto',
                'Ensino Fundamental completo',
                'Ensino Médio completo',
                'Ensino Superior incompleto',
                'Ensino Superior completo',
                'Pós-graduação',
                'Prefere não responder'
              ]
                  .map((e) => _buildRadioOption(
                        title: e,
                        value: e,
                        groupValue: _dados.escolaridade,
                        onChanged: (val) =>
                            setState(() => _dados.escolaridade = val),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Você se identifica com alguma religião?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: [
                _buildRadioOption(
                  title: 'Sim',
                  value: 'Sim',
                  groupValue: _dados.religiao,
                  onChanged: (val) => setState(() => _dados.religiao = val),
                ),
                _buildRadioOption(
                  title: 'Não',
                  value: 'Não',
                  groupValue: _dados.religiao,
                  onChanged: (val) => setState(() => _dados.religiao = val),
                ),
                if (_dados.religiao == 'Sim')
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: TextFormField(
                      style: GoogleFonts.poppins(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Qual?',
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (val) => _dados.religiaoTipo = val,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Você está satisfeito com os serviços públicos na sua região?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: ['Sim', 'Não', 'Parcialmente']
                  .map((e) => _buildRadioOption(
                        title: e,
                        value: e,
                        groupValue: _dados.satisfacaoServicos,
                        onChanged: (val) =>
                            setState(() => _dados.satisfacaoServicos = val),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Quais áreas são mais problemáticas na sua região?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: [
                ...[
                  'Saúde',
                  'Educação',
                  'Segurança',
                  'Transporte',
                  'Infraestrutura',
                  'Meio ambiente',
                ].map((e) => _buildCheckboxOption(
                      title: e,
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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: TextFormField(
                    style: GoogleFonts.poppins(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Outro (opcional)',
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
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val.isNotEmpty && !_dados.problemas.contains(val)) {
                          _dados.problemas.add(val);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Você conhece os políticos da sua região?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: ['Sim', 'Não', 'Mais ou menos']
                  .map((e) => _buildRadioOption(
                        title: e,
                        value: e,
                        groupValue: _dados.conhecePoliticos,
                        onChanged: (val) =>
                            setState(() => _dados.conhecePoliticos = val),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Você confia nos políticos eleitos atualmente?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nenhuma\nconfiança',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Máxima\nconfiança',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 56,
                    child: Slider(
                      value: _dados.confianca ?? 5,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      activeColor: Color(0xFF6C63FF),
                      inactiveColor: Colors.grey[300],
                      label: '${(_dados.confianca ?? 5).toInt()}',
                      onChanged: (val) => setState(() => _dados.confianca = val),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${(_dados.confianca ?? 5).toInt()} / 10',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Quais políticos do DF você conhece?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: TextFormField(
                style: GoogleFonts.poppins(fontSize: 16),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Separe por vírgula',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
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
                    Icons.person,
                    color: Color(0xFF6C63FF),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                ),
                onChanged: (val) => _dados.politicosConhecidos =
                    val.split(',').map((e) => e.trim()).toList(),
              ),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Você vota na próxima eleição?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: ['Sim', 'Não', 'Não sei ainda']
                  .map((e) => _buildRadioOption(
                        title: e,
                        value: e,
                        groupValue: _dados.vaiVotar,
                        onChanged: (val) => setState(() => _dados.vaiVotar = val),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'O que mais influencia seu voto?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Column(
              children: [
                ...[
                  'Propostas',
                  'Experiência',
                  'Reputação / Honestidade',
                  'Influência da família ou amigos',
                  'Benefícios diretos para a comunidade',
                  'Outro'
                ].map((e) => _buildRadioOption(
                      title: e,
                      value: e,
                      groupValue: _dados.influenciaVoto,
                      onChanged: (val) =>
                          setState(() => _dados.influenciaVoto = val),
                    )),
                if (_dados.influenciaVoto == 'Outro')
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: TextFormField(
                      style: GoogleFonts.poppins(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Especifique',
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (val) => _dados.influenciaOutro = val,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'De 0 a 10, qual seu interesse por política?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.sentiment_very_dissatisfied, color: Colors.grey[600]),
                          Text(
                            'Nenhum\ninteresse',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.sentiment_very_satisfied, color: Colors.grey[600]),
                          Text(
                            'Muito\ninteressado',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 56,
                    child: Slider(
                      value: _dados.interesse ?? 5,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      activeColor: Color(0xFF6C63FF),
                      inactiveColor: Colors.grey[300],
                      label: '${(_dados.interesse ?? 5).toInt()}',
                      onChanged: (val) => setState(() => _dados.interesse = val),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${(_dados.interesse ?? 5).toInt()} / 10',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Deixe sua opinião livre sobre política no DF:',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: TextFormField(
                maxLines: 6,
                style: GoogleFonts.poppins(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Escreva aqui...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                ),
                onChanged: (val) => _dados.opiniaoLivre = val,
              ),
            ),
          ),
        ),
      ),
      _buildPage(
        titulo: 'Você conhece algum desses políticos?',
        conteudo: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuint,
            )),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    'Deslize para ver todos os políticos',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 360,
                    child: PageView.builder(
                      itemCount: politicos.length,
                      controller: PageController(viewportFraction: 0.85),
                      itemBuilder: (context, index) {
                        final p = politicos[index];
                        final selecionado =
                            _dados.politicosConhecidos?.contains(p['nome']) ?? false;
                        return Hero(
                          tag: 'politico-${p['nome']}',
                          child: GestureDetector(
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
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black26,
                              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF6C63FF),
                                            ),
                                          ),
                                        );
                                      },
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
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                          Colors.black.withOpacity(0.9),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['nome']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          p['partido']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: selecionado 
                                                ? Color(0xFF4CAF50).withOpacity(0.8) 
                                                : Colors.white.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                selecionado
                                                    ? Icons.check_circle
                                                    : Icons.radio_button_unchecked,
                                                color: selecionado
                                                    ? Colors.white
                                                    : Colors.white70,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                selecionado
                                                    ? 'Eu conheço'
                                                    : 'Não conheço',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selecionado)
                                    Positioned(
                                      top: 16,
                                      right: 16,
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF4CAF50),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildRadioOption({
    required String title,
    required dynamic value,
    required dynamic groupValue,
    required Function(dynamic) onChanged,
  }) {
    final bool selected = value == groupValue;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? Color(0xFFEEEBFF) : Colors.grey[100],
            border: Border.all(
              color: selected ? Color(0xFF6C63FF) : Colors.grey[300]!,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Color(0xFF6C63FF).withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Color(0xFF6C63FF) : Colors.white,
                  border: Border.all(
                    color:
                        selected ? Color(0xFF6C63FF) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? Color(0xFF6C63FF) : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: value ? Color(0xFFEEEBFF) : Colors.grey[100],
            border: Border.all(
              color: value ? Color(0xFF6C63FF) : Colors.grey[300]!,
              width: value ? 2 : 1,
            ),
            boxShadow: value
                ? [
                    BoxShadow(
                      color: Color(0xFF6C63FF).withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: value ? Color(0xFF6C63FF) : Colors.white,
                  border: Border.all(
                    color: value ? Color(0xFF6C63FF) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: value
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                    color: value ? Color(0xFF6C63FF) : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String titulo,
    required Widget conteudo,
  }) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF9F8FF)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressIndicator(),
                  SizedBox(height: 32),
                  Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(
                    color: Color(0xFF6C63FF),
                    thickness: 3,
                    endIndent: MediaQuery.of(context).size.width * 0.75,
                  ),
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(child: conteudo)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_paginaAtual > 0)
                    TextButton.icon(
                      onPressed: _paginaAnterior,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF6C63FF),
                      ),
                      label: Text(
                        'Anterior',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 100),
                  ElevatedButton(
                    onPressed: _proximaPagina,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _paginaAtual == totalPerguntas - 1 ? 'Enviar' : 'Próximo',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          _paginaAtual == totalPerguntas - 1
                              ? Icons.check_circle
                              : Icons.arrow_forward_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: _paginas(),
      ),
    );
  }
}

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
    return Container(); // Não usado mais - incorporado na nova lógica
  }
}