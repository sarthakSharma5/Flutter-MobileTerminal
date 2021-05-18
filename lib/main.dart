import 'package:code3_terminal/auth.dart';
import 'package:code3_terminal/connect.dart';
import 'package:code3_terminal/execCmd.dart';
import 'package:code3_terminal/viewCmds.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    initialRoute: "/",
    title: 'Mobile Terminal',
    routes: {
      "/": (context) => AuthDB(),
      "/exec": (context) => MyApp(),
      "/login": (context) => LoginScreen(),
      "/view": (context) => ViewCommands(),
    },
  ));
}
