import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/presentation/providers/existencias_provider.dart';
import 'package:sazones_semanales/presentation/screens/agregar_existencia_screen.dart';
import 'package:sazones_semanales/presentation/widgets/existencia_card.dart';
import 'package:sazones_semanales/presentation/widgets/filtro_categorias.dart';
import 'package:sazones_semanales/presentation/widgets/filtro_estados.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ExistenciasScreen extends StatelessWidget {
  const ExistenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExistenciasProvider(context),
      child: const _ExistenciasScreenContent(),
    );
  }
}

class _ExistenciasScreenContent extends StatelessWidget {
  const _ExistenciasScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Existencias en tu Despensa',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: _buildExistenciasList(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AgregarExistenciaScreen(),
            ),
          );

          // Si se agregó una existencia, recargar la lista
          if (result == true) {
            final provider =
                Provider.of<ExistenciasProvider>(context, listen: false);
            provider.recargarExistencias();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final provider = Provider.of<ExistenciasProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: provider.textoBusqueda.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    provider.buscarPorNombre('');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          provider.buscarPorNombre(value);
        },
      ),
    );
  }

  Widget _buildExistenciasList(BuildContext context) {
    final provider = Provider.of<ExistenciasProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.existencias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay productos en tu inventario',
              style: GoogleFonts.getFont(
                AppConstants.primaryFont,
                fontSize: AppConstants.fontSizeHeading,
                fontWeight: AppConstants.fontWeightBold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.textoBusqueda.isNotEmpty ||
                      provider.filtroCategoria != null ||
                      provider.filtroEstado != EstadoExistencia.disponible
                  ? 'Prueba con otros filtros de búsqueda'
                  : 'Agrega productos usando el botón +',
              style: GoogleFonts.getFont(
                AppConstants.primaryFont,
                fontSize: AppConstants.fontSizeBody,
                fontWeight: AppConstants.fontWeightMedium,
                color: Colors.grey,
              ),
            ),
            if (provider.textoBusqueda.isNotEmpty ||
                provider.filtroCategoria != null ||
                provider.filtroEstado != EstadoExistencia.disponible)
              TextButton(
                onPressed: () => provider.limpiarFiltros(),
                child: Text(
                  'Limpiar filtros',
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeButton,
                    fontWeight: AppConstants.fontWeightMedium,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.recargarExistencias(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: provider.existencias.length,
        itemBuilder: (context, index) {
          final existencia = provider.existencias[index];
          return ExistenciaCard(
            existencia: existencia,
            onConsumida: () => provider.marcarComoConsumida(existencia.id),
          );
        },
      ),
    );
  }

  void _mostrarFiltros(BuildContext context) {
    final provider = Provider.of<ExistenciasProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Filtros',
                        style: GoogleFonts.getFont(
                          AppConstants.primaryFont,
                          fontSize: AppConstants.fontSizeHeading,
                          fontWeight: AppConstants.fontWeightBold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Categoría',
                      style: GoogleFonts.getFont(
                        AppConstants.primaryFont,
                        fontSize: AppConstants.fontSizeSubheading,
                        fontWeight: AppConstants.fontWeightBold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FiltroCategorias(
                      categorias: provider.categorias,
                      categoriaSeleccionada: provider.filtroCategoria,
                      onCategoriaSeleccionada: (categoria) {
                        provider.filtrarPorCategoria(categoria);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Estado',
                      style: GoogleFonts.getFont(
                        AppConstants.primaryFont,
                        fontSize: AppConstants.fontSizeSubheading,
                        fontWeight: AppConstants.fontWeightBold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FiltroEstados(
                      estadoSeleccionado: provider.filtroEstado,
                      onEstadoSeleccionado: (estado) {
                        provider.filtrarPorEstado(estado);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.limpiarFiltros();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Limpiar filtros',
                          style: GoogleFonts.getFont(
                            AppConstants.primaryFont,
                            fontSize: AppConstants.fontSizeButton,
                            fontWeight: AppConstants.fontWeightMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
