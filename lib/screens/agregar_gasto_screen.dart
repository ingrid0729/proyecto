import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class AgregarGastoScreen extends StatefulWidget {
  final Database database;
  final int userId;

  AgregarGastoScreen({required this.database, required this.userId});

  @override
  _AgregarGastoScreenState createState() => _AgregarGastoScreenState();
}

class _AgregarGastoScreenState extends State<AgregarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();

  final List<String> _categorias = [
    'Comida',
    'Transporte',
    'Salud',
    'Entretenimiento',
    'Otros'
  ];
  String? _categoriaSeleccionada = 'Comida';

  Future<void> _guardarGasto() async {
    if (_formKey.currentState!.validate()) {
      final descripcion = _descripcionController.text;
      final monto = double.parse(_montoController.text);
      final fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await widget.database.insert(
        'expenses', // Asegúrate de usar la tabla correcta
        {
          'userId': widget.userId,
          'description': descripcion,
          'amount': monto,
          'date': fecha,
          'category': _categoriaSeleccionada,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Gasto')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa una descripción' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                decoration: InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa el monto' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: InputDecoration(labelText: 'Categoría'),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarGasto,
                child: Text('Guardar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
