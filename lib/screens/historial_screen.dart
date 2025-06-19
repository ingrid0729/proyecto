import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class HistorialScreen extends StatefulWidget {
  final Database database;
  final int userId;

  const HistorialScreen(
      {super.key, required this.database, required this.userId});

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Map<String, dynamic>> _gastosEliminados = [];

  Future<void> _cargarGastosEliminados() async {
    final datos = await widget.database.query(
      'deleted_expenses',
      where: 'userId = ?',
      whereArgs: [widget.userId],
      orderBy: 'date DESC',
    );
    setState(() {
      _gastosEliminados = datos;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarGastosEliminados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Gastos Eliminados'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _gastosEliminados.isEmpty
          ? const Center(child: Text('No hay gastos eliminados'))
          : ListView.builder(
              itemCount: _gastosEliminados.length,
              itemBuilder: (context, index) {
                final gasto = _gastosEliminados[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(gasto['description'] ?? ''),
                    subtitle: Text(
                        '${gasto['category'] ?? ''} - ${gasto['date'] ?? ''}'),
                    trailing: Text(
                      '\$${(gasto['amount'] as num).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
