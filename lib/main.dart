import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/jenis_catatan_view_model.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/siswa_view_model.dart';
import 'view_models/guru_view_model.dart';
import 'views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JenisCatatanViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SiswaViewModel()),
        ChangeNotifierProvider(create: (_) => GuruViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZiePoint App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF302B63),
          primary: const Color(0xFF302B63),
          secondary: const Color(0xFF6C63FF),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Default typography fallback
      ),
      home: const LoginView(),
    );
  }
}