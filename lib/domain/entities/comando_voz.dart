/// Model class for voice commands
class ComandoVoz {
  /// Map of product names to quantities
  final Map<String, int> productos;
  
  /// Original text of the command
  final String textoOriginal;
  
  /// Constructor
  ComandoVoz({
    required this.productos,
    required this.textoOriginal,
  });
  
  /// Creates a ComandoVoz from a text command
  factory ComandoVoz.fromText(String text) {
    final Map<String, int> productos = {};
    
    // Normalize text (lowercase, remove accents)
    final normalizedText = text.toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
    
    // Common patterns for consumption commands in Spanish
    final patterns = [
      // "Voy a usar X de Y"
      RegExp(r'voy a (usar|gastar|consumir) (\d+) (?:de |)(.+?)(?:$|y|,|\s+)'),
      // "Usaré X de Y"
      RegExp(r'(usar[eé]|gastar[eé]|consumir[eé]) (\d+) (?:de |)(.+?)(?:$|y|,|\s+)'),
      // "X de Y"
      RegExp(r'(\d+) (?:de |)(.+?)(?:$|y|,|\s+)'),
      // "Necesito X de Y"
      RegExp(r'(?:necesito|quiero|voy a necesitar) (\d+) (?:de |)(.+?)(?:$|y|,|\s+)'),
      // "Voy a cocinar con X de Y"
      RegExp(r'(?:voy a cocinar|cocinar[eé]|preparar[eé]) con (\d+) (?:de |)(.+?)(?:$|y|,|\s+)'),
    ];
    
    for (final pattern in patterns) {
      final matches = pattern.allMatches(normalizedText);
      
      for (final match in matches) {
        int quantity;
        String product;
        
        if (match.groupCount == 3) {
          // First pattern: "Voy a usar X de Y"
          quantity = int.parse(match.group(2)!);
          product = match.group(3)!.trim();
        } else if (match.groupCount == 2) {
          // Third pattern: "X de Y"
          quantity = int.parse(match.group(1)!);
          product = match.group(2)!.trim();
        } else {
          continue;
        }
        
        // Handle plural forms
        if (product.endsWith('s') && !product.endsWith('es')) {
          // Simple plural (e.g., "manzanas" -> "manzana")
          product = product.substring(0, product.length - 1);
        } else if (product.endsWith('es')) {
          // Complex plural (e.g., "limones" -> "limon")
          product = product.substring(0, product.length - 2);
        }
        
        // Add to map or update quantity if product already exists
        productos.update(
          product,
          (value) => value + quantity,
          ifAbsent: () => quantity,
        );
      }
    }
    
    return ComandoVoz(
      productos: productos,
      textoOriginal: text,
    );
  }
  
  @override
  String toString() {
    return 'ComandoVoz{productos: $productos, textoOriginal: $textoOriginal}';
  }
}