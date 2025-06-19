import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class GastosFiltradosScreen extends StatefulWidget {
  final Database database;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;
  final String titulo;

  GastosFiltradosScreen({
    required this.database,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.titulo,
  });

  @override
  _GastosFiltradosScreenState createState() => _GastosFiltradosScreenState();
}

class _GastosFiltradosScreenState extends State<GastosFiltradosScreen> {
  List<Map<String, dynamic>> _gastos = [];

  @override
  void initState() {
    super.initState();
    _cargarGastosFiltrados();
  }

  Future<void> _cargarGastosFiltrados() async {
    final gastos = await widget.database.query(
      'expenses',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [
        widget.userId,
        widget.startDate.toIso8601String(),
        widget.endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    setState(() {
      _gastos = gastos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: _gastos.isEmpty
          ? Center(child: Text('No hay gastos registrados'))
          : ListView.builder(
              itemCount: _gastos.length,
              itemBuilder: (context, index) {
                final gasto = _gastos[index];
                return ListTile(
                  title: Text(gasto['description']),
                  subtitle: Text('${gasto['category']} - ${gasto['date']}'),
                  trailing:
                      Text('\$${(gasto['amount'] as num).toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}
