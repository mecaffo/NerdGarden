class Verdura {
  final int id;
  final String nome;
  final String unita;

  Verdura({
    //tutti required come nel backend
    required this.id,
    required this.nome,
    required this.unita,
  });

  factory Verdura.fromJson(Map<String, dynamic> json) {
    return Verdura(
      id: json['id'],
      nome: json['nome'],
      unita: json['unita'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'unita': unita,
    };
  }
}