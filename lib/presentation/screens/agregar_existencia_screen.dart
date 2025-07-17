import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/proveedor.dart';
import 'package:sazones_semanales/domain/entities/producto_base.dart';
import 'package:sazones_semanales/presentation/providers/agregar_existencia_provider.dart';
import 'package:sazones_semanales/presentation/widgets/barcode_scanner_button.dart';
import 'package:sazones_semanales/presentation/widgets/image_capture_widget.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

// Referencias explícitas a las clases para evitar advertencias de imports no utilizados
// ignore: unused_element
final _tipoProveedor = Proveedor;
// ignore: unused_element
final _tipoProductoBase = ProductoBase;

class AgregarExistenciaScreen extends StatelessWidget {
  const AgregarExistenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AgregarExistenciaProvider(context),
      child: const _AgregarExistenciaScreenContent(),
    );
  }
}

class _AgregarExistenciaScreenContent extends StatefulWidget {
  const _AgregarExistenciaScreenContent();

  @override
  State<_AgregarExistenciaScreenContent> createState() =>
      _AgregarExistenciaScreenContentState();
}

class _AgregarExistenciaScreenContentState
    extends State<_AgregarExistenciaScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _codigoBarrasController = TextEditingController();
  final _nombreProductoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precioController = TextEditingController();
  DateTime _fechaCompra = DateTime.now();
  DateTime? _fechaCaducidad;
  TipoPerecibilidad _perecibilidad = TipoPerecibilidad.semiPerecedero;

  @override
  void dispose() {
    _codigoBarrasController.dispose();
    _nombreProductoController.dispose();
    _categoriaController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AgregarExistenciaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agregar Producto',
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
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(context, provider),
    );
  }

  Widget _buildForm(BuildContext context, AgregarExistenciaProvider provider) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCaptureField(provider),
            const SizedBox(height: 16),
            _buildCodigoBarrasField(provider),
            const SizedBox(height: 16),
            _buildNombreProductoField(provider),
            const SizedBox(height: 16),
            _buildCategoriaField(provider),
            const SizedBox(height: 16),
            _buildPrecioField(),
            const SizedBox(height: 16),
            _buildFechaCompraField(context),
            const SizedBox(height: 16),
            _buildPerecibilidadField(),
            const SizedBox(height: 16),
            _buildFechaCaducidadField(context),
            const SizedBox(height: 16),
            _buildProveedorField(provider),
            const SizedBox(height: 24),
            _buildSubmitButton(provider),
            if (provider.errorMensaje.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  provider.errorMensaje,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCaptureField(AgregarExistenciaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto del Producto',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: 8),
        ImageCaptureWidget(
          onImageSelected: (File image) {
            provider.setImagenProducto(image);
          },
          initialImagePath: provider.imagenProducto?.path,
        ),
      ],
    );
  }

  Widget _buildCodigoBarrasField(AgregarExistenciaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código de Barras',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _codigoBarrasController,
                decoration: const InputDecoration(
                  hintText: 'Escanea o ingresa el código de barras',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El código de barras es obligatorio';
                  }
                  if (value.length < 8) {
                    return 'El código debe tener al menos 8 caracteres';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.length >= 8) {
                    provider.buscarProductoPorCodigoBarras(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            BarcodeScannerButton(
              label: 'Escanear',
              onBarcodeScanned: (barcode) {
                _codigoBarrasController.text = barcode;
                provider.buscarProductoPorCodigoBarras(barcode);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNombreProductoField(AgregarExistenciaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre del Producto',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return provider.obtenerSugerenciasNombre(textEditingValue.text);
          },
          onSelected: (String selection) {
            _nombreProductoController.text = selection;
            provider.buscarProductoPorNombre(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Asignar el controller del autocomplete a nuestro controller
            if (_nombreProductoController.text.isEmpty &&
                provider.productoSeleccionado != null) {
              controller.text = provider.productoSeleccionado!.nombre;
              _nombreProductoController.text =
                  provider.productoSeleccionado!.nombre;
            }

            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Ingresa el nombre del producto',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre del producto es obligatorio';
                }
                if (value.length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
              onChanged: (value) {
                _nombreProductoController.text = value;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoriaField(AgregarExistenciaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return provider.categorias;
            }
            return provider.categorias.where((categoria) => categoria
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            _categoriaController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Asignar el controller del autocomplete a nuestro controller
            if (_categoriaController.text.isEmpty &&
                provider.productoSeleccionado != null) {
              controller.text = provider.productoSeleccionado!.categoria;
              _categoriaController.text =
                  provider.productoSeleccionado!.categoria;
            }

            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Selecciona o ingresa una categoría',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La categoría es obligatoria';
                }
                return null;
              },
              onChanged: (value) {
                _categoriaController.text = value;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrecioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Precio',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _precioController,
          decoration: const InputDecoration(
            hintText: 'Ingresa el precio pagado',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El precio es obligatorio';
            }
            final precio = double.tryParse(value);
            if (precio == null || precio <= 0) {
              return 'Ingresa un precio válido mayor a cero';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFechaCompraField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Compra',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _seleccionarFechaCompra(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(_fechaCompra),
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeBody,
                    fontWeight: AppConstants.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _seleccionarFechaCompra(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaCompra,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _fechaCompra = fecha;
      });
    }
  }

  Widget _buildPerecibilidadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tipo de Perecibilidad',
              style: GoogleFonts.getFont(
                AppConstants.primaryFont,
                fontSize: AppConstants.fontSizeSubheading,
                fontWeight: AppConstants.fontWeightBold,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: () => _mostrarAyudaPerecibilidad(context),
              tooltip: 'Información sobre tipos de perecibilidad',
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TipoPerecibilidad>(
          value: _perecibilidad,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Selecciona el tipo de perecibilidad',
          ),
          items: TipoPerecibilidad.values.map((tipo) {
            return DropdownMenuItem<TipoPerecibilidad>(
              value: tipo,
              child: Text(tipo.nombre),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _perecibilidad = value;
              });
            }
          },
        ),
        const SizedBox(height: 4),
        Text(
          _getPerecibilidadDescription(_perecibilidad),
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeCaption,
            fontWeight: AppConstants.fontWeightMedium,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _getPerecibilidadDescription(TipoPerecibilidad tipo) {
    switch (tipo) {
      case TipoPerecibilidad.perecedero:
        return 'Alerta: 2 días antes de caducar. Ej: Carnes frescas, pescado, lácteos abiertos.';
      case TipoPerecibilidad.semiPerecedero:
        return 'Alerta: 5 días antes de caducar. Ej: Frutas, verduras, lácteos cerrados.';
      case TipoPerecibilidad.pocoPerecedero:
        return 'Alerta: 15 días antes de caducar. Ej: Pan envasado, quesos duros, embutidos.';
      case TipoPerecibilidad.noPerecedero:
        return 'Alerta: 90 días antes de caducar. Ej: Enlatados, pasta seca, arroz, especias.';
    }
  }

  void _mostrarAyudaPerecibilidad(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tipos de Perecibilidad',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPerecibilidadInfo(
                'Altamente Perecedero',
                'Productos que se deterioran muy rápidamente y requieren refrigeración constante.',
                'Carnes frescas, pescado, mariscos, lácteos abiertos, comida preparada.',
                '2 días',
                Colors.red,
              ),
              const Divider(),
              _buildPerecibilidadInfo(
                'Medianamente Perecedero',
                'Productos que tienen una vida útil moderada con refrigeración adecuada.',
                'Frutas, verduras, lácteos sin abrir, huevos, embutidos frescos.',
                '5 días',
                Colors.orange,
              ),
              const Divider(),
              _buildPerecibilidadInfo(
                'Poco Perecedero',
                'Productos con vida útil extendida que pueden conservarse en condiciones adecuadas.',
                'Pan envasado, quesos duros, embutidos curados, salsas abiertas.',
                '15 días',
                Colors.amber,
              ),
              const Divider(),
              _buildPerecibilidadInfo(
                'No Perecedero',
                'Productos de larga duración que pueden almacenarse a temperatura ambiente.',
                'Enlatados, pasta seca, arroz, legumbres, especias, aceites.',
                '90 días',
                Colors.green,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerecibilidadInfo(
    String titulo,
    String descripcion,
    String ejemplos,
    String alerta,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeSubheading,
                  fontWeight: AppConstants.fontWeightBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: GoogleFonts.getFont(
              AppConstants.primaryFont,
              fontSize: AppConstants.fontSizeBody,
              fontWeight: AppConstants.fontWeightMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ejemplos: $ejemplos',
            style: GoogleFonts.getFont(
              AppConstants.primaryFont,
              fontSize: AppConstants.fontSizeBody,
              fontWeight: AppConstants.fontWeightMedium,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Alerta: $alerta antes de la fecha de caducidad',
            style: GoogleFonts.getFont(
              AppConstants.primaryFont,
              fontSize: AppConstants.fontSizeBody,
              fontWeight: AppConstants.fontWeightBold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFechaCaducidadField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Caducidad (opcional)',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _seleccionarFechaCaducidad(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.event, size: 20),
                const SizedBox(width: 8),
                Text(
                  _fechaCaducidad != null
                      ? DateFormat('dd/MM/yyyy').format(_fechaCaducidad!)
                      : 'Seleccionar fecha de caducidad',
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeBody,
                    fontWeight: AppConstants.fontWeightMedium,
                    color: _fechaCaducidad != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Spacer(),
                if (_fechaCaducidad != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _fechaCaducidad = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _seleccionarFechaCaducidad(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate:
          _fechaCaducidad ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      setState(() {
        _fechaCaducidad = fecha;
      });
    }
  }

  Widget _buildProveedorField(AgregarExistenciaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proveedor',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeSubheading,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: provider.proveedorSeleccionadoId,
          decoration: const InputDecoration(
            hintText: 'Selecciona un proveedor',
            border: OutlineInputBorder(),
          ),
          items: provider.proveedores.map((proveedor) {
            return DropdownMenuItem<String>(
              value: proveedor.id,
              child: Text('${proveedor.nombre} (${proveedor.tipoNombre})'),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Debes seleccionar un proveedor';
            }
            return null;
          },
          onChanged: (value) {
            if (value != null) {
              provider.seleccionarProveedor(value);
            }
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            // TODO: Implementar navegación a pantalla de agregar proveedor
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Funcionalidad de agregar proveedor pendiente')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Agregar nuevo proveedor'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AgregarExistenciaProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed:
            provider.isSubmitting ? null : () => _guardarExistencia(provider),
        child: provider.isSubmitting
            ? const CircularProgressIndicator()
            : Text(
                'Guardar Producto',
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeButton,
                  fontWeight: AppConstants.fontWeightMedium,
                ),
              ),
      ),
    );
  }

  void _guardarExistencia(AgregarExistenciaProvider provider) async {
    if (_formKey.currentState?.validate() ?? false) {
      final precio = double.tryParse(_precioController.text) ?? 0.0;

      final resultado = await provider.guardarExistencia(
        codigoBarras: _codigoBarrasController.text,
        nombreProducto: _nombreProductoController.text,
        categoria: _categoriaController.text,
        fechaCompra: _fechaCompra,
        fechaCaducidad: _fechaCaducidad,
        precio: precio,
        perecibilidad: _perecibilidad,
      );

      if (resultado && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto agregado correctamente')),
        );
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
      }
    }
  }
}
