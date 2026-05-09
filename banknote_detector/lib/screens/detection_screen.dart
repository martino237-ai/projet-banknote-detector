import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/detection_result.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  DetectionResult? _result;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _result = null;
          _isProcessing = true;
        });
        
        final apiService = Provider.of<ApiService>(context, listen: false);
        final result = await apiService.detectImage(image);
        
        if (mounted) {
          setState(() {
            _result = result;
            _isProcessing = false;
          });
          
          if (result == null && apiService.error != null) {
            _showErrorDialog(apiService.error!);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorDialog('Erreur: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Erreur de connexion'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('IA - Détecteur de Billets', 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePreview(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 32),
              if (_isProcessing)
                _buildLoadingState()
              else if (_result != null)
                _buildResultCard(_result!)
              else
                _buildInitialState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: _selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  kIsWeb 
                    ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: IconButton(
                      onPressed: () => setState(() => _selectedImage = null),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.black26),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 70, color: Colors.blue.shade100),
                    const SizedBox(height: 16),
                    Text(
                      'Prêt pour l\'analyse',
                      style: TextStyle(color: Colors.blue.shade300, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
            icon: Icons.camera_rounded,
            label: 'CAMÉRA',
            primary: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildButton(
            onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
            icon: Icons.photo_library_rounded,
            label: 'GALERIE',
            primary: false,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({required VoidCallback? onPressed, required IconData icon, required String label, required bool primary}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? Colors.blue.shade700 : Colors.white,
        foregroundColor: primary ? Colors.white : Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: primary ? BorderSide.none : BorderSide(color: Colors.blue.shade100, width: 2),
        ),
        elevation: primary ? 4 : 0,
      ),
    );
  }

  Widget _buildInitialState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: Colors.blue.shade400),
          const SizedBox(height: 12),
          Text(
            'Scannez un billet pour vérifier son authenticité et sa valeur instantanément.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue.shade900, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircularProgressIndicator(strokeWidth: 4),
        const SizedBox(height: 24),
        const Text(
          'ANALYSE IA EN COURS...',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildResultCard(DetectionResult result) {
    final bool isAuthentic = result.isAuthentic;
    final color = isAuthentic ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              isAuthentic ? '✓ AUTHENTIQUE' : '⚠ SUSPECT / FAUX',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),
          if (isAuthentic) ...[
            const Text('DÉNOMINATION', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2)),
            Text(
              '${result.currency} ${result.denomination}',
              style: TextStyle(color: color, fontSize: 56, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            _buildBar('Confiance Denom.', result.denominationConfidence ?? 0, color),
          ],
          const SizedBox(height: 16),
          _buildBar('Confiance Authentification', result.confidence, Colors.blue.shade700),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoTile(Icons.timer_rounded, '${result.processingTimeMs.toStringAsFixed(0)}ms'),
              _infoTile(Icons.calendar_today_rounded, '${result.timestamp.day}/${result.timestamp.month}'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBar(String label, double val, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            Text('${(val * 100).toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: c)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: val,
          backgroundColor: c.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(c),
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _infoTile(IconData i, String v) {
    return Row(
      children: [
        Icon(i, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
