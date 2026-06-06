import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onStartPressed;

  const HomeScreen({super.key, this.onStartPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07101F), Color(0xFF0B172F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: _buildCircle(320, const Color(0xFF4F46E5).withOpacity(0.16)),
            ),
            Positioned(
              bottom: -90,
              left: -80,
              child: _buildCircle(260, const Color(0xFF22C55E).withOpacity(0.10)),
            ),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          _buildHeroSection(context),
                          const SizedBox(height: 44),
                          _buildSectionHeader('Services Premium'),
                          const SizedBox(height: 22),
                          _buildFeatureGrid(context),
                          const SizedBox(height: 36),
                          _buildPromoCard(context),
                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withOpacity(0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Powered by Advanced AI',
            style: TextStyle(
              color: Color(0xFF4F46E5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Vérifiez vos\nBillets en un Clin d\'Œil',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Technologie de détection neuronale pour une sécurité financière instantanée, avec un design premium et une expérience fluide.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.78),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: onStartPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            minimumSize: const Size(210, 62),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            elevation: 10,
            shadowColor: const Color(0xFF4F46E5).withOpacity(0.28),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Démarrer l\'Analyse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.65)),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildFeatureItem(
              'Authenticité', 
              'Détection de faux billets', 
              Icons.verified_user_rounded, 
              const Color(0xFF6366F1)
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildFeatureItem(
              'Précision', 
              'IA de dernière génération', 
              Icons.auto_graph_rounded, 
              const Color(0xFFEC4899)
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildFeatureItem(
              'Multi-Devises', 
              'Supporte 50+ monnaies', 
              Icons.public_rounded, 
              const Color(0xFFF59E0B)
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildFeatureItem(
              'Sécurisé', 
              'Anonymat de vos données', 
              Icons.lock_person_rounded, 
              const Color(0xFF22C55E)
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF11203A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bénéficiez d\'un\nAudit de Sécurité',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Découvrez nos solutions entreprises.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

