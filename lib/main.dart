import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import 'capa_datos/repositories/central_riesgo_memory_impl.dart';
import 'capa_datos/repositories/central_riesgo_postgres_impl.dart';
import 'capa_negocio/repositories/central_riesgo_repository.dart';
import 'capa_negocio/usecases/evaluar_credito_usecase.dart';
import 'capa_presentacion/credito_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  CentralRiesgoRepository repository;
  
  String host = '127.0.0.1';
  try {
    if (Platform.isAndroid) {
      host = '10.0.2.2';
    }
  } catch(e) {
    // Es intencional, en web Platform.isAndroid arroja error
  }
  
  try {
    final connection = await Connection.open(
      Endpoint(
        host: host,
        database: 'Centrales_Riesgo',
        port: 5432,
        username: 'postgres',
        password: '070320',
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable, // Necesario para pruebas locales
      ),
    );
    
    debugPrint('✅ Conexión a PostgreSQL establecida en \$host');
    repository = CentralRiesgoPostgresImpl(connection: connection);
    
  } catch (e) {
    debugPrint('❌ Error conectando a PostgreSQL: \$e');
    debugPrint('⚠️ Haciendo Fallback a Repositorio en Memoria');
    repository = CentralRiesgoMemoryImpl();
  }
  
  final useCase = EvaluarCreditoUseCase(repository);

  runApp(MyApp(useCase: useCase));
}

class MyApp extends StatelessWidget {
  final EvaluarCreditoUseCase useCase;

  const MyApp({super.key, required this.useCase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consultar Crédito',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C81), // Azul clásico e institucional
          secondary: const Color(0xFFF9A826), // Acento moderno
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Fuente estándar limpia
      ),
      home: CreditoScreen(evaluarCreditoUseCase: useCase),
    );
  }
}
