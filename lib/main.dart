import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/product.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get local directory for Isar storage
  final dir = await getApplicationDocumentsDirectory();

  // Open Isar database instance
  isar = await Isar.open(
    [], // Temporarily empty so code runner can build schema files
    directory: dir.path,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'merryjays POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('merryjays POS - Isar Ready!'),
        ),
      ),
    );
  }
}