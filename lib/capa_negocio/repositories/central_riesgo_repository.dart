abstract class CentralRiesgoRepository {
  /// Devuelve el puntaje en la central de riesgo dado un número de documento.
  Future<int> obtenerPuntaje(String tipoDoc, String nroDoc);
}
