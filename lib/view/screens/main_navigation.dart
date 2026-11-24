import 'package:flutter/material.dart';

import 'auth/auth_gate.dart';
import 'garagem/garagem_screen.dart';
import 'perfil/perfil_screen.dart';
import 'vitrine/vitrine_screen.dart';

/// Navegação centralizada do app (requisito "Navegação").
/// BottomNavigationBar com 3 abas: Vitrine (pública), Garagem e Perfil
/// (estas duas protegidas pelo AuthGate).
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _abaAtual = 0;

  void _irPara(int indice) => setState(() => _abaAtual = indice);

  @override
  Widget build(BuildContext context) {
    // IndexedStack mantém o estado de cada aba ao trocar (scroll, campos etc.)
    final abas = <Widget>[
      VitrineScreen(onEntrar: () => _irPara(1)),
      const AuthGate(child: GaragemScreen()),
      const AuthGate(child: PerfilScreen()),
    ];

    return Scaffold(
      body: IndexedStack(index: _abaAtual, children: abas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaAtual,
        onTap: _irPara,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Vitrine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.garage_outlined),
            activeIcon: Icon(Icons.garage),
            label: 'Garagem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
