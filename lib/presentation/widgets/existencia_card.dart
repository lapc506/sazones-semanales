import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';

class ExistenciaCard extends StatelessWidget {
  final Existencia existencia;
  final VoidCallback onConsumida;

  const ExistenciaCard({
    super.key,
    required this.existencia,
    required this.onConsumida,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determinar el color de fondo según la proximidad a caducar
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black87;
    
    if (existencia.haCaducado) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade900;
    } else if (existencia.estaProximaACaducar) {
      switch (existencia.perecibilidad) {
        case TipoPerecibilidad.perecedero:
          backgroundColor = Colors.red.shade50;
          textColor = Colors.red.shade900;
          break;
        case TipoPerecibilidad.semiPerecedero:
          backgroundColor = Colors.orange.shade50;
          textColor = Colors.orange.shade900;
          break;
        case TipoPerecibilidad.pocoPerecedero:
          backgroundColor = Colors.amber.shade50;
          textColor = Colors.amber.shade900;
          break;
        case TipoPerecibilidad.noPerecedero:
          backgroundColor = Colors.green.shade50;
          textColor = Colors.green.shade900;
          break;
      }
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: backgroundColor,
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navegar a la pantalla de detalle de existencia
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      existencia.nombreProducto,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  _buildCaducidadIndicator(context),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    existencia.categoria,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(existencia.precio),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Comprado: ${_formatDate(existencia.fechaCompra)}',
                        ),
                        if (existencia.fechaCaducidad != null)
                          _buildInfoRow(
                            Icons.timer_outlined,
                            'Caduca: ${_formatDate(existencia.fechaCaducidad!)}',
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: colorScheme.primary,
                    onPressed: onConsumida,
                    tooltip: 'Marcar como consumido',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaducidadIndicator(BuildContext context) {
    if (existencia.haCaducado) {
      return _buildIndicatorChip(
        context,
        'CADUCADO',
        Colors.red,
      );
    }
    
    if (existencia.estaProximaACaducar) {
      switch (existencia.perecibilidad) {
        case TipoPerecibilidad.perecedero:
          return _buildIndicatorChip(
            context,
            'CADUCA PRONTO',
            Colors.red,
          );
        case TipoPerecibilidad.semiPerecedero:
          return _buildIndicatorChip(
            context,
            'CADUCA PRONTO',
            Colors.orange,
          );
        case TipoPerecibilidad.pocoPerecedero:
          return _buildIndicatorChip(
            context,
            'CADUCA PRONTO',
            Colors.amber,
          );
        case TipoPerecibilidad.noPerecedero:
          return _buildIndicatorChip(
            context,
            'REVISAR',
            Colors.green,
          );
      }
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildIndicatorChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}