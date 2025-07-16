class AppConstants {
  // Database constants
  static const String databaseName = 'inventario_alacena.db';
  static const int databaseVersion = 1;
  
  // Notification constants
  static const String notificationChannelId = 'inventory_notifications';
  static const String notificationChannelName = 'Notificaciones de Inventario';
  static const String notificationChannelDescription = 'Notificaciones para productos próximos a caducar';
  
  // App constants
  static const String appName = 'Gestor de Inventario de Alacena';
  static const int defaultExpirationWarningDays = 3;
  
  // Voice commands
  static const List<String> consumeCommands = [
    'consumir',
    'usar',
    'tomar',
    'gastar',
  ];
}