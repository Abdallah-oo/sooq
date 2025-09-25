import 'package:flutter/material.dart';
import 'package:market_salla/screens/navigationbar/drawer.dart';
import 'package:market_salla/screens/navigationbar/favorite.dart';
import 'package:market_salla/screens/navigationbar/home.dart';
import 'package:market_salla/screens/navigationbar/profile.dart';
import 'package:market_salla/screens/navigationbar/search.dart';
import 'package:market_salla/widgets/buttomnavigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    Favorite(),
    Search(),
    Profile(),
    Customdrawer(),
  ];

  void _onItemTapped(int index) {
    if (index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: ButtomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
