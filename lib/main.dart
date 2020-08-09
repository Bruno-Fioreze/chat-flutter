import 'package:flutter/material.dart';
import 'package:chat_flutter/ui/home.dart';


void main() {
  runApp
  (
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        primaryColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue,
        )
      ),
    )
  );
 
}
