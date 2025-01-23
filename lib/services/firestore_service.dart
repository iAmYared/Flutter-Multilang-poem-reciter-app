import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _poetryDbUrl = 'https://poetrydb.org/author,title';

  Future<void> saveUser(String uid, String email) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> savePoem(String userId, String title, String content) async {
    await _db.collection('users').doc(userId).collection('poems').add({
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePoem(String userId, String poemId, String title, String content) async {
    await _db.collection('users').doc(userId).collection('poems').doc(poemId).update({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePoem(String userId, String poemId) async {
    await _db.collection('users').doc(userId).collection('poems').doc(poemId).delete();
  }

  Stream<List<Map<String, dynamic>>> getUserPoems(String userId) {
    return _db.collection('users').doc(userId).collection('poems')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => {
          'id': doc.id,
          'title': doc['title'],
          'content': doc['content'],
        })
        .toList()
      );
  }

  Future<List<Map<String, dynamic>>> fetchPoemsFromApi(String author, String title) async {
    final response = await http.get(Uri.parse('$_poetryDbUrl/$author;$title'));
    if (response.statusCode == 200) {
      List poems = jsonDecode(response.body);
      List<Map<String, dynamic>> poemDetails = poems.map((poem) => {
        'title': poem['title'],
        'content': (poem['lines'] as List).join('\n')
      }).toList();
      return poemDetails;
    } else {
      throw Exception('Failed to load poems');
    }
  }
}
