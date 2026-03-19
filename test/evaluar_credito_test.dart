import 'package:flutter_test/flutter_test.dart';
import 'package:parcial1/capa_negocio/entities/usuario_credito.dart';
import 'package:parcial1/capa_negocio/repositories/central_riesgo_repository.dart';
import 'package:parcial1/capa_negocio/usecases/evaluar_credito_usecase.dart';

class MockCentralRiesgo implements CentralRiesgoRepository {
  final int puntajeFake;
  MockCentralRiesgo(this.puntajeFake);

  @override
  Future<int> obtenerPuntaje(String tipoDoc, String nroDoc) async {
    return puntajeFake;
  }
}

void main() {
  group('EvaluarCreditoUseCase Pruebas', () {
    test('Rechaza si el plazo solicitado es menor a 1 o mayor a 72', () async {
      final fakeRepo = MockCentralRiesgo(1000);
      final useCase = EvaluarCreditoUseCase(fakeRepo);
      
      final creditoInvalido = UsuarioCredito(
        tipoDoc: 'CC', nroDoc: '111', 
        ingresosTotales: 3000, egresosTotales: 1000, 
        montoSolicitado: 5000, plazoSolicitado: 80, // mayor a 72
      );

      final resultado = await useCase.ejecutar(creditoInvalido);
      expect(resultado, ResultadoCredito.rechazado);
    });

    test('Rechaza automáticamente si la balanza es menor o igual a 0', () async {
      final fakeRepo = MockCentralRiesgo(1000);
      final useCase = EvaluarCreditoUseCase(fakeRepo);
      
      // Balanza = 1000 - 1000 = 0
      final creditoBalanzaCero = UsuarioCredito(
        tipoDoc: 'CC', nroDoc: '111', 
        ingresosTotales: 1000, egresosTotales: 1000, 
        montoSolicitado: 5000, plazoSolicitado: 12,
      );

      final resultado = await useCase.ejecutar(creditoBalanzaCero);
      expect(resultado, ResultadoCredito.rechazado);
    });

    test('Rechaza si la RelacionCreditoBalanza (RCB) es >= 0.95', () async {
      final fakeRepo = MockCentralRiesgo(1000); // Aunque el puntaje sea alto
      final useCase = EvaluarCreditoUseCase(fakeRepo);
      
      // Balanza = 2000 - 1000 = 1000
      // Cuota = 10000 / 10 = 1000
      // RCB = 1000 / 1000 = 1.0 (que es >= 0.95)
      final creditoAltoRiesgo = UsuarioCredito(
        tipoDoc: 'CC', nroDoc: '111', 
        ingresosTotales: 2000, egresosTotales: 1000, 
        montoSolicitado: 10000, plazoSolicitado: 10,
      );

      final resultado = await useCase.ejecutar(creditoAltoRiesgo);
      expect(resultado, ResultadoCredito.rechazado);
    });

    test('Aprueba si RCB entre 0.7 y 0.95, con puntaje >= 800', () async {
      final fakeRepo = MockCentralRiesgo(810);
      final useCase = EvaluarCreditoUseCase(fakeRepo);
      
      // Balanza = 2000 - 1000 = 1000
      // Cuota = 9000 / 10 = 900. RCB = 900/1000 = 0.90
      final credito = UsuarioCredito(
        tipoDoc: 'CC', nroDoc: '12234587', 
        ingresosTotales: 2000, egresosTotales: 1000, 
        montoSolicitado: 9000, plazoSolicitado: 10,
      );

      final resultado = await useCase.ejecutar(credito);
      expect(resultado, ResultadoCredito.aprobado);
    });

    test('Rechaza si RCB entre 0.7 y 0.95, con puntaje < 800', () async {
      final fakeRepo = MockCentralRiesgo(790); // Fallaría aquí
      final useCase = EvaluarCreditoUseCase(fakeRepo);
      
      final credito = UsuarioCredito(
        tipoDoc: 'CC', nroDoc: '12234587', 
        ingresosTotales: 2000, egresosTotales: 1000, 
        montoSolicitado: 9000, plazoSolicitado: 10,
      );

      final resultado = await useCase.ejecutar(credito);
      expect(resultado, ResultadoCredito.rechazado);
    });
    
    test('Aprueba si RCB entre 0.4 y 0.7, con puntaje >= 600', () async {
      final fakeRepo = MockCentralRiesgo(650);
      final useCase = EvaluarCreditoUseCase(fakeRepo);
      
      // Balanza = 2000 - 1000 = 1000
      // Cuota = 5000 / 10 = 500. RCB = 500/1000 = 0.50
      final credito = UsuarioCredito(
        tipoDoc: 'CC', nroDoc: '12234587', 
        ingresosTotales: 2000, egresosTotales: 1000, 
        montoSolicitado: 5000, plazoSolicitado: 10,
      );

      final resultado = await useCase.ejecutar(credito);
      expect(resultado, ResultadoCredito.aprobado);
    });

    test('Aprueba si RCB < 0.4, con puntaje >= 400', () async {
      final fakeRepo = MockCentralRiesgo(450);
      final useCase = EvaluarCreditoUseCase(fakeRepo);
      
      // Balanza = 2000 - 1000 = 1000
      // Cuota = 3000 / 10 = 300. RCB = 300/1000 = 0.30
      final credito = UsuarioCredito(
        tipoDoc: 'CC', nroDoc: '12234587', 
        ingresosTotales: 2000, egresosTotales: 1000, 
        montoSolicitado: 3000, plazoSolicitado: 10,
      );

      final resultado = await useCase.ejecutar(credito);
      expect(resultado, ResultadoCredito.aprobado);
    });
  });
}
