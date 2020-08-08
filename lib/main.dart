import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_flutter/ui/home.dart';


void main() {
  runApp(MaterialApp(home: Home(),));
  Firestore.instance.collection("mensagens").document("mensagem").setData({"texto":"bruno","lida":true});
  
}
