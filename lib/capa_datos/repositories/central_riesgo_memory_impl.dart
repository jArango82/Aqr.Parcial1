import '../../capa_negocio/repositories/central_riesgo_repository.dart';

class CentralRiesgoMemoryImpl implements CentralRiesgoRepository {
  // Simulación de una base de datos en memoria para el puntaje por documento.
  final Map<String, int> _bdEnMemoria = {
    '12234587': 563,
    '11111111': 850,
    '22222222': 650,
    '33333333': 450,
    '44444444': 300,
  };

  @override
  Future<int> obtenerPuntaje(String tipoDoc, String nroDoc) async {
    // Simulamos un pequeño retraso de red
    await Future.delayed(const Duration(milliseconds: 500));
    return _bdEnMemoria[nroDoc] ?? 0;
  }
}
