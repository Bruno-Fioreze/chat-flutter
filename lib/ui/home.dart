import 'package:chat_flutter/ui/text_composer.dart';
import 'package:chat_flutter/ui/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  FirebaseUser _userF;
  bool _loading = false;
  @override
  void initState() {
    super.initState();

    setState(() {
      FirebaseAuth.instance.onAuthStateChanged.listen((user) {
        _userF = user;
        data["uid"] = _userF.uid;
        data["name"] = _userF.displayName;
        data["url"] = _userF.photoUrl;
        data["time"] = Timestamp.now();
      });
    });
  }

  Map<String, dynamic> data = {};

  Future _getUser() async {
    if (_userF != null) {
      return _userF;
    }
    try {
      final GoogleSignInAccount _googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication _googleSignInAuthentication =
          await _googleSignInAccount.authentication;
      final AuthCredential _credential = GoogleAuthProvider.getCredential(
          idToken: _googleSignInAuthentication.idToken,
          accessToken: _googleSignInAuthentication.accessToken);
      final AuthResult _authResult =
          await FirebaseAuth.instance.signInWithCredential(_credential);
      final FirebaseUser user = _authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String text, File file}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldkey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possivel fazer login. tente novamente!"),
        backgroundColor: Colors.red,
      ));
    }

    if (file != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(file);
          setState(() {
            _loading = true;
          });
      StorageTaskSnapshot taskSnap = await task.onComplete;
      String url = await taskSnap.ref.getDownloadURL();
      data["imgUrl"] = url;
    }

    if (text != null) {
      data["text"] = text;
    }
    Firestore.instance.collection("messages").add(data);
    setState(() {
      data["imgUrl"] = "";
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title:
              Text(_userF != null ? "olá, ${_userF.displayName}" : "Chat App"),
              centerTitle: true,
          elevation: 0,
          actions: <Widget>[
            _userF != null
                ? IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      GoogleSignIn().signOut();
                      SnackBar(
                        content: Text("Você saiu com sucesso!"),
                      );
                    })
                : Container()
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded( 
                child: StreamBuilder<QuerySnapshot>(
                    stream:
                        Firestore.instance.collection("messages").orderBy("time").snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        default:
                          List<DocumentSnapshot> documents =
                              snapshot.data.documents.reversed.toList();

                          return ListView.builder(
                              itemCount: documents.length,
                              reverse: true,
                              itemBuilder: (context, index) {
                                return ChatMessage(documents[index].data["uid"],
                                  documents[index].data["uid"] == _userF?.uid
                                );
                              });
                      }
                    })),
            _loading ? LinearProgressIndicator() : Container(),
            TextComposer(_sendMessage),
          ],
        ));
  }
  
}
