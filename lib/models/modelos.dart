class Compromisso {
  const Compromisso({
    required this.id,
    required this.titulo,
    required this.inicio,
    required this.fim,
  });

  final String id;
  final String titulo;
  final DateTime inicio;
  final DateTime fim;

  factory Compromisso.fromMap(Map<String, dynamic> m) => Compromisso(
        id: m['id'] as String,
        titulo: m['titulo'] as String,
        inicio: DateTime.parse(m['inicio'] as String).toLocal(),
        fim: DateTime.parse(m['fim'] as String).toLocal(),
      );
}

class Grupo {
  const Grupo({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.membros,
    this.excluiEm,
  });

  /// Dias que um membro pode ficar sozinho antes de o grupo ser excluído.
  /// Só serve para o texto de confirmação: precisa ser igual a
  /// dias_para_excluir_grupo() no SQL. A data real vem de [excluiEm].
  static const diasParaExcluir = 7;

  final String id;
  final String nome;
  final String codigo;
  final int membros;

  /// Quando o grupo será excluído por ter só um membro (null = sem prazo).
  final DateTime? excluiEm;

  String get excluiEmTexto {
    final d = excluiEm;
    if (d == null) return '';
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year} às ${dois(d.hour)}:${dois(d.minute)}';
  }

  factory Grupo.fromMap(Map<String, dynamic> m) {
    final part = m['participacoes'];
    final n = (part is List && part.isNotEmpty) ? (part.first['count'] as int) : 1;
    return Grupo(
      id: m['id'] as String,
      nome: m['nome'] as String,
      codigo: m['codigo'] as String,
      membros: n,
      excluiEm: m['exclui_em'] == null
          ? null
          : DateTime.parse(m['exclui_em'] as String).toLocal(),
    );
  }
}

/// Aviso de grupo gerado no servidor (alguém saiu, grupo será/foi excluído).
class AvisoGrupo {
  const AvisoGrupo({
    required this.id,
    required this.titulo,
    required this.mensagem,
  });

  final String id;
  final String titulo;
  final String mensagem;

  factory AvisoGrupo.fromMap(Map<String, dynamic> m) => AvisoGrupo(
        id: m['id'] as String,
        titulo: m['titulo'] as String,
        mensagem: m['mensagem'] as String,
      );
}

class Ocupacao {
  const Ocupacao({
    required this.usuarioId,
    required this.nomeMembro,
    required this.inicio,
    required this.fim,
  });

  final String usuarioId;
  final String nomeMembro;
  final DateTime inicio;
  final DateTime fim;

  factory Ocupacao.fromMap(Map<String, dynamic> m) => Ocupacao(
        usuarioId: m['usuario_id'] as String,
        nomeMembro: m['nome_membro'] as String,
        inicio: DateTime.parse(m['inicio'] as String).toLocal(),
        fim: DateTime.parse(m['fim'] as String).toLocal(),
      );
}

class Intervalo {
  const Intervalo({required this.inicio, required this.fim});

  final DateTime inicio;
  final DateTime fim;

  Duration get duracao => fim.difference(inicio);

  factory Intervalo.fromMap(Map<String, dynamic> m) => Intervalo(
        inicio: DateTime.parse(m['inicio_livre'] as String).toLocal(),
        fim: DateTime.parse(m['fim_livre'] as String).toLocal(),
      );
}
