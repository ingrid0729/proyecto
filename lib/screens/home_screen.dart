import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'gastos_filtrados_screen.dart';
import 'auth_screen.dart';
import 'agregar_gasto_screen.dart';
import 'editar_gasto_screen.dart';
import 'package:gastos_personales/screens/historial_screen.dart';

class HomeScreen extends StatefulWidget {
  final Database database;
  final int userId;

  const HomeScreen({required this.database, required this.userId, super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _gastos = [];
  List<Map<String, dynamic>> _gastosFiltrados = [];
  String _nombreUsuario = '';
  String _categoriaSeleccionada = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
    _cargarGastos();
  }

  Future<void> _cargarNombreUsuario() async {
    final usuarios = await widget.database.query(
      'users',
      where: 'id = ?',
      whereArgs: [widget.userId],
    );
    if (usuarios.isNotEmpty) {
      setState(() {
        _nombreUsuario = usuarios.first['name']?.toString() ?? '';
      });
    }
  }

  Future<void> _cargarGastos() async {
    final datos = await widget.database.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [widget.userId],
      orderBy: 'date DESC',
    );
    setState(() {
      _gastos = datos;
      _filtrarGastos();
    });
  }

  void _filtrarGastos() {
    if (_categoriaSeleccionada == 'Todas') {
      _gastosFiltrados = List.from(_gastos);
    } else {
      _gastosFiltrados = _gastos
          .where((gasto) => gasto['category'] == _categoriaSeleccionada)
          .toList();
    }
  }

  Future<void> _eliminarGasto(int gastoId) async {
    final gasto = await widget.database.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [gastoId],
      limit: 1,
    );
    if (gasto.isNotEmpty) {
      final g = gasto.first;
      await widget.database.insert('deleted_expenses', g);
    }

    await widget.database.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [gastoId],
    );

    await _cargarGastos();
  }

  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen(database: widget.database)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> categorias = ['Todas'];
    categorias.addAll({
      ..._gastos.map((g) => g['category'] as String? ?? ''),
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, $_nombreUsuario'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              accountName: Text(_nombreUsuario),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/logo.png'),
              ),
            ),
            _crearOpcion(Icons.history, 'Historial', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistorialScreen(
                    database: widget.database,
                    userId: widget.userId,
                  ),
                ),
              );
            }),
            Divider(),
            _crearOpcion(Icons.calendar_view_month, 'Gastos por Mes', () {
              final now = DateTime.now();
              final inicio = DateTime(now.year, now.month, 1);
              final fin = DateTime(now.year, now.month + 1, 0);
              _irAGastosFiltrados('Gastos del Mes', inicio, fin);
            }),
            _crearOpcion(Icons.calendar_view_week, 'Gastos por Semana', () {
              final now = DateTime.now();
              final inicio = now.subtract(Duration(days: now.weekday - 1));
              final fin = inicio.add(Duration(days: 6));
              _irAGastosFiltrados('Gastos de la Semana', inicio, fin);
            }),
            _crearOpcion(Icons.calendar_today, 'Gastos por Día', () {
              final now = DateTime.now();
              final inicio = DateTime(now.year, now.month, now.day);
              final fin =
                  inicio.add(Duration(days: 1)).subtract(Duration(seconds: 1));
              _irAGastosFiltrados('Gastos del Día', inicio, fin);
            }),
            Divider(),
            _crearOpcion(Icons.settings, 'Configuración', () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Aquí iría Configuración')),
              );
            }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Filtrar por Categoría',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
              value: _categoriaSeleccionada,
              items: categorias
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (valor) {
                setState(() {
                  _categoriaSeleccionada = valor ?? 'Todas';
                  _filtrarGastos();
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: _gastosFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        'No hay gastos registrados',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _gastosFiltrados.length,
                      itemBuilder: (context, index) {
                        final gasto = _gastosFiltrados[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(
                              gasto['description'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${gasto['category']} • ${gasto['date']}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              children: [
                                Text(
                                  '\$${(gasto['amount'] as num).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green[700],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Eliminar gasto',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text('Confirmar eliminación'),
                                        content: Text('¿Eliminar este gasto?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true &&
                                        gasto['id'] != null) {
                                      await _eliminarGasto(gasto['id'] as int);
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarGastoScreen(
                                    database: widget.database,
                                    gasto: gasto,
                                  ),
                                ),
                              );
                              if (result == true) {
                                _cargarGastos();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, size: 30),
        tooltip: 'Agregar nuevo gasto',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AgregarGastoScreen(
                database: widget.database,
                userId: widget.userId,
              ),
            ),
          );
          _cargarGastos();
        },
      ),
    );
  }

  ListTile _crearOpcion(IconData icon, String texto, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        texto,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _irAGastosFiltrados(String titulo, DateTime inicio, DateTime fin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GastosFiltradosScreen(
          database: widget.database,
          userId: widget.userId,
          startDate: inicio,
          endDate: fin,
          titulo: titulo,
        ),
      ),
    );
  }
}
