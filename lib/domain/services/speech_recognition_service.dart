/// Interface for speech recognition service
abstract class SpeechRecognitionService {
  /// Initializes the speech recognition service
  /// 
  /// Returns true if initialization was successful, false otherwise
  Future<bool> initialize();
  
  /// Starts listening for speech input
  /// 
  /// [onResult] is called when speech is recognized
  /// [onError] is called when an error occurs
  /// [localeId] is the locale ID for the language to recognize (e.g., 'es-ES' for Spanish)
  Future<bool> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
    String? localeId,
  });
  
  /// Stops listening for speech input
  Future<void> stopListening();
  
  /// Returns true if the service is currently listening
  bool get isListening;
  
  /// Returns a list of available locales for speech recognition
  Future<List<String>> getAvailableLocales();
  
  /// Parses a voice command for product consumption
  /// 
  /// Returns a map with product names as keys and quantities as values
  Map<String, int> parseConsumptionCommand(String command);
}