class FormularioData {
  String? sexo;
  int? idade;
  String? renda;
  String? escolaridade;
  String? religiao;
  String? religiaoTipo;
  String? satisfacaoServicos;
  List<String> problemas = [];
  String? conhecePoliticos;
  double? confianca;
  List<String>? politicosConhecidos;
  String? vaiVotar;
  String? influenciaVoto;
  String? influenciaOutro;
  double? interesse;
  String? opiniaoLivre;
  double? latitude;
  double? longitude;
  DateTime? dataHora;

  Map<String, dynamic> toJson() {
    return {
      'sexo': sexo,
      'idade': idade,
      'renda': renda,
      'escolaridade': escolaridade,
      'religiao': religiao == 'Sim' ? religiaoTipo : 'Não',
      'satisfacao_servicos': satisfacaoServicos,
      'problemas': problemas,
      'conhece_politicos': conhecePoliticos,
      'confianca': confianca,
      'politicos_conhecidos': politicosConhecidos?.join(', '),
      'vai_votar': vaiVotar == 'Sim',
      'influencia_voto': influenciaVoto == 'Outro' ? influenciaOutro : influenciaVoto,
      'interesse': interesse,
      'opiniao': opiniaoLivre,
      'latitude': latitude,
      'longitude': longitude,
      'data_hora': dataHora?.toIso8601String()
    };
  }
}
