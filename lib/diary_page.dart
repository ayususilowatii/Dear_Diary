import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class DiaryPage extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  quill.QuillController _controller = quill.QuillController.basic();
  String _selectedEmoji = '😊';

  final _auth = FirebaseAuth.instance;

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _saveDiaryEntry() async {
    final diaryEntry = DiaryEntry(
      content: _controller.document.toPlainText(),
      emoji: _selectedEmoji,
    );

    final firebaseService = FirebaseService('https://deardiary-ab238.firebaseio.com');
    
    try {
      await firebaseService.saveDiaryEntry(diaryEntry);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Diary entry saved successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save diary entry')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDiaryEntry,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Mood: ', style: TextStyle(fontSize: 18)),
                DropdownButton<String>(
                  value: _selectedEmoji,
                  items: ['😊', '😢', '😠', '😐', '😃'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 24),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEmoji = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: quill.QuillEditor.basic(
                controller: _controller,
                readOnly: false,
              ),
            ),
          ),
          quill.QuillToolbar.basic(controller: _controller),
        ],
      ),
    );
  }
}

class DiaryEntry {
  String content;
  String emoji;

  DiaryEntry({required this.content, required this.emoji});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'emoji': emoji,
    };
  }
}

class FirebaseService {
  final String baseUrl;

  FirebaseService(this.baseUrl);

  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    final url = Uri.parse('$baseUrl/diaryEntries.json');
    final response = await http.post(
      url,
      body: json.encode(entry.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save diary entry');
    }
  }
}
