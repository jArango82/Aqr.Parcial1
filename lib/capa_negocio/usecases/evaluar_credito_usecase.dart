import '../entities/usuario_credito.dart';
import '../repositories/central_riesgo_repository.dart';

enum ResultadoCredito { aprobado, rechazado }

class EvaluarCreditoUseCase {
  final CentralRiesgoRepository centralRiesgoRepository;

  EvaluarCreditoUseCase(this.centralRiesgoRepository);

  Future<ResultadoCredito> ejecutar(UsuarioCredito solicitud) async {
    // Regla: El plazo solicitado debe ser entre 1 y 72 meses
    if (solicitud.plazoSolicitado < 1 || solicitud.plazoSolicitado > 72) {
      return ResultadoCredito.rechazado;
    }

    // Regla: Si la balanza es cero o negativa el credito sera negado
    if (solicitud.balanza <= 0) {
      return ResultadoCredito.rechazado;
    }

    final double rcb = solicitud.relacionCreditoBalanza;

    // Regla: Si la relacionCreditoBalanza es igual o superior a 0.95 el credito sera negado
    if (rcb >= 0.95) {
      return ResultadoCredito.rechazado;
    }

    // Obtener puntaje de la central de riesgo
    final int puntaje = await centralRiesgoRepository.obtenerPuntaje(
      solicitud.tipoDoc,
      solicitud.nroDoc,
    );

    // Regla: Si rcb >= 0.7 y < 0.95 -> puntaje >= 800 para aprobar
    if (rcb >= 0.7 && rcb < 0.95) {
      if (puntaje >= 800) {
        return ResultadoCredito.aprobado;
      } else {
        return ResultadoCredito.rechazado;
      }
    }

    // Regla: Si rcb >= 0.4 y < 0.7 -> puntaje >= 600 para aprobar
    if (rcb >= 0.4 && rcb < 0.7) {
      if (puntaje >= 600) {
        return ResultadoCredito.aprobado;
      } else {
        return ResultadoCredito.rechazado;
      }
    }

    // Regla: Si rcb < 0.4 -> puntaje >= 400 para aprobar
    if (rcb < 0.4) {
      if (puntaje >= 400) {
        return ResultadoCredito.aprobado;
      } else {
        return ResultadoCredito.rechazado;
      }
    }

    return ResultadoCredito.rechazado;
  }
}
