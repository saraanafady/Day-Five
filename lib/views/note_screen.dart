import 'package:day5/controllers/hive_controller.dart';
import 'package:day5/controllers/sqlite_controller.dart';
import 'package:day5/models/note.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

enum StorageType { hive, sqlite }

class _NotesScreenState extends State<NotesScreen> {
  final SqliteController sqliteController = SqliteController();
  final HiveController hiveController = HiveController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Note> _notes = [];
  StorageType selectedStorage = StorageType.hive;

  void _initHive() async {
    hiveController.init();
  }

  void _loadNotes() async {
    if (selectedStorage == StorageType.sqlite) {
      final notes = await sqliteController.getNotes();
      setState(() {
        _notes = notes;
      });
    } else if (selectedStorage == StorageType.hive) {
      final notes = await hiveController.getNotes();
      setState(() {
        _notes = notes;
      });
    }
  }

  void _addNote() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      return;
    }

    final note = Note(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.insert(note);
    } else if (selectedStorage == StorageType.hive) {
      hiveController.add(note);
    }

    _titleController.clear();
    _descriptionController.clear();

    _loadNotes();
  }

  void deleteNote(int? id) async {
    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.delete(id);
    } else {
      hiveController.delete(id);
    }
    _loadNotes();
  }

  @override
  void initState() {
    super.initState();
    _initHive();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Notes'), backgroundColor: Colors.teal),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create a Note",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addNote,
                            icon: Icon(Icons.add),
                            label: Text("Add Note"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<StorageType>(
                          value: selectedStorage,
                          items: [
                            DropdownMenuItem(
                              value: StorageType.sqlite,
                              child: Text('SQLite'),
                            ),
                            DropdownMenuItem(
                              value: StorageType.hive,
                              child: Text('Hive'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStorage = value!;
                            });
                            _loadNotes();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        hiveController.clear();
                        _loadNotes();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("All Hive notes cleared")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Clear Hive Notes"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _notes.isEmpty
                    ? Center(child: Text("No notes available"))
                    : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              note.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(note.description),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (selectedStorage == StorageType.hive) {
                                  deleteNote(index);
                                } else {
                                  deleteNote(note.id);
                                }
                              },
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
