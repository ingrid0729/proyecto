import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_personales/main.dart';
import 'package:gastos_personales/database/db_helper.dart';

void main() {
  testWidgets('Pantalla de Login aparece al iniciar la app',
      (WidgetTester tester) async {
    await tester.runAsync(() => DBHelper.initDb());

    await tester.pumpWidget(MyApp());

    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);
  });
}
