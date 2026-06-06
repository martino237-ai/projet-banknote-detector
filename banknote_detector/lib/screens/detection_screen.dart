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
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
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
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07101F),
      appBar: AppBar(
        title: const Text('Analyse IA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageCard(),
              const SizedBox(height: 32),
              if (!_isProcessing && _result == null) _buildInstructionText(),
              if (_isProcessing) _buildLoadingState(),
              if (_result != null) _buildResultSection(_result!),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: _selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  kIsWeb 
                    ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.44), shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: const Color(0xFF0F172A),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_enhance_outlined, size: 66, color: Colors.white.withOpacity(0.22)),
                    const SizedBox(height: 18),
                    Text(
                      'Aucune image sélectionnée',
                      style: TextStyle(color: Colors.white.withOpacity(0.72), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return Column(
      children: [
        const Text(
          'Prêt pour l\'authentification',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Prenez une photo nette du billet pour que notre IA puisse l\'analyser précisément.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF4F46E5)),
        const SizedBox(height: 20),
        const Text(
          'Traitement par le réseau neuronal...',
          style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildResultSection(DetectionResult result) {
    final bool isAuthentic = result.isAuthentic;
    final themeColor = isAuthentic ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Icon(isAuthentic ? Icons.check_circle_rounded : Icons.warning_rounded, color: themeColor, size: 52),
          const SizedBox(height: 16),
          Text(
            isAuthentic ? 'BILLET AUTHENTIQUE' : 'BILLET SUSPECT',
            style: TextStyle(color: themeColor, fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const Divider(height: 32, color: Colors.white12),
          _buildResultRow('Valeur', '${result.currency} ${result.denomination}'),
          _buildResultRow('Confiance', '${(result.confidence * 100).toStringAsFixed(1)}%'),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: result.confidence,
              minHeight: 8,
              backgroundColor: themeColor.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation(themeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.68), fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _customButton(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: Icons.camera_alt_rounded,
            label: 'Caméra',
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _customButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: Icons.photo_library_rounded,
            label: 'Galerie',
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _customButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isPrimary}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF4F46E5) : const Color(0xFF14243C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

