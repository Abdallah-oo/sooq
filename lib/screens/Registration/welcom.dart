import 'package:flutter/material.dart';
import 'package:market_salla/screens/auth_gate.dart';

class Welcom extends StatelessWidget {
  const Welcom({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color.fromARGB(255, 220, 241, 227),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Center(child: Image.asset('assets/img/welcom.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(18, 0, 18, 60),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'GET STARTED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
