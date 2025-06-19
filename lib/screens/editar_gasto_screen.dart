import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class EditarGastoScreen extends StatefulWidget {
  final Database database;
  final Map<String, dynamic> gasto;

  const EditarGastoScreen(
      {super.key, required this.database, required this.gasto});

  @override
  _EditarGastoScreenState createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  late TextEditingController _descripcionController;
  late TextEditingController _montoController;
  late TextEditingController _categoriaController;

  @override
  void initState() {
    super.initState();
    _descripcionController =
        TextEditingController(text: widget.gasto['description']);
    _montoController =
        TextEditingController(text: widget.gasto['amount'].toString());
    _categoriaController =
        TextEditingController(text: widget.gasto['category']);
  }

  Future<void> _guardarCambios() async {
    await widget.database.update(
      'expenses',
      {
        'description': _descripcionController.text,
        'amount': double.tryParse(_montoController.text) ?? 0,
        'category': _categoriaController.text,
      },
      where: 'id = ?',
      whereArgs: [widget.gasto['id']],
    );

    Navigator.pop(context, true); // Devuelve true para recargar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: 'Motivo'),
            ),
            TextField(
              controller: _montoController,
              decoration: InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _categoriaController,
              decoration: InputDecoration(labelText: 'Categoría'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }
}
