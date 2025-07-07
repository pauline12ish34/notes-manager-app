import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_system/screens/auth/login_screen.dart';
import 'package:note_system/screens/notes_screen.dart';
import 'package:provider/provider.dart';
import 'package:note_system/providers/notes_provider.dart';

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
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/notes': (context) => const NotesScreen(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:note_system/screens/auth/login_screen.dart'; 
// import 'package:note_system/screens/auth/signup_screen.dart';
// import 'package:note_system/screens/home_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Auth App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => const LoginScreen(),
//         '/signup': (context) => const SignupScreen(),
//         '/home': (context) => const HomeScreen(),
//       },
//       // Add this to prevent route errors
//       onUnknownRoute: (settings) => MaterialPageRoute(
//         builder: (context) => const LoginScreen(),
//       ),
//     );
//   }
// }