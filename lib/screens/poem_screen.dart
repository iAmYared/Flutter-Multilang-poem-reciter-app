import 'package:flutter/material.dart';
import 'package:peom_reciter_app/screens/user_peoms_screen.dart';
import 'package:peom_reciter_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'poem_detail_screen.dart';
import 'login_screen.dart';
import 'user_profile_screen.dart';

class PoemScreen extends StatefulWidget {
  @override
  _PoemScreenState createState() => _PoemScreenState();
}

class _PoemScreenState extends State<PoemScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<String> _apiPoems = [];
  List<Map<String, dynamic>> _apiPoemDetails = [];
  int _currentPage = 0;
  final int _poemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchPoems();
  }

  void _fetchPoems() async {
    List<Map<String, dynamic>> poems = await _firestoreService.fetchPoemsFromApi('Shakespeare', 'Sonnet');
    setState(() {
      _apiPoems = poems.map((poem) => poem['title'] as String).toList();
      _apiPoemDetails = poems;
    });
  }

  void _navigateToPoemDetail(BuildContext context, Map<String, dynamic> poem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PoemDetailScreen(poem: poem),
      ),
    );
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _prevPage() {
    setState(() {
      if (_currentPage > 0) _currentPage--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = _currentPage * _poemsPerPage;
    final endIndex = (_currentPage + 1) * _poemsPerPage;
    final displayedPoems = _apiPoems.sublist(startIndex, endIndex.clamp(0, _apiPoems.length));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Poem Reciter', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(248, 12, 240, 202),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal[700],
              ),
              accountName: Text(user?.displayName ?? 'Hello,', style: TextStyle(color: Colors.white)),
              accountEmail: Text(user?.email ?? 'user@example.com', style: TextStyle(color: Colors.white)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  user?.displayName != null ? user!.displayName![0] : 'U',
                  style: TextStyle(fontSize: 40.0, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book, color: Colors.teal[200]),
              title: Text('My Poems', style: TextStyle(color: Colors.teal[200])),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserPoemsScreen(user: user)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.teal[200]),
              title: Text('Profile', style: TextStyle(color: Colors.teal[200])),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.teal[200]),
              title: Text('Logout', style: TextStyle(color: Colors.teal[200])),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: displayedPoems.length,
                itemBuilder: (context, index) {
                  final title = displayedPoems[index];
                  final poem = _apiPoemDetails[startIndex + index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    color: Colors.teal[600],
                    child: ListTile(
                      title: Text(title, style: TextStyle(color: Colors.white)),
                      onTap: () => _navigateToPoemDetail(context, poem),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _prevPage,
                  child: Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.teal[700], padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text('Next'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), backgroundColor: Colors.teal[700],
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
