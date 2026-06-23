import 'package:flutter/material.dart';
import 'package:nerdgarden_app/models/verdura.dart';
import 'package:nerdgarden_app/services/api_service.dart';

class VerdureScreen extends StatefulWidget {
  const VerdureScreen({super.key});

  @override
  State<VerdureScreen> createState() => _VerdureScreenState();
}

class _VerdureScreenState extends State<VerdureScreen> {
  List<Verdura> _verdure = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerdure();
  }

  Future<void> _loadVerdure() async {
    try {
      final verdure = await ApiService.getVerdure();
      setState(() {
        _verdure = verdure;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nel caricamento delle verdure'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova verdura'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Es. Pomodoro',
            border: OutlineInputBorder(),
          ),
          autofocus: true, //apre tastiera in automatico
          textCapitalization: TextCapitalization.sentences, //prima lettera maiuscola
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _addVerdura(controller.text.trim());
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  Future<void> _addVerdura(String nome) async {
    try {
      final nuova = await ApiService.createVerdura(nome);
      setState(() => _verdure.add(nuova));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore,verdura già esistente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteVerdura(Verdura verdura) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina verdura'),
        content: Text('Sei sicuro di voler eliminare "${verdura.nome}"?'),
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
        await ApiService.deleteVerdura(verdura.id);
        setState(() => _verdure.remove(verdura));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Le mie verdure')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _verdure.isEmpty
              ? const Center(child: Text('Nessuna verdura aggiunta'))
              : ListView.builder(
                  itemCount: _verdure.length,
                  itemBuilder: (context, index) {
                    final verdura = _verdure[index];
                    return ListTile(
                      leading: const Icon(Icons.eco),
                      title: Text(verdura.nome),
                      subtitle: Text(verdura.unita),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteVerdura(verdura),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}