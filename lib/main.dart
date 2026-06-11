import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/jenis_catatan_view_model.dart';
import 'views/jenis_catatan_view.dart';

void main() {
  runApp(
    // Kita bungkus app dengan MultiProvider kalau kedepannya 
    // kamu mau tambah ViewModel lain (misal untuk Siswa atau Guru)
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JenisCatatanViewModel()),
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
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: JenisCatatanView(),
    );
  }
}