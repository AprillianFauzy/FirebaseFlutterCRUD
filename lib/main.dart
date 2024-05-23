import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart'; // Mengimport konfigurasi Firebase yang disimpan terpisah.

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Memastikan inisialisasi widget Flutter.
  await Firebase.initializeApp(
    // Inisialisasi Firebase dengan FirebaseOptions yang diambil dari platform default.
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp()); // Menjalankan aplikasi Flutter.
}

class MyApp extends StatelessWidget {
  // Kelas MyApp sebagai root widget aplikasi.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Mengatur tema dan konfigurasi aplikasi.
      home:
          UserScreen(), // Menetapkan UserScreen sebagai halaman awal aplikasi.
    );
  }
}

class UserScreen extends StatefulWidget {
  // Kelas UserScreen sebagai StatefulWidget.
  @override
  _UserScreenState createState() =>
      _UserScreenState(); // Membuat instance dari _UserScreenState.
}

class _UserScreenState extends State<UserScreen> {
  // Kelas _UserScreenState sebagai State.
  final FirebaseFirestore db =
      FirebaseFirestore.instance; // Menginisialisasi instance Firestore.

  final TextEditingController _firstNameController =
      TextEditingController(); // Controller untuk input First Name.
  final TextEditingController _lastNameController =
      TextEditingController(); // Controller untuk input Last Name.
  final TextEditingController _bornController =
      TextEditingController(); // Controller untuk input Year Born.

  void addUser() {
    // Method untuk menambahkan user baru ke Firestore.
    final user = <String, dynamic>{
      // Membuat objek user dari input pengguna.
      "first": _firstNameController.text,
      "last": _lastNameController.text,
      "born": int.parse(_bornController.text),
    };

    db.collection("users").add(user).then((DocumentReference doc) {
      // Menambahkan user ke koleksi "users" di Firestore.
      print(
          'DocumentSnapshot added with ID: ${doc.id}'); // Log penambahan berhasil.
      _clearInputFields(); // Menghapus input fields setelah penambahan.
    });
  }

  void updateUser(String docId) {
    // Method untuk memperbarui user di Firestore.
    final updatedUser = <String, dynamic>{
      // Membuat objek user yang diperbarui.
      "first": _firstNameController.text,
      "last": _lastNameController.text,
      "born": int.parse(_bornController.text),
    };

    db.collection("users").doc(docId).update(updatedUser).then((_) {
      // Memperbarui user di Firestore.
      print(
          'DocumentSnapshot updated with ID: $docId'); // Log pembaruan berhasil.
      _clearInputFields(); // Menghapus input fields setelah pembaruan.
    });
  }

  void deleteUser(String docId) {
    // Method untuk menghapus user dari Firestore.
    db.collection("users").doc(docId).delete().then((_) {
      // Menghapus user dari Firestore.
      print(
          'DocumentSnapshot deleted with ID: $docId'); // Log penghapusan berhasil.
    });
  }

  void _clearInputFields() {
    // Method untuk menghapus isi input fields.
    _firstNameController.clear();
    _lastNameController.clear();
    _bornController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Method untuk membangun tampilan widget.
    return Scaffold(
      // Widget Scaffold sebagai layout dasar aplikasi.
      appBar: AppBar(
        // AppBar sebagai bagian atas aplikasi.
        title: Text('Firestore CRUD Example'), // Judul AppBar.
      ),
      body: Column(
        // Widget Column untuk menata widget secara vertikal.
        children: [
          // Input fields untuk nama dan tahun lahir.
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
          // Tombol untuk menambahkan dan memperbarui user.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: addUser,
                child: Text('Add User'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update dengan ID dokumen tertentu untuk demonstrasi.
                  updateUser("document_id_here");
                },
                child: Text('Update User'),
              ),
            ],
          ),
          // Daftar user yang ditampilkan dalam ListView.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection("users")
                  .snapshots(), // Mendengarkan perubahan pada koleksi "users".
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  // Menangani kesalahan jika terjadi.
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Menampilkan indikator loading saat data sedang dimuat.
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData; // Mengambil data snapshot.

                return ListView.builder(
                  // Membangun daftar user dalam ListView.
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    var doc = data.docs[index]; // Dokumen user saat ini.
                    var user = doc.data()
                        as Map<String, dynamic>; // Data pengguna dari dokumen.
                    return ListTile(
                      // Widget ListTile untuk menampilkan data pengguna.
                      title: Text("${user['first']} ${user['last']}"),
                      subtitle: Text("Born: ${user['born']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteUser(
                            doc.id), // Menghapus user saat tombol di tekan.
                      ),
                      onTap: () {
                        _firstNameController.text = user['first'];
                        _lastNameController.text = user['last'];
                        _bornController.text = user['born'].toString();
                        // Anda dapat mengimplementasikan cara untuk melewati doc.id untuk memperbarui.
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
