// import 'package:sazones_semanales/lib/src/backend/database_service.dart'; // 👈 Asegúrate de importar aquí también
import 'package:flutter/material.dart';
import 'package:sazones_semanales/src/frontend/views/home/homepage_viewmodel.dart'; // 👈 Importa el estado

class HomePageView extends StatefulWidget {
  final String title;
  const HomePageView({Key? key, required this.title}) : super(key: key);

  @override
  State<HomePageView> createState() => HomePageViewModel();
}
