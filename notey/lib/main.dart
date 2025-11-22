import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NoteApp());
}

class NoteApp extends StatefulWidget {
  const NoteApp({super.key});

  @override
  State<NoteApp> createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  bool isDarkMode = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notey',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF1a1a1a),
              primaryColor: const Color(0xFF5B54D9),
              cardColor: const Color(0xFF252525),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1a1a1a),
                elevation: 0,
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFF2F0EA),
              primaryColor: const Color(0xFF023E47),
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF2F0EA),
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF023E47)),
                titleTextStyle: TextStyle(
                  color: Color(0xFF023E47),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      home: HomeScreen(
        isDarkMode: isDarkMode,
        onThemeToggle: toggleTheme,
      ),
    );
  }
}

class Note {
  String id;
  String title;
  String content;
  DateTime lastModified;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.lastModified,
  });
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  Future<void> callPythonBackend() async {
    final url = Uri.parse('http://127.0.0.1:8000/get-message'); 

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSnackBar("Success: ${data['message']}", Colors.green);
      } else {
        _showSnackBar("Error: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection Failed. Is Python running?", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          onSave: (title, content) {
            setState(() {
              notes.insert(
                0,
                Note(
                  id: DateTime.now().toString(),
                  title: title,
                  content: content,
                  lastModified: DateTime.now(),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void _editNote(Note note, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          note: note,
          onSave: (title, content) {
            setState(() {
              notes[index] = Note(
                id: note.id,
                title: title,
                content: content,
                lastModified: DateTime.now(),
              );
            });
          },
          onDelete: () {
            setState(() {
              notes.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : const Color(0xFF023E47);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notey',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_sync, color: textColor), 
            onPressed: callPythonBackend, 
          ),
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: widget.onThemeToggle,
              child: Container(
                width: 60,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: isDark ? 30 : 2,
                      top: 2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color.fromARGB(255, 43, 39, 117) : const Color(0xFF023E47),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'Add Note',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 80,
                          color: isDark ? Colors.grey[700] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes yet',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Material(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          elevation: isDark ? 0 : 2,
                          child: InkWell(
                            onTap: () => _editNote(note, index),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title.isEmpty
                                              ? 'Untitled'
                                              : note.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (note.content.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      note.content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  final Function(String title, String content) onSave;
  final VoidCallback? onDelete;

  const NoteDetailScreen({
    super.key,
    this.note,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty) {
      widget.onSave(_titleController.text, _contentController.text);
      Navigator.pop(context);
    }
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete?.call();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saveNote,
        ),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}