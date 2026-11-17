
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const FootballAIPro());
}

const String apiUrl =
    'https://delicate-firefly-96f4football-ai-pro-api.lankoandehamadou79.workers.dev';

// Fonctions pour lire les données JSON sans provoquer d'erreur.
Map<String, dynamic> asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

dynamic firstValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (map[key] != null) return map[key];
  }
  return null;
}

List<dynamic> extractMatches(dynamic data) {
  if (data is List) return data;

  final root = asMap(data);

  for (final key in [
    'response',
    'réponse',
    'matches',
    'matchs',
    'fixtures',
  ]) {
    if (root[key] is List) {
      return root[key] as List<dynamic>;
    }
  }

  for (final key in ['data', 'result', 'results']) {
    final nested = asMap(root[key]);

    for (final nestedKey in [
      'response',
      'matches',
      'matchs',
      'fixtures',
      'items',
    ]) {
      if (nested[nestedKey] is List) {
        return nested[nestedKey] as List<dynamic>;
      }
    }
  }

  return <dynamic>[];
}

String displayValue(dynamic value, String fallback) {
  if (value == null || value.toString().isEmpty) {
    return fallback;
  }
  return value.toString();
}

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
  String? emptyMessage;
  DateTime? lastUpdate;

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    if (loading) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);

    try {
      final request = await client
          .getUrl(Uri.parse('$apiUrl/fixtures/live'))
          .timeout(const Duration(seconds: 20));

      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      final response =
          await request.close().timeout(const Duration(seconds: 20));

      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }

      final data = jsonDecode(body);
      final result = extractMatches(data);

      String? message;

      if (result.isEmpty) {
        final root = asMap(data);
        final count = root['results'];

        if (count != null && count.toString() != '0') {
          message =
              'Le serveur annonce $count rencontres, mais '
              'l’application ne trouve pas leur liste.\n\n'
              'Clés reçues : ${root.keys.join(', ')}';
        } else {
          message =
              'Aucun match en direct actuellement. '
              'Appuie sur Actualiser pour vérifier à nouveau.';
        }
      }

      if (!mounted) return;

      setState(() {
        matches = result;
        emptyMessage = message;
        lastUpdate = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Impossible de récupérer les matchs. '
            'Vérifie ta connexion et réessaie.';
      });
    } finally {
      client.close(force: true);

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
              if (matches.isNotEmpty)
                Text(
                  '${matches.length} matchs',
                  style: const TextStyle(color: Colors.greenAccent),
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
              'Dernière mise à jour : '
              '${lastUpdate!.hour.toString().padLeft(2, '0')}:'
              '${lastUpdate!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white60),
            ),
          ),

        if (loading && matches.isEmpty)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (errorMessage != null && matches.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                    ),
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
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  emptyMessage ?? 'Aucun match détecté.',
                  textAlign: TextAlign.center,
                ),
              ),
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
        'L’historique des analyses sera disponible '
        'dans une prochaine version.',
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
    final item = asMap(match);

    final fixture = asMap(
      firstValue(item, ['fixture', 'match']),
    );

    final league = asMap(
      firstValue(item, ['league', 'ligue']),
    );

    final teams = asMap(
      firstValue(item, ['teams', 'équipes']),
    );

    final goals = asMap(
      firstValue(item, ['goals', 'buts']),
    );

    final status = asMap(
      firstValue(fixture, ['status', 'statut']),
    );

    final home = asMap(
      firstValue(teams, ['home', 'domicile']),
    );

    final away = asMap(
      firstValue(teams, ['away', 'extérieur', 'exterieur']),
    );

    final homeName = displayValue(
      firstValue(home, ['name', 'nom']),
      'Équipe domicile',
    );

    final awayName = displayValue(
      firstValue(away, ['name', 'nom']),
      'Équipe extérieure',
    );

    final homeGoals = displayValue(
      firstValue(goals, ['home', 'domicile']),
      '-',
    );

    final awayGoals = displayValue(
      firstValue(goals, ['away', 'extérieur', 'exterieur']),
      '-',
    );

    final minute = firstValue(
      status,
      ['elapsed', 'écoulé', 'minute'],
    );

    final state = displayValue(
      firstValue(status, ['short', 'court', 'long']),
      'En direct',
    );

    final leagueName = displayValue(
      firstValue(league, ['name', 'nom']),
      'Championnat',
    );

    return Card(
      color: const Color(0xFF1B2B35),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              leagueName,
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
                    homeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
                    awayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              minute != null
                  ? '$minute min • $state'
                  : state,
              style: const TextStyle(
                color: Colors.orangeAccent,
              ),
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
    final home = double.tryParse(
      homeController.text.replaceAll(',', '.'),
    );
    final draw = double.tryParse(
      drawController.text.replaceAll(',', '.'),
    );
    final away = double.tryParse(
      awayController.text.replaceAll(',', '.'),
    );

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
          'Domicile : '
          '${(pHome / total * 100).toStringAsFixed(1)} %\n'
          'Match nul : '
          '${(pDraw / total * 100).toStringAsFixed(1)} %\n'
          'Extérieur : '
          '${(pAway / total * 100).toStringAsFixed(1)} %\n\n'
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

  Widget oddsField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
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
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Saisis les cotes affichées sur 1xBet '
          'pour estimer les probabilités.',
        ),
        const SizedBox(height: 20),
        oddsField(
          'Cote 1 - Victoire domicile',
          homeController,
        ),
        oddsField(
          'Cote X - Match nul',
          drawController,
        ),
        oddsField(
          'Cote 2 - Victoire extérieur',
          awayController,
        ),
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
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
