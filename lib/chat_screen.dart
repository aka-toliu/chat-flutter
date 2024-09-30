import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
    });
  }

  Future<User?> _getUser() async {

      try {

        final GoogleSignInAccount? googleSignInAccount =
            await googleSignIn.signIn();

        final GoogleSignInAuthentication? googleSignInAuthentication =
            await googleSignInAccount!.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication?.idToken,
          accessToken: googleSignInAuthentication?.accessToken,
        );

        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);


        final User? user = authResult.user;
        return user;

      } catch (error) {
        print("Error during Google Sign In: $error");
      }

  }

  Future<void> _sendMessage({String? text, File? imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Usuário não está logado."),
        ),
      );
    }

    Map<String, dynamic> data = {
      "uid": user?.uid,
      "senderName": user?.displayName,
      "senderPhotoUrl": user?.photoURL
    };

    if (imgFile != null) {
      // Upload the image
      final ref = FirebaseStorage.instance.ref().child(
          DateTime.now().microsecondsSinceEpoch.toString() +
              '.jpg'); // Add extension
      final uploadTask = ref.putFile(imgFile);

      // Wait for upload and await download URL retrieval
      final taskSnapshot =
          await uploadTask.whenComplete(() => print('Upload complete'));

      final url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url; // Store the actual URL string
    }

    if (text != null) {
      data['text'] = text;
    }

    FirebaseFirestore.instance.collection('messages').add(data).then(
        (DocumentReference doc) =>
            print('DocumentSnapshot added with ID: ${doc.id}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Whatsapp 2"),
        backgroundColor: Colors.greenAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('messages').snapshots(),
            builder: (contact, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  List<DocumentSnapshot> documents =
                      snapshot.data!.docs.reversed.toList();

                  return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(documents[index].get('text')),
                        );
                      });
              }
            },
          )),
          TextComposer(sendMessage: _sendMessage)
        ],
      ),
    );
  }
}
