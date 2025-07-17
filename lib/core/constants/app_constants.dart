import 'package:flutter/material.dart';

class AppConstants {
  // Database constants
  static const String databaseName = 'inventario_alacena.db';
  static const int databaseVersion = 1;
  
  // Notification constants
  static const String notificationChannelId = 'inventory_notifications';
  static const String notificationChannelName = 'Notificaciones de Inventario';
  static const String notificationChannelDescription = 'Notificaciones para productos próximos a caducar';
  
  // App constants
  static const String appName = 'Sazones Semanales';
  static const String appAuthors = 'Andrés Peña Castillo';
  static const int defaultExpirationWarningDays = 3;
  
  // Voice commands
  static const List<String> consumeCommands = [
    'consumir',
    'usar',
    'tomar',
    'gastar',
  ];
  
  // Typography constants
  static const String primaryFont = 'Montserrat';
  static const String secondaryFont = 'Ubuntu';
  
  // Font sizes
  static const double fontSizeAppBarTitle = 32.0;
  static const double fontSizeHeading = 20.0;
  static const double fontSizeSubheading = 16.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeCaption = 12.0;
  static const double fontSizeButton = 14.0;
  
  // Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
}