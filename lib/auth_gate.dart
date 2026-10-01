import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importe suas telas
import 'main.dart';  // Para acessar a MyHomePage
import 'login.dart'; // Sua tela de login (ajuste o nome se for diferente)

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto o Firebase carrega
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário estiver logado, abre a tela principal
        if (snapshot.hasData) {
          return const MyHomePage(title: 'FirebaseApp Home Page');
        }

        // Se NÃO estiver logado, abre a tela de login
        return const LoginScreen(); // Altere para a sua classe de login
      },
    );
  }
}