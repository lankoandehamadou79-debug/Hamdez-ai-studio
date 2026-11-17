
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const FootballAIPro());
}

const String apiUrl =
    'https://delicate-firefly-96f4football-ai-pro-api.lankoandehamadou79.workers.dev';

class FootballAIPro extends StatelessWidget {
  const FootballAIPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FOOTBALL AI PRO',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101820),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;
  List<dynamic> matches = [];
  bool loading = false;
  String? errorMessage;
  DateTime? lastUpdate;

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    final client = HttpClient();

    try {
      final request = await client
          .getUrl(Uri.parse('$apiUrl/fixtures/live'))
          .timeout(const Duration(seconds: 20));

      final response =
          await request.close().timeout(const Duration(seconds: 20));

      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }

      final data = jsonDecode(body);
      final List<dynamic> result = data['response'] ?? [];

      if (!mounted) return;

      setState(() {
        matches = result;
        lastUpdate = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Impossible de charger les matchs. Vérifie Internet.';
      });
    } finally {
      client.close();
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚽ FOOTBALL AI PRO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF172A22),
      ),
      body: IndexedStack(
        index: selectedTab,
        children: [
          livePage(),
          const AnalysisPage(),
          historyPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_soccer),
            label: 'En direct',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analyse',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
        ],
      ),
    );
  }

  Widget livePage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'MATCHS EN DIRECT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: loading ? null : loadMatches,
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualiser',
              ),
            ],
          ),
        ),
        if (lastUpdate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Dernière mise à jour : ${lastUpdate!.hour.toString().padLeft(2, '0')}:${lastUpdate!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white60),
            ),
          ),
        if (loading && matches.isEmpty)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (errorMessage != null && matches.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loadMatches,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (matches.isEmpty)
          const Expanded(
            child: Center(
              child: Text('Aucun match en direct actuellement.'),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadMatches,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  return MatchCard(match: matches[index]);
                },
              ),
            ),
          ),
        if (loading && matches.isNotEmpty)
          const LinearProgressIndicator(),
      ],
    );
  }

  Widget historyPage() {
    return const Center(
      child: Text(
        'L’historique des analyses sera disponible dans une prochaine version.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final dynamic match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final fixture = match['fixture'] ?? {};
    final teams = match['teams'] ?? {};
    final goals = match['goals'] ?? {};
    final league = match['league'] ?? {};
    final status = fixture['status'] ?? {};

    final home = teams['home']?['name'] ?? 'Équipe domicile';
    final away = teams['away']?['name'] ?? 'Équipe extérieure';
    final homeGoals = goals['home'] ?? '-';
    final awayGoals = goals['away'] ?? '-';
    final minute = status['elapsed'];
    final state = status['short'] ?? '';

    return Card(
      color: const Color(0xFF1B2B35),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              league['name'] ?? 'Championnat',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    home,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '$homeGoals - $awayGoals',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    away,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              minute != null ? '$minute min • $state' : state.toString(),
              style: const TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final homeController = TextEditingController();
  final drawController = TextEditingController();
  final awayController = TextEditingController();

  String result = '';

  void calculate() {
    final home = double.tryParse(homeController.text);
    final draw = double.tryParse(drawController.text);
    final away = double.tryParse(awayController.text);

    if (home == null ||
        draw == null ||
        away == null ||
        home <= 1 ||
        draw <= 1 ||
        away <= 1) {
      setState(() {
        result = 'Entre trois cotes valides, supérieures à 1.';
      });
      return;
    }

    final pHome = 1 / home;
    final pDraw = 1 / draw;
    final pAway = 1 / away;
    final total = pHome + pDraw + pAway;

    setState(() {
      result =
          'Domicile : ${(pHome / total * 100).toStringAsFixed(1)} %\n'
          'Match nul : ${(pDraw / total * 100).toStringAsFixed(1)} %\n'
          'Extérieur : ${(pAway / total * 100).toStringAsFixed(1)} %\n\n'
          'Ces estimations sont calculées à partir des cotes saisies. '
          'Ce ne sont pas des prédictions garanties.';
    });
  }

  @override
  void dispose() {
    homeController.dispose();
    drawController.dispose();
    awayController.dispose();
    super.dispose();
  }

  Widget oddsField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'ANALYSE DES COTES 1X2',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Saisis les cotes affichées sur 1xBet pour estimer les probabilités.',
        ),
        const SizedBox(height: 20),
        oddsField('Cote 1 - Victoire domicile', homeController),
        oddsField('Cote X - Match nul', drawController),
        oddsField('Cote 2 - Victoire extérieur', awayController),
        ElevatedButton(
          onPressed: calculate,
          child: const Text('Calculer les probabilités'),
        ),
        const SizedBox(height: 20),
        if (result.isNotEmpty)
          Card(
            color: const Color(0xFF1B2B35),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                result,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ),
          ),
      ],
    );
  }
}
