import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme_service.dart';
import 'providers/auth_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/theme_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final initialMode = await ThemeService.getSavedThemeMode();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
       ChangeNotifierProxyProvider<AuthProvider, JournalProvider>(
        create: (context) => JournalProvider(Provider.of<AuthProvider>(context, listen: false)),
        update: (context, auth, previousJournal) => 
            JournalProvider(auth)..loadJournals(),
      ),
      ChangeNotifierProvider(create: (_) => ThemeProvider(initialMode)),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JourNWal',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProv.mode,
      home: const LoginPage(),
      routes: {
        '/home': (_) => const HomePage(),
      },
    );
  }
}
