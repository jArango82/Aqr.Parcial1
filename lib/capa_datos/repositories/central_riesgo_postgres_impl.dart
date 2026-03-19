import 'package:postgres/postgres.dart';
import '../../capa_negocio/repositories/central_riesgo_repository.dart';

class CentralRiesgoPostgresImpl implements CentralRiesgoRepository {
  final Connection connection;

  CentralRiesgoPostgresImpl({required this.connection});

  @override
  Future<int> obtenerPuntaje(String tipoDoc, String nroDoc) async {
    final result = await connection.execute(
      Sql.named(
        'SELECT puntaje FROM DATOS WHERE TipoDoc = @TipoDoc AND NroDOC = @NroDOC',
      ),
      parameters: {'TipoDoc': tipoDoc, 'NroDOC': nroDoc},
    );

    if (result.isEmpty) {
      return 0;
    }

    return result[0][0] as int;
  }
}
