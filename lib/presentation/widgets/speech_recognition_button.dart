import 'package:flutter/material.dart';
import 'package:sazones_semanales/infrastructure/services/service_providers.dart';

/// A button widget that triggers speech recognition
class SpeechRecognitionButton extends StatefulWidget {
  /// Callback function that receives the recognized text
  final void Function(String) onTextRecognized;

  /// Callback function that receives the parsed products and quantities
  final void Function(Map<String, int>) onProductsRecognized;

  /// Optional label for the button
  final String? label;

  /// Constructor
  const SpeechRecognitionButton({
    super.key,
    required this.onTextRecognized,
    required this.onProductsRecognized,
    this.label,
  });

  @override
  State<SpeechRecognitionButton> createState() =>
      SpeechRecognitionButtonState();
}

class SpeechRecognitionButtonState extends State<SpeechRecognitionButton> {
  bool _isListening = false;

  /// Toggles the listening state
  void _toggleListening() async {
    final service = SpeechRecognitionServiceProvider.getService(context);

    if (_isListening) {
      // Stop listening
      await service.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      // Start listening
      setState(() {
        _isListening = true;
      });

      final success = await service.startListening(
        onResult: (text) {
          // Call the callback with the recognized text
          widget.onTextRecognized(text);

          // Parse the command and call the callback with the products
          final products = service.parseConsumptionCommand(text);
          widget.onProductsRecognized(products);

          // Update the state
          setState(() {
            _isListening = false;
          });
        },
        onError: (error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
            ),
          );

          // Update the state
          setState(() {
            _isListening = false;
          });
        },
      );

      if (!success) {
        // Update the state if starting listening failed
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleListening,
        borderRadius: BorderRadius.circular(100),
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: _isListening
                  ? [Colors.red.shade400, Colors.red.shade700]
                  : [Colors.purple.shade300, Colors.deepPurple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label ??
                      (_isListening ? 'Escuchando...' : 'Reconocer voz'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isListening)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: _PulsingCircle(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra un círculo pulsante para indicar que se está escuchando
class _PulsingCircle extends StatefulWidget {
  const _PulsingCircle();

  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.5),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                spreadRadius: _animation.value,
                blurRadius: _animation.value * 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
