import 'package:flutter/material.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/infrastructure/repositories/repository_providers.dart';
import 'package:sazones_semanales/presentation/widgets/speech_recognition_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sazones_semanales/infrastructure/di/service_locator.dart';

/// Pantalla para consumir productos mediante comandos de voz
class ConsumoPorVozScreen extends StatefulWidget {
  /// Constructor
  const ConsumoPorVozScreen({super.key});

  @override
  State<ConsumoPorVozScreen> createState() => _ConsumoPorVozScreenState();
}

class _ConsumoPorVozScreenState extends State<ConsumoPorVozScreen> {
  /// El último texto reconocido
  String? _lastRecognizedText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Registrar servicios dependientes del contexto
    ServiceLocator.registerContextDependentServices(context);
  }

  /// Los productos y cantidades reconocidos
  Map<String, int> _recognizedProducts = {};

  /// Las existencias encontradas que coinciden con los productos reconocidos
  Map<String, List<Existencia>> _existenciasEncontradas = {};

  /// Indica si se está buscando existencias
  bool _isBuscando = false;

  /// Indica si se está marcando existencias como consumidas
  bool _isConsumiendo = false;

  /// Existencias seleccionadas para consumir
  final Map<String, List<String>> _existenciasSeleccionadas = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Consumo por Voz',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeAppBarTitle,
            fontWeight: AppConstants.fontWeightBold,
            color: AppConstants.appBarForegroundColor,
          ),
        ),
        backgroundColor: AppConstants.appBarBackgroundColor,
        foregroundColor: AppConstants.appBarForegroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instrucciones:',
              style: GoogleFonts.getFont(
                AppConstants.primaryFont,
                fontSize: AppConstants.fontSizeSubheading,
                fontWeight: AppConstants.fontWeightBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona el botón y di algo como:\n'
              '- "Voy a usar 2 manzanas y 1 limón"\n'
              '- "Consumiré 3 huevos y 2 tomates"\n'
              '- "Gastaré 1 paquete de pasta"',
              style: GoogleFonts.getFont(
                AppConstants.primaryFont,
                fontSize: AppConstants.fontSizeBody,
                fontWeight: AppConstants.fontWeightMedium,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SpeechRecognitionButton(
                    onTextRecognized: (text) {
                      setState(() {
                        _lastRecognizedText = text;
                      });
                    },
                    onProductsRecognized: (products) {
                      setState(() {
                        _recognizedProducts = products;
                        _existenciasEncontradas.clear();
                        _existenciasSeleccionadas.clear();
                      });

                      if (products.isNotEmpty) {
                        _buscarExistencias(products);
                      }
                    },
                    label: 'Hablar para consumir',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_lastRecognizedText != null) ...[
              Text(
                'Texto reconocido:',
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeSubheading,
                  fontWeight: AppConstants.fontWeightBold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lastRecognizedText!,
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeBody,
                  fontWeight: AppConstants.fontWeightMedium,
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (_isBuscando) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Buscando productos...'),
                  ],
                ),
              ),
            ] else if (_recognizedProducts.isNotEmpty) ...[
              Expanded(
                child: _buildProductList(),
              ),
              if (_tieneProductosSeleccionados()) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isConsumiendo ? null : _consumirSeleccionados,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isConsumiendo
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Consumir Seleccionados',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// Construye la lista de productos reconocidos con sus existencias
  Widget _buildProductList() {
    if (_existenciasEncontradas.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron existencias para los productos mencionados',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return ListView.builder(
      itemCount: _existenciasEncontradas.length,
      itemBuilder: (context, index) {
        final productName = _existenciasEncontradas.keys.elementAt(index);
        final existencias = _existenciasEncontradas[productName]!;
        final cantidadSolicitada = _recognizedProducts[productName] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Cantidad solicitada: $cantidadSolicitada',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${existencias.length} disponibles',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: existencias.length,
                itemBuilder: (context, i) {
                  final existencia = existencias[i];
                  final isSelected = _existenciasSeleccionadas[productName]
                          ?.contains(existencia.id) ??
                      false;

                  return CheckboxListTile(
                    title: Text(existencia.nombreProducto),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Comprado: ${_formatDate(existencia.fechaCompra)}'),
                        if (existencia.fechaCaducidad != null)
                          Text(
                              'Caduca: ${_formatDate(existencia.fechaCaducidad!)}'),
                        Text(
                            'Precio: \$${existencia.precio.toStringAsFixed(2)}'),
                      ],
                    ),
                    secondary: existencia.estaProximaACaducar
                        ? const Icon(Icons.warning, color: Colors.orange)
                        : null,
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _existenciasSeleccionadas
                              .putIfAbsent(productName, () => [])
                              .add(existencia.id);
                        } else {
                          _existenciasSeleccionadas[productName]
                              ?.remove(existencia.id);
                          if (_existenciasSeleccionadas[productName]?.isEmpty ??
                              false) {
                            _existenciasSeleccionadas.remove(productName);
                          }
                        }
                      });
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Busca existencias para los productos reconocidos
  Future<void> _buscarExistencias(Map<String, int> products) async {
    setState(() {
      _isBuscando = true;
    });

    try {
      // Guardar el contexto antes de la operación asíncrona
      final currentContext = context;
      final repository =
          RepositoryProviders.getExistenciaRepository(currentContext);
      final Map<String, List<Existencia>> resultados = {};

      for (final productName in products.keys) {
        // Buscar existencias disponibles que coincidan con el nombre del producto
        final existencias =
            await repository.buscarPorNombreProducto(productName);

        // Filtrar solo las existencias disponibles
        final disponibles = existencias.where((e) => e.estaDisponible).toList();

        // Ordenar por fecha de caducidad (primero las que caducan antes)
        disponibles.sort((a, b) {
          if (a.fechaCaducidad == null && b.fechaCaducidad == null) return 0;
          if (a.fechaCaducidad == null) return 1;
          if (b.fechaCaducidad == null) return -1;
          return a.fechaCaducidad!.compareTo(b.fechaCaducidad!);
        });

        if (disponibles.isNotEmpty) {
          resultados[productName] = disponibles;
        }
      }

      // Verificar si el widget sigue montado antes de actualizar el estado
      if (mounted) {
        setState(() {
          _existenciasEncontradas = resultados;
          _isBuscando = false;
        });
      }
    } catch (e) {
      // Verificar si el widget sigue montado antes de actualizar el estado
      if (mounted) {
        setState(() {
          _isBuscando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar existencias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Marca las existencias seleccionadas como consumidas
  Future<void> _consumirSeleccionados() async {
    setState(() {
      _isConsumiendo = true;
    });

    try {
      // Guardar el contexto antes de la operación asíncrona
      final currentContext = context;
      final repository =
          RepositoryProviders.getExistenciaRepository(currentContext);
      final List<String> idsAConsumir = [];

      // Recopilar todos los IDs de existencias seleccionadas
      for (final productIds in _existenciasSeleccionadas.values) {
        idsAConsumir.addAll(productIds);
      }

      // Marcar todas las existencias como consumidas
      await repository.marcarMultiplesComoConsumidas(idsAConsumir);

      // Verificar si el widget sigue montado antes de actualizar el estado
      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Productos marcados como consumidos correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar selecciones
        setState(() {
          _existenciasSeleccionadas.clear();
          _existenciasEncontradas.clear();
          _recognizedProducts.clear();
          _lastRecognizedText = null;
          _isConsumiendo = false;
        });
      }
    } catch (e) {
      // Verificar si el widget sigue montado antes de actualizar el estado
      if (mounted) {
        setState(() {
          _isConsumiendo = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al consumir productos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Verifica si hay productos seleccionados para consumir
  bool _tieneProductosSeleccionados() {
    return _existenciasSeleccionadas.isNotEmpty;
  }

  /// Formatea una fecha para mostrarla en la UI
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
