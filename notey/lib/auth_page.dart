import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notey/main.dart';
// ... other imports

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        // Listen to the auth state (logged in or out)
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the stream has data, the user is logged in
          if (snapshot.hasData) {
            return const NoteApp(); // Replace with your actual Home Page
          }
          // Otherwise, they need to login
          return const LoginScreen(); // We will build this next
        },
      ),
    );
  }
}