import 'package:flutter/material.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';

class FiltroEstados extends StatelessWidget {
  final EstadoExistencia? estadoSeleccionado;
  final Function(EstadoExistencia?) onEstadoSeleccionado;

  const FiltroEstados({
    super.key,
    required this.estadoSeleccionado,
    required this.onEstadoSeleccionado,
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
          'Todos',
        ),
        _buildChip(
          context,
          EstadoExistencia.disponible,
          'Disponibles',
        ),
        _buildChip(
          context,
          EstadoExistencia.consumida,
          'Consumidos',
        ),
        _buildChip(
          context,
          EstadoExistencia.caducada,
          'Caducados',
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, EstadoExistencia? estado, String label) {
    final isSelected = estado == estadoSeleccionado;
    final theme = Theme.of(context);
    
    Color chipColor;
    if (estado == null) {
      chipColor = Colors.grey.shade200;
    } else {
      switch (estado) {
        case EstadoExistencia.disponible:
          chipColor = Colors.green.shade100;
          break;
        case EstadoExistencia.consumida:
          chipColor = Colors.blue.shade100;
          break;
        case EstadoExistencia.caducada:
          chipColor = Colors.red.shade100;
          break;
      }
    }
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onEstadoSeleccionado(estado),
      backgroundColor: chipColor,
      selectedColor: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : chipColor,
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}