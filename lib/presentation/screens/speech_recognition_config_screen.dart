import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sazones_semanales/core/config/platform_config.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_service_factory.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla para configurar el reconocimiento de voz
class SpeechRecognitionConfigScreen extends StatefulWidget {
  /// Constructor
  const SpeechRecognitionConfigScreen({super.key});

  @override
  State<SpeechRecognitionConfigScreen> createState() =>
      _SpeechRecognitionConfigScreenState();
}

class _SpeechRecognitionConfigScreenState
    extends State<SpeechRecognitionConfigScreen> {
  final PlatformConfig _platformConfig = PlatformConfig();
  bool _isLoading = true;
  bool _modelExists = false;
  bool _binaryExists = false;
  bool _useCloudFallback = false;
  final TextEditingController _apiKeyController = TextEditingController();

  // Implementación seleccionada
  SpeechRecognitionServiceFactory.SpeechRecognitionImplementation
      _selectedImplementation =
      SpeechRecognitionServiceFactory.getImplementation();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  Future<void> _initConfig() async {
    setState(() {
      _isLoading = true;
    });

    await _platformConfig.initialize();

    _modelExists = await _platformConfig.isWhisperModelAvailable();
    _binaryExists = await _platformConfig.isWhisperBinaryAvailable();
    _useCloudFallback = _platformConfig.useCloudFallback;
    _apiKeyController.text = _platformConfig.cloudApiKey;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración de Reconocimiento de Voz',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeAppBarTitle,
            fontWeight: AppConstants.fontWeightBold,
            color: AppConstants.appBarForegroundColor,
          ),
        ),
        backgroundColor: AppConstants.appBarBackgroundColor,
        foregroundColor: AppConstants.appBarForegroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Implementación de reconocimiento de voz',
                    style: GoogleFonts.getFont(
                      AppConstants.primaryFont,
                      fontSize: AppConstants.fontSizeSubheading,
                      fontWeight: AppConstants.fontWeightBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildImplementationSelector(),
                  const SizedBox(height: 24),
                  if (_selectedImplementation ==
                      SpeechRecognitionServiceFactory
                          .SpeechRecognitionImplementation.whisper) ...[
                    Text(
                      'Configuración de Whisper.cpp',
                      style: GoogleFonts.getFont(
                        AppConstants.primaryFont,
                        fontSize: AppConstants.fontSizeSubheading,
                        fontWeight: AppConstants.fontWeightBold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildWhisperConfig(),
                    const SizedBox(height: 24),
                    _buildFallbackConfig(),
                  ],
                  if (_selectedImplementation ==
                      SpeechRecognitionServiceFactory
                          .SpeechRecognitionImplementation.cloud) ...[
                    Text(
                      'Configuración de API en la nube',
                      style: GoogleFonts.getFont(
                        AppConstants.primaryFont,
                        fontSize: AppConstants.fontSizeSubheading,
                        fontWeight: AppConstants.fontWeightBold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCloudApiConfig(),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Guardar configuración'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImplementationSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona el método de reconocimiento de voz:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Opción para móviles
            if (Platform.isAndroid || Platform.isIOS)
              RadioListTile<
                  SpeechRecognitionServiceFactory
                  .SpeechRecognitionImplementation>(
                title: const Text('Reconocimiento nativo (Android/iOS)'),
                subtitle:
                    const Text('Usa el reconocimiento de voz del dispositivo'),
                value: SpeechRecognitionServiceFactory
                    .SpeechRecognitionImplementation.mobile,
                groupValue: _selectedImplementation,
                onChanged: (value) {
                  setState(() {
                    _selectedImplementation = value!;
                  });
                },
              ),

            // Opción para Windows API
            if (Platform.isWindows)
              RadioListTile<
                  SpeechRecognitionServiceFactory
                  .SpeechRecognitionImplementation>(
                title: const Text('Windows Speech Recognition'),
                subtitle: const Text(
                    'Usa la API de reconocimiento de voz de Windows'),
                value: SpeechRecognitionServiceFactory
                    .SpeechRecognitionImplementation.windowsApi,
                groupValue: _selectedImplementation,
                onChanged: (value) {
                  setState(() {
                    _selectedImplementation = value!;
                  });
                },
              ),

            // Opción para Whisper.cpp
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
              RadioListTile<
                  SpeechRecognitionServiceFactory
                  .SpeechRecognitionImplementation>(
                title: const Text('Whisper.cpp (Offline)'),
                subtitle:
                    const Text('Usa el modelo de OpenAI Whisper localmente'),
                value: SpeechRecognitionServiceFactory
                    .SpeechRecognitionImplementation.whisper,
                groupValue: _selectedImplementation,
                onChanged: (value) {
                  setState(() {
                    _selectedImplementation = value!;
                  });
                },
              ),

            // Opción para API en la nube
            RadioListTile<
                SpeechRecognitionServiceFactory
                .SpeechRecognitionImplementation>(
              title: const Text('API en la nube (OpenAI)'),
              subtitle:
                  const Text('Usa la API de OpenAI para reconocimiento de voz'),
              value: SpeechRecognitionServiceFactory
                  .SpeechRecognitionImplementation.cloud,
              groupValue: _selectedImplementation,
              onChanged: (value) {
                setState(() {
                  _selectedImplementation = value!;
                });
              },
            ),

            // Opción para simulación
            RadioListTile<
                SpeechRecognitionServiceFactory
                .SpeechRecognitionImplementation>(
              title: const Text('Simulación'),
              subtitle: const Text(
                  'Simula el reconocimiento de voz con entrada de texto'),
              value: SpeechRecognitionServiceFactory
                  .SpeechRecognitionImplementation.mock,
              groupValue: _selectedImplementation,
              onChanged: (value) {
                setState(() {
                  _selectedImplementation = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhisperConfig() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de Whisper.cpp:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Ruta del modelo
            ListTile(
              title: const Text('Modelo de Whisper'),
              subtitle: Text(
                _platformConfig.whisperModelPath ?? 'No seleccionado',
                style: TextStyle(
                  color: _modelExists ? Colors.green : Colors.red,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _modelExists ? Icons.check_circle : Icons.error,
                    color: _modelExists ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectModelFile,
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Ruta del binario
            ListTile(
              title: const Text('Binario de Whisper'),
              subtitle: Text(
                _platformConfig.whisperBinaryPath ?? 'No seleccionado',
                style: TextStyle(
                  color: _binaryExists ? Colors.green : Colors.red,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _binaryExists ? Icons.check_circle : Icons.error,
                    color: _binaryExists ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectBinaryFile,
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Nota: Para usar Whisper.cpp, necesitas descargar:',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            const Text('1. El modelo ggml-large-v3.bin de OpenAI Whisper'),
            const Text(
                '2. El binario compilado de whisper.cpp para tu sistema'),
            const SizedBox(height: 8),
            const Text(
              'Puedes encontrarlos en: https://github.com/ggml-org/whisper.cpp/releases',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectModelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
      dialogTitle: 'Seleccionar modelo de Whisper',
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _platformConfig.whisperModelPath = result.files.single.path;
      });

      _modelExists = await File(_platformConfig.whisperModelPath!).exists();
      setState(() {});
    }
  }

  Future<void> _selectBinaryFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: Platform.isWindows ? ['exe'] : [''],
      dialogTitle: 'Seleccionar binario de Whisper',
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _platformConfig.whisperBinaryPath = result.files.single.path;
      });

      _binaryExists = await File(_platformConfig.whisperBinaryPath!).exists();
      setState(() {});
    }
  }

  /// Construye la configuración de fallback
  Widget _buildFallbackConfig() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de fallback:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Opción para usar la API en la nube como fallback
            SwitchListTile(
              title: const Text('Usar API en la nube como fallback'),
              subtitle: const Text(
                'Si no se encuentran los archivos de Whisper.cpp, usar la API en la nube',
              ),
              value: _useCloudFallback,
              onChanged: (value) {
                setState(() {
                  _useCloudFallback = value;
                });
              },
            ),

            if (_useCloudFallback) ...[
              const SizedBox(height: 16),
              const Text(
                'Clave de API de OpenAI:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu clave de API de OpenAI',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'Puedes obtener una clave de API en: https://platform.openai.com/api-keys',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construye la configuración de la API en la nube
  Widget _buildCloudApiConfig() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de la API de OpenAI:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Clave de API de OpenAI:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                hintText: 'Ingresa tu clave de API de OpenAI',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Puedes obtener una clave de API en: https://platform.openai.com/api-keys',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nota: El uso de la API de OpenAI puede generar costos. Consulta los precios en:',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            const Text(
              'https://openai.com/pricing',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _saveConfig() async {
    // Guardar la implementación seleccionada
    SpeechRecognitionServiceFactory.setImplementation(_selectedImplementation);

    // Guardar la configuración de fallback
    _platformConfig.useCloudFallback = _useCloudFallback;
    _platformConfig.cloudApiKey = _apiKeyController.text;

    // Guardar la configuración
    await _platformConfig.saveConfig();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
