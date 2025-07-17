import 'package:flutter/material.dart';

class FiltroCategorias extends StatelessWidget {
  final List<String> categorias;
  final String? categoriaSeleccionada;
  final Function(String?) onCategoriaSeleccionada;

  const FiltroCategorias({
    super.key,
    required this.categorias,
    required this.categoriaSeleccionada,
    required this.onCategoriaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(
          context,
          null,
          'Todas',
        ),
        ...categorias.map((categoria) => _buildChip(
          context,
          categoria,
          categoria,
        )),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String? categoria, String label) {
    final isSelected = categoria == categoriaSeleccionada;
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onCategoriaSeleccionada(categoria),
      backgroundColor: Colors.grey.shade200,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}