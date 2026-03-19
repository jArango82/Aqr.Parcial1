import 'package:flutter/material.dart';
import '../capa_negocio/entities/usuario_credito.dart';
import '../capa_negocio/usecases/evaluar_credito_usecase.dart';

class CreditoScreen extends StatefulWidget {
  final EvaluarCreditoUseCase evaluarCreditoUseCase;

  const CreditoScreen({super.key, required this.evaluarCreditoUseCase});

  @override
  State<CreditoScreen> createState() => _CreditoScreenState();
}

class _CreditoScreenState extends State<CreditoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tipoDoc = 'CC';
  final _nroDocCtrl = TextEditingController();
  final _ingresosCtrl = TextEditingController();
  final _egresosCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();

  bool _isLoading = false;

  void _evaluar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Usamos un ligero delay simulado intencional de interfaz
      await Future.delayed(const Duration(milliseconds: 600));

      final solicitud = UsuarioCredito(
        tipoDoc: _tipoDoc,
        nroDoc: _nroDocCtrl.text,
        ingresosTotales: double.parse(_ingresosCtrl.text),
        egresosTotales: double.parse(_egresosCtrl.text),
        montoSolicitado: double.parse(_montoCtrl.text),
        plazoSolicitado: int.parse(_plazoCtrl.text),
      );

      final resultado = await widget.evaluarCreditoUseCase.ejecutar(solicitud);

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      _mostrarDialogoResultado(resultado);
    }
  }

  void _mostrarDialogoResultado(ResultadoCredito resultado) {
    final bool esAprobado = resultado == ResultadoCredito.aprobado;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            children: [
              Icon(
                esAprobado ? Icons.check_circle : Icons.cancel,
                color: esAprobado ? Colors.green : Colors.red,
                size: 60,
              ),
              const SizedBox(height: 10),
              Text(
                esAprobado ? '¡Crédito Aprobado!' : 'Crédito Rechazado',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        content: Text(
          esAprobado 
            ? '¡Felicidades! Tienes un perfil crediticio excelente y cumples con las reglas de negocio exigidas.'
            : 'Lo sentimos, tu solicitud no cumple con los requisitos financieros necesarios o tu puntuación de riesgo es insuficiente.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context), 
            child: const Text('Comprendido', style: TextStyle(fontSize: 16)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Preaprobación de Crédito', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.real_estate_agent, size: 60, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 10),
        const Text(
          'Solicitud de Crédito Libre',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        const Text(
          'Ingresa tus datos para evaluar el riesgo en segundos.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        )
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDropdownField(),
              const SizedBox(height: 15),
              _buildTextField(_nroDocCtrl, 'Número de Documento', Icons.numbers, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField(_ingresosCtrl, 'Ingresos Totales', Icons.attach_money, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField(_egresosCtrl, 'Egresos Totales', Icons.money_off, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField(_montoCtrl, 'Monto Solicitado', Icons.account_balance_wallet, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField(_plazoCtrl, 'Plazo (Meses)', Icons.calendar_month, isNumber: true),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _evaluar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('EVALUAR CRÉDITO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      initialValue: _tipoDoc,
      decoration: InputDecoration(
        labelText: 'Tipo de Documento',
        prefixIcon: Icon(Icons.badge, color: Theme.of(context).colorScheme.primary.withAlpha(178)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'CC', child: Text('Cédula de Ciudadanía (CC)')),
        DropdownMenuItem(value: 'CE', child: Text('Cédula de Extranjería (CE)')),
      ],
      onChanged: (String? value) {
        if (value != null) {
          setState(() => _tipoDoc = value);
        }
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {required bool isNumber}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) {
        if (val == null || val.isEmpty) return 'Requerido';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary.withAlpha(178)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
