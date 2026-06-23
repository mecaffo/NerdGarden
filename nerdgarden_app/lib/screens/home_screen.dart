import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nerdgarden_app/models/verdura.dart';
import 'package:nerdgarden_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<int> _ordineVerdure = []; //ordine dinamico verdure recenti
  List<Verdura> _verdure = [];
  Verdura? _verduraSelezionata;
  final _pesoController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _dataSelezionata = DateTime.now();
  bool _isLoading = false;
  bool _verdureLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadVerdure();
  }

Future<void> _loadVerdure() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final ordine = prefs.getStringList('ordine_verdure') ?? [];
    _ordineVerdure = ordine.map((e) => int.parse(e)).toList();
    
    final verdure = await ApiService.getVerdure();
    verdure.sort((a, b) {
      final indexA = _ordineVerdure.indexOf(a.id);
      final indexB = _ordineVerdure.indexOf(b.id);
      if (indexA == -1 && indexB == -1) return 0;
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });
    setState(() {
      _verdure = verdure;
      _verdureLoaded = true;
    });
  } catch (e) {
    setState(() => _verdureLoaded = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore — server raggiungibile?'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _aggiornaOrdineVerdure(int verduraId) async {
  final preft = await SharedPreferences.getInstance();
  _ordineVerdure.remove(verduraId);
  _ordineVerdure.insert(0, verduraId);
  await preft.setStringList(
    'ordine_verdure',
    _ordineVerdure.map((e) => e.toString()).toList(),
  );
}

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelezionata,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dataSelezionata = picked);
    }
  }

  Future<void> _salvaRaccolto() async {
    if (_verduraSelezionata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una verdura')),
      );
      return;
    }
    if (_pesoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci il peso')),
      );
      return;
    }
    final peso = int.tryParse(_pesoController.text.trim());
    if (peso == null || peso <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peso non valido')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService.createRaccolto(
        _verduraSelezionata!.id,
        peso,
        _dataSelezionata,
        _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      await _aggiornaOrdineVerdure(_verduraSelezionata!.id);
      setState(() {
        _verdure = List.from(_verdure); // forza il ridisegno del dropdown
        _verduraSelezionata = null;
        _pesoController.clear();
        _noteController.clear();
        _dataSelezionata = DateTime.now();
        _isLoading = false;
      });
      _verdure.sort((a, b) {
      final indexA = _ordineVerdure.indexOf(a.id);
      final indexB = _ordineVerdure.indexOf(b.id);
      if (indexA == -1 && indexB == -1) return 0;
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Raccolto salvato!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nel salvataggio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo raccolto')),
      body: _verdureLoaded
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Verdura',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Verdura>(
                    value: _verduraSelezionata,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Seleziona una verdura',
                    ),
                    items: _verdure
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v.nome),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _verduraSelezionata = v),
                  ),
                  const SizedBox(height: 16),
                  const Text('Peso (g)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pesoController,
                    decoration: const InputDecoration(
                      hintText: 'Es. 350',
                      border: OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const Text('Data',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_dataSelezionata),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Note (opzionale)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Es. prima raccolta della stagione',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _salvaRaccolto,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Salva raccolto'),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}