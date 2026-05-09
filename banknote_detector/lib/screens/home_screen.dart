import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Banknote AI', 
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade900, Colors.blue.shade500],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue sur Banknote AI',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'La solution intelligente pour vérifier vos billets de banque en un instant grâce à l\'intelligence artificielle.',
                    style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Nos Fonctionnalités'),
                  const SizedBox(height: 20),
                  _buildFeatureCard(
                    context,
                    'Détection Instantanée',
                    'Identifiez la valeur et l\'authenticité d\'un billet en prenant simplement une photo.',
                    Icons.camera_enhance_rounded,
                    Colors.blue,
                  ),
                  _buildFeatureCard(
                    context,
                    'Analyse de Sécurité',
                    'Détectez les contrefaçons grâce à nos modèles d\'IA entraînés sur des milliers d\'échantillons.',
                    Icons.security_rounded,
                    Colors.green,
                  ),
                  _buildFeatureCard(
                    context,
                    'Historique & Suivi',
                    'Gardez une trace de toutes vos analyses passées et consultez-les à tout moment.',
                    Icons.history_rounded,
                    Colors.orange,
                  ),
                  _buildFeatureCard(
                    context,
                    'Statistiques Avancées',
                    'Visualisez vos données d\'analyse sous forme de graphiques clairs et intuitifs.',
                    Icons.bar_chart_rounded,
                    Colors.purple,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Comment ça marche ?'),
                  const SizedBox(height: 16),
                  _buildStep(1, 'Prenez une photo nette du billet.'),
                  _buildStep(2, 'Attendez l\'analyse de notre IA (quelques millisecondes).'),
                  _buildStep(3, 'Consultez les résultats détaillés et le taux de confiance.'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
