import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_system/screens/auth/login_screen.dart';
import 'package:note_system/screens/auth/signup_screen.dart';
import 'package:note_system/screens/notes_screen.dart';
import 'package:provider/provider.dart';
import 'package:note_system/providers/notes_provider.dart';
import 'package:note_system/providers/authentication_provider.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()), 
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/notes': (context) =>  NotesScreen(),
          '/signup': (context) =>  SignupScreen(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) =>  LoginScreen(),
        ),
      ),
    );
  }
}