import 'package:nerdgarden_app/models/verdura.dart';

class Raccolto {
  final int id;
  final int verduraId;
  final int peso;
  final DateTime data;
  final String? note;
  final Verdura verdura;

  Raccolto({
    //tutti required tranne la nota come nel backend
    required this.id,
    required this.verduraId,
    required this.peso,
    required this.data,
    this.note,
    required this.verdura,
  });

  factory Raccolto.fromJson(Map<String, dynamic> json) {
    return Raccolto(
      id: json['id'],
      verduraId: json['verdura_id'],
      peso: json['peso'],
      data: DateTime.parse(json['data']),
      note: json['note'],
      verdura: Verdura.fromJson(json['verdura']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verdura_id': verduraId,
      'peso': peso,
      'data': data.toIso8601String().split('T')[0],
      'note': note,
    };
  }
}