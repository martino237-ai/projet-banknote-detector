import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07101F),
      appBar: AppBar(
        title: const Text('Statistiques'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF4F46E5),
        onRefresh: () async {
          await Provider.of<ApiService>(context, listen: false).getStats();
          setState(() {});
        },
        child: FutureBuilder<Map<String, dynamic>?>(
          future: Provider.of<ApiService>(context, listen: false).getStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF4F46E5)));
            }

            final stats = snapshot.data;
            if (stats == null || (stats['total'] ?? 0) == 0) {
              return _buildEmptyStats();
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Vue d\'ensemble'),
                  const SizedBox(height: 16),
                  _buildMainStats(stats),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Répartition de l\'Authenticité'),
                  const SizedBox(height: 16),
                  _buildDistributionChart(stats),
                  const SizedBox(height: 32),
                  _buildPerformanceCard(stats),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildEmptyStats() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: Icon(Icons.analytics_outlined, size: 64, color: Colors.white.withOpacity(0.18)),
              ),
              const SizedBox(height: 24),
              const Text('Données insuffisantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Réalisez vos premières analyses\npour générer des statistiques.', 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.68))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainStats(Map<String, dynamic> stats) {
    return Column(
      children: [
        _buildStatTile(
          'Total Analyses',
          stats['total'].toString(),
          Icons.auto_graph_rounded,
          const Color(0xFF4F46E5),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                'Authentiques',
                stats['authentic'].toString(),
                Icons.verified_rounded,
                const Color(0xFF22C55E),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatTile(
                'Suspects',
                stats['fake'].toString(),
                Icons.gpp_maybe_rounded,
                const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.66), fontSize: 13, fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(Map<String, dynamic> stats) {
    final total = (stats['total'] as num).toDouble();
    final authentic = (stats['authentic'] as num).toDouble();
    final fake = (stats['fake'] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _chartIndicator('Authentique', const Color(0xFF22C55E)),
              const SizedBox(width: 24),
              _chartIndicator('Suspect', const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  if (authentic > 0) Expanded(flex: authentic.toInt(), child: Container(color: const Color(0xFF22C55E))),
                  if (fake > 0) Expanded(flex: fake.toInt(), child: Container(color: const Color(0xFFEF4444))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(authentic / total * 100).toInt()}% Authentique', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${(fake / total * 100).toInt()}% Suspect', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartIndicator(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPerformanceCard(Map<String, dynamic> stats) {
    final confidence = (stats['avg_confidence'] ?? 0.0) as double;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF111B2E), Color(0xFF1D2B4B)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text('Indice de Confiance IA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '${(confidence * 100).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Précision moyenne de détection basée sur vos scans récents.',
            style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
