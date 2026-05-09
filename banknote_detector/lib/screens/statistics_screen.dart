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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tableau de Bord', 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue.shade900,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ApiService>(context, listen: false).getStats();
          setState(() {});
        },
        child: FutureBuilder<Map<String, dynamic>?>(
          future: Provider.of<ApiService>(context, listen: false).getStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = snapshot.data;
            if (stats == null || (stats['total'] ?? 0) == 0) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.analytics_outlined, size: 80, color: Colors.blue.shade200),
                        ),
                        const SizedBox(height: 24),
                        Text('Données insuffisantes', 
                          style: TextStyle(color: Colors.blue.shade900, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Faites quelques analyses pour voir vos stats.', 
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Résumé Global', 
                    style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'Total Analyses',
                    stats['total'].toString(),
                    Icons.insights_rounded,
                    Colors.blue.shade700,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Authentiques',
                          stats['authentic'].toString(),
                          Icons.check_circle_rounded,
                          Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Suspects',
                          stats['fake'].toString(),
                          Icons.warning_rounded,
                          Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'Confiance Moyenne',
                    '${((stats['avg_confidence'] ?? 0) * 100).toStringAsFixed(1)}%',
                    Icons.speed_rounded,
                    Colors.amber.shade700,
                  ),
                  const SizedBox(height: 32),
                  Text('Répartition', 
                    style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildEfficiencyChart(stats),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blue.shade900)),
        ],
      ),
    );
  }

  Widget _buildEfficiencyChart(Map<String, dynamic> stats) {
    final total = (stats['total'] as num).toDouble();
    final authentic = (stats['authentic'] as num).toDouble();
    final fake = (stats['fake'] as num).toDouble();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Analyse Visuelle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Icon(Icons.pie_chart_outline_rounded, color: Colors.grey.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: [
                    if (authentic > 0)
                      Expanded(flex: authentic.toInt(), child: Container(color: Colors.green.shade400)),
                    if (fake > 0)
                      Expanded(flex: fake.toInt(), child: Container(color: Colors.red.shade400)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend('Authentique', Colors.green.shade400, (authentic/total * 100).toStringAsFixed(0)),
              _buildLegend('Suspect', Colors.red.shade400, (fake/total * 100).toStringAsFixed(0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, String percent) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text('$percent%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blue.shade900)),
      ],
    );
  }
}
