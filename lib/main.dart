import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserScreen(),
    );
  }
}

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bornController = TextEditingController();

  void addUser() {
    final user = <String, dynamic>{
      "first": _firstNameController.text,
      "last": _lastNameController.text,
      "born": int.parse(_bornController.text),
    };

    db.collection("users").add(user).then((DocumentReference doc) {
      print('DocumentSnapshot added with ID: ${doc.id}');
      _clearInputFields();
    });
  }

  void updateUser(String docId) {
    final updatedUser = <String, dynamic>{
      "first": _firstNameController.text,
      "last": _lastNameController.text,
      "born": int.parse(_bornController.text),
    };

    db.collection("users").doc(docId).update(updatedUser).then((_) {
      print('DocumentSnapshot updated with ID: $docId');
      _clearInputFields();
    });
  }

  void deleteUser(String docId) {
    db.collection("users").doc(docId).delete().then((_) {
      print('DocumentSnapshot deleted with ID: $docId');
    });
  }

  void _clearInputFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _bornController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore CRUD Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _bornController,
              decoration: InputDecoration(labelText: 'Year Born'),
              keyboardType: TextInputType.number,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: addUser,
                child: Text('Add User'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update with hardcoded document ID for demonstration
                  updateUser("document_id_here");
                },
                child: Text('Update User'),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.collection("users").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                return ListView.builder(
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    var doc = data.docs[index];
                    var user = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text("${user['first']} ${user['last']}"),
                      subtitle: Text("Born: ${user['born']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteUser(doc.id),
                      ),
                      onTap: () {
                        _firstNameController.text = user['first'];
                        _lastNameController.text = user['last'];
                        _bornController.text = user['born'].toString();
                        // You can implement a way to pass the doc.id for update
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
