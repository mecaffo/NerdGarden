import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nerdgarden_app/models/raccolto.dart';
import 'package:nerdgarden_app/models/verdura.dart';
import 'package:nerdgarden_app/services/api_service.dart';

class RaccoltiScreen extends StatefulWidget {
  const RaccoltiScreen({super.key});

  @override
  State<RaccoltiScreen> createState() => _RaccoltiScreenState();
}

class _RaccoltiScreenState extends State<RaccoltiScreen> {
  List<Raccolto> _raccolti = [];
  List<Verdura> _verdure = [];
  Verdura? _filtroVerdura;
  int? _filtroMese;
  int? _filtroAnno;
  bool _isLoading = true;

  final List<String> _mesi = [
    'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
  ];

  @override
  void initState() {
    super.initState();
    _filtroAnno = DateTime.now().year;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getVerdure(),
        ApiService.getRaccolti(
          verduraId: _filtroVerdura?.id,
          mese: _filtroMese,
          anno: _filtroAnno,
        ),
      ]);
      setState(() {
        _verdure = results[0] as List<Verdura>;
        _raccolti = results[1] as List<Raccolto>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nel caricamento dei raccolti'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRaccolto(Raccolto raccolto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina raccolto'),
        content: Text(
            'Elimini il raccolto di ${raccolto.verdura.nome} del ${DateFormat('dd/MM/yyyy').format(raccolto.data)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.deleteRaccolto(raccolto.id);
        setState(() => _raccolti.remove(raccolto));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errore nella cancellazione'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildFiltri() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<Verdura?>(
              value: _filtroVerdura,
              decoration: const InputDecoration(
                labelText: 'Verdura',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tutte')),
                ..._verdure.map((v) => DropdownMenuItem(value: v, child: Text(v.nome))),
              ],
              onChanged: (v) {
                setState(() => _filtroVerdura = v);
                _loadData();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<int?>(
              value: _filtroMese,
              decoration: const InputDecoration(
                labelText: 'Mese',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tutti')),
                ...List.generate(12, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_mesi[i]),
                )),
              ],
              onChanged: (m) {
                setState(() => _filtroMese = m);
                _loadData();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<int?>(
              value: _filtroAnno,
              decoration: const InputDecoration(
                labelText: 'Anno',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: List.generate(5, (i) {
                final anno = DateTime.now().year - i;
                return DropdownMenuItem(value: anno, child: Text(anno.toString()));
              }),
              onChanged: (a) {
                setState(() => _filtroAnno = a);
                _loadData();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raccolti')),
      body: Column(
        children: [
          _buildFiltri(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _raccolti.isEmpty
                    ? const Center(child: Text('Nessun raccolto trovato'))
                    : ListView.builder(
                        itemCount: _raccolti.length,
                        itemBuilder: (context, index) {
                          final raccolto = _raccolti[index];
                          return ListTile(
                            leading: const Icon(Icons.scale),
                            title: Text(raccolto.verdura.nome),
                            subtitle: Text(
                                DateFormat('dd/MM/yyyy').format(raccolto.data)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${raccolto.peso}g',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _deleteRaccolto(raccolto),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}