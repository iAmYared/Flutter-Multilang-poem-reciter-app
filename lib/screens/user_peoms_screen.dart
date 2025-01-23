import 'package:flutter/material.dart';
import 'package:peom_reciter_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPoemsScreen extends StatelessWidget {
  final User? user;

  UserPoemsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();

    void _showEditDialog(String poemId, String initialTitle, String initialContent) {
      _titleController.text = initialTitle;
      _contentController.text = initialContent;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple[500],
            title: Text('Edit Poem', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Poem Title',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title, color: Colors.white),
                    filled: true,
                    fillColor: Colors.deepPurple[400],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _contentController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Poem Content',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description, color: Colors.white),
                    filled: true,
                    fillColor: Colors.deepPurple[400],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  if (user != null) {
                    _firestoreService.updatePoem(
                      user!.uid,
                      poemId,
                      _titleController.text,
                      _contentController.text,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My Poems', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple[700],
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getUserPoems(user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final poems = snapshot.data!;
          return ListView.builder(
            itemCount: poems.length,
            itemBuilder: (context, index) {
              final poem = poems[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                color: Colors.deepPurple[600],
                child: ListTile(
                  title: Text(poem['title'], style: TextStyle(color: Colors.white)),
                  subtitle: Text(poem['content'], style: TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          _showEditDialog(poem['id'], poem['title'], poem['content']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          if (user != null) {
                            _firestoreService.deletePoem(user!.uid, poem['id']);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
