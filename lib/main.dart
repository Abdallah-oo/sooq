import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/screens/routing/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>Sallastate() ,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home:const MainScreen(),
      ),
    );
  }
}
