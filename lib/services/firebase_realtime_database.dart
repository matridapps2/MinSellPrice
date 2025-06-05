import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RealtimeDatabaseExample extends StatefulWidget {
  @override
  _RealtimeDatabaseExampleState createState() =>
      _RealtimeDatabaseExampleState();
}

class _RealtimeDatabaseExampleState extends State<RealtimeDatabaseExample> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void _addUserData() async {
    String name = _nameController.text.trim();
    String age = _ageController.text.trim();

    if (name.isNotEmpty && age.isNotEmpty) {
      DatabaseReference newUserRef = _database.child('users').push();

      await newUserRef.set({
        'name': name,
        'age': int.parse(age),
        'timestamp': DateTime.now().toIso8601String(),
      });

      _nameController.clear();
      _ageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User added to Realtime Database')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Realtime DB")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Age', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addUserData,
              child: Text('Add to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
