
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

  final homeTeam = TextEditingController();
  final awayTeam = TextEditingController();
  final odd1 = TextEditingController();
  final oddX = TextEditingController();
  final odd2 = TextEditingController();

  double? probability1;
  double? probabilityX;
  double? probability2;
  double? margin;

  String? errorMessage;

  @override
  void dispose() {
    homeTeam.dispose();
    awayTeam.dispose();
    odd1.dispose();
    oddX.dispose();
    odd2.dispose();
    super.dispose();
  }

  void calculate() {
    final o1 = double.tryParse(odd1.text.replaceAll(',', '.'));
    final ox = double.tryParse(oddX.text.replaceAll(',', '.'));
    final o2 = double.tryParse(odd2.text.replaceAll(',', '.'));

    if (homeTeam.text.trim().isEmpty ||
        awayTeam.text.trim().isEmpty ||
        o1 == null || ox == null || o2 == null ||
        o1 <= 1 || ox <= 1 || o2 <= 1) {
      setState(() {
        errorMessage = 'Remplis tous les champs. Chaque cote doit être supérieure à 1.';
        probability1 = null;
      });
      return;
    }

    final p1 = 1 / o1;
    final px = 1 / ox;
    final p2 = 1 / o2;
    final total = p1 + px + p2;

    setState(() {
      probability1 = p1 / total * 100;
      probabilityX = px / total * 100;
      probability2 = p2 / total * 100;
      margin = (total - 1) * 100;
      errorMessage = null;
    });
  }

  void reset() {
    homeTeam.clear();
    awayTeam.clear();
    odd1.clear();
    oddX.clear();
    odd2.clear();
    setState(() {
      probability1 = null;
      probabilityX = null;
      probability2 = null;
      margin = null;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),
        title: const Text(
          'FOOTBALL AI PRO',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                  ? analysis()
                  : history(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
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
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Bienvenue dans ton assistant !',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('Analyse et statistiques du football'),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF087F5B), Color(0xFF123D35)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, size: 38),
              SizedBox(height: 12),
              Text(
                'FOOTBALL AI PRO',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Ton assistant d’analyse football.'),
            ],
          ),
        ),
        const SizedBox(height: 25),
        toolCard(Icons.sports_soccer, 'Matchs de football',
            'Consulter les rencontres', 1),
        toolCard(Icons.psychology, 'Calculateur 1xBet',
            'Analyser les cotes et probabilités', 2),
        toolCard(Icons.history, 'Historique',
            'Retrouver tes analyses', 3),
        const SizedBox(height: 15),
        const Text(
          'Les probabilités sont des estimations calculées à partir des cotes. Elles ne garantissent aucun résultat.',
          style: TextStyle(color: Colors.orangeAccent),
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
          setState(() => selectedIndex = destination);
        },
      ),
    );
  }

  Widget matches() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer, size: 65, color: Colors.green),
            SizedBox(height: 15),
            Text(
              'MATCHS DE FOOTBALL',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Le calendrier des matchs et les résultats en direct seront ajoutés avec une source de données football.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget inputField(
      String label, TextEditingController controller, String hint,
      {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType:
            number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget analysis() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'ANALYSE DES COTES 1X2',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Entre les équipes et les cotes affichées sur 1xBet.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 22),
        inputField('Équipe à domicile', homeTeam, 'Ex : Real Madrid'),
        inputField('Équipe à l’extérieur', awayTeam, 'Ex : Barcelone'),
        const SizedBox(height: 8),
        const Text(
          'COTES 1XBET',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        inputField('1 - Victoire domicile', odd1, 'Ex : 2.10', number: true),
        inputField('X - Match nul', oddX, 'Ex : 3.20', number: true),
        inputField('2 - Victoire extérieur', odd2, 'Ex : 3.50', number: true),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: calculate,
            icon: const Icon(Icons.psychology),
            label: const Text('CALCULER LES PROBABILITÉS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Effacer les données'),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 15),
          Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
        ],
        if (probability1 != null) ...[
          const SizedBox(height: 25),
          Card(
            color: const Color(0xFF1C2B3C),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RÉSULTATS DE L’ANALYSE',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text('${homeTeam.text} - ${awayTeam.text}',
                      style: const TextStyle(fontSize: 17)),
                  const Divider(height: 25),
                  resultRow('1 - ${homeTeam.text}', probability1!),
                  resultRow('X - Match nul', probabilityX!),
                  resultRow('2 - ${awayTeam.text}', probability2!),
                  const Divider(height: 25),
                  Text(
                    'Marge estimée des cotes : ${margin!.toStringAsFixed(2)} %',
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Ces probabilités sont normalisées à partir des trois cotes. Elles reflètent le marché, pas une prédiction indépendante de l’IA.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget resultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label)),
              Text(
                '${value.toStringAsFixed(1)} %',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: Colors.white12,
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  Widget history() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Text(
          'HISTORIQUE\n\nLa sauvegarde des analyses sera ajoutée dans une prochaine version.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
