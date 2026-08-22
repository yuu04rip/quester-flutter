// lib/ui/screens/nav_screens.dart

import 'package:flutter/material.dart';

/// Definizione delle schermate di navigazione
class NavScreens {
  final String title;
  final IconData icon;

  const NavScreens({required this.title, required this.icon});
}

/// Lista delle schermate principali
const List<NavScreens> navScreensList = [
  NavScreens(title: 'Profilo', icon: Icons.person),
  NavScreens(title: 'Missioni', icon: Icons.home),
  NavScreens(title: 'Negozio', icon: Icons.shopping_bag),
];