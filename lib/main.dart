
import 'package:flutter/material.dart';

void main() {
  runApp(const FootballAIPro());
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
        scaffoldBackgroundColor: const Color(0xFF101827),
        colorSchemeSeed: Colors.green,
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
  int selectedIndex = 0;

  final List<String> titles = [
    'Tableau de bord',
    'Matchs de football',
    'Analyses IA',
    'Historique',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),
        title: const Text(
          'FOOTBALL AI PRO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.sports_soccer, color: Colors.green),
          ),
        ],
      ),
      body: selectedIndex == 0
          ? dashboard()
          : selectedIndex == 1
              ? matches()
              : selectedIndex == 2
                  ? analyses()
                  : history(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer),
            label: 'Matchs',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology),
            label: 'Analyse IA',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Bienvenue dans ton assistant !',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Analyse intelligente du football',
          style: TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF087F5B), Color(0xFF123D35)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, size: 35),
              SizedBox(height: 12),
              Text(
                'FOOTBALL AI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Ton intelligence football commence ici.'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'MES OUTILS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 12),
        toolCard(Icons.sports_soccer, 'Matchs du jour',
            'Découvrir les rencontres', 1),
        toolCard(Icons.psychology, 'Analyses intelligentes',
            'Étudier les équipes et probabilités', 2),
        toolCard(Icons.history, 'Historique des pronostics',
            'Suivre les résultats', 3),
        const SizedBox(height: 20),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'Important : les analyses sont des estimations. '
              'Aucun pronostic ne garantit un gain. '
              'Les paris doivent toujours être validés manuellement.',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget toolCard(
      IconData icon, String title, String subtitle, int destination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 30),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          setState(() {
            selectedIndex = destination;
          });
        },
      ),
    );
  }

  Widget matches() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text('MATCHS DE FOOTBALL',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              'Le calendrier et les matchs en direct seront connectés '
              'à une source de données football.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget analyses() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text('ANALYSE INTELLIGENTE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              'Bientôt : statistiques, forme des équipes, '
              'buts, probabilités et comparaison des cotes.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget history() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text('HISTORIQUE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              'Tes futurs pronostics et leurs résultats '
              'seront enregistrés ici.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
