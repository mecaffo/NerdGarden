import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nerdgarden_app/models/verdura.dart';
import 'package:nerdgarden_app/models/raccolto.dart';

class ApiService {
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('server_ip') ?? '192.168.1.1';
    final port = prefs.getString('server_port') ?? '8000';
    return 'http://$ip:$port';
  }

  // --- health ---
  static Future<bool> checkHealth() async {
    try {
      final base = await getBaseUrl();
      final response = await http.get(Uri.parse('$base/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- verdure ---
  static Future<List<Verdura>> getVerdure() async {
    final base = await getBaseUrl();
    final response = await http.get(Uri.parse('$base/verdure/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((v) => Verdura.fromJson(v)).toList();
    }
    throw Exception('Errore nel caricamento delle verdure');
  }

  static Future<Verdura> createVerdura(String nome) async {
    final base = await getBaseUrl();
    final response = await http.post(
      Uri.parse('$base/verdure/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'unita': 'g'}),
    );
    if (response.statusCode == 200) {
      return Verdura.fromJson(jsonDecode(response.body));
    }
    throw Exception('Errore nella creazione della verdura');
  }

  static Future<void> deleteVerdura(int id) async {
    final base = await getBaseUrl();
    final response = await http.delete(Uri.parse('$base/verdure/$id'));
    if (response.statusCode != 200) {
      throw Exception('Errore nella cancellazione della verdura');
    }
  }

  // --- raccolti ---
  static Future<List<Raccolto>> getRaccolti({int? verduraId, int? mese, int? anno}) async {
    final base = await getBaseUrl();
    final params = <String, String>{};
    if (verduraId != null) params['verdura_id'] = verduraId.toString();
    if (mese != null) params['mese'] = mese.toString();
    if (anno != null) params['anno'] = anno.toString();
    final uri = Uri.parse('$base/raccolti/').replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((r) => Raccolto.fromJson(r)).toList();
    }
    throw Exception('Errore nel caricamento dei raccolti');
  }

  static Future<Raccolto> createRaccolto(int verduraId, int peso, DateTime data, String? note) async {
    final base = await getBaseUrl();
    final response = await http.post(
      Uri.parse('$base/raccolti/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'verdura_id': verduraId,
        'peso': peso,
        'data': data.toIso8601String().split('T')[0],
        'note': note,
      }),
    );
    if (response.statusCode == 200) {
      return Raccolto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Errore nel salvataggio del raccolto');
  }

  static Future<void> deleteRaccolto(int id) async {
    final base = await getBaseUrl();
    final response = await http.delete(Uri.parse('$base/raccolti/$id'));
    if (response.statusCode != 200) {
      throw Exception('Errore nella cancellazione del raccolto');
    }
  }
}