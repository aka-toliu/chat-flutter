import 'package:chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp( MaterialApp(
    home: ChatScreen(),
    theme: ThemeData(
      iconTheme: IconThemeData(
        color: Colors.green
      )
    ),
  ));

/*
  final user = <String, dynamic>{
    "first": "Túlio",
    "last": "Santos",
    "born": 1998
  };
*/

/*  FirebaseFirestore.instance.collection("users").add(user).then((DocumentReference doc) =>
      print('DocumentSnapshot added with ID: ${doc.id}'));*/

  /*FirebaseFirestore.instance.collection("col").doc("doc").set({"texto": "Marcello"});*/

}
