class UsuarioCredito {
  final String tipoDoc;
  final String nroDoc;
  final double ingresosTotales;
  final double egresosTotales;
  final double montoSolicitado;
  final int plazoSolicitado;

  UsuarioCredito({
    required this.tipoDoc,
    required this.nroDoc,
    required this.ingresosTotales,
    required this.egresosTotales,
    required this.montoSolicitado,
    required this.plazoSolicitado,
  });

  double get balanza => ingresosTotales - egresosTotales;
  double get relacionCreditoBalanza {
    if (balanza == 0) return double.infinity;
    return (montoSolicitado / plazoSolicitado) / balanza;
  }
}
