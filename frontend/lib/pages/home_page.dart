import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/carousel_banner.dart';
import 'item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JournalProvider>(context, listen: false).loadJournals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final journalProv = Provider.of<JournalProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('JourNWal — Hi, ${auth.username.isNotEmpty ? auth.username : 'Guest'}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'light') themeProv.setMode(ThemeMode.light);
              else if (v == 'dark') themeProv.setMode(ThemeMode.dark);
              else if (v == 'logout') {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'light', child: Text('Light Theme')),
              const PopupMenuItem(value: 'dark', child: Text('Dark Theme')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => journalProv.loadJournals(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const CarouselBanner(),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Mengapa journaling?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Journaling membantu refleksi, mengurangi stress, dan meningkatkan produktivitas.'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemPage())),
                    child: const Text('Lihat semua')),
              ],
            ),
            if (journalProv.loading)
              const Center(child: CircularProgressIndicator())
            else if (journalProv.journals.isEmpty)
              const Center(child: Text('Belum ada journal.'))
            else
              ...journalProv.journals.take(3).map((j) => ListTile(
                title: Text(j.title),
                subtitle: Text('${j.author} • ${j.date.toLocal().toString().split('.').first}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemPage(initialJournalId: j.id))),
              )),
            const SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemPage())),
        child: const Icon(Icons.article),
        tooltip: 'Open Journals',
      ),
    );
  }
}
