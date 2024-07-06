import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class Note {
  final String title;
  final String content;

  Note({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    title: json['title'],
    content: json['content'],
  );
}

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = []; 

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('notes');
    if (notesJson != null) {
      setState(() {
        notes = (json.decode(notesJson) as List)
            .map((data) => Note.fromJson(data))
            .toList();
      });
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String notesJson = json.encode(notes.map((note) => note.toJson()).toList());
    await prefs.setString('notes', notesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10.0),
            elevation: 5.0,
            child: ListTile(
              title: Text(
                notes[index].title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
                child: Text(
                  notes[index].content,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Delete'),
                        content: Text('Are you sure you want to delete this note?'),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              setState(() {
                                notes.removeAt(index);
                              });
                              await saveNotes();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              onTap: () async {
                
                final editedNote = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditNotePage(note: notes[index]),
                  ),
                );
                if (editedNote != null) {
                  setState(() {
                    notes[index] = editedNote;
                  });
                  await saveNotes();
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 53, 88, 231),
        onPressed: () async {
          
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditNotePage()),
          );
          if (newNote != null) {
            setState(() {
              notes.add(newNote);
            });
            await saveNotes();
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({Key? key, this.note}) : super(key: key);

  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isError = false;
  bool _isErrorTitle = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                  errorText: _isErrorTitle ? 'Input cannot be left empty' : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _isErrorTitle = false;
                  });
                },
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Content',
                  errorText: _isError ? 'Input cannot be left empty' : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _isError = false;
                  });
                },
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    
                    final title = _titleController.text;
                    final content = _contentController.text;
                    if (title.isEmpty && content.isEmpty) {
                      setState(() {
                        _isErrorTitle = true;
                        _isError = true;
                      });
                    } else if (title.isEmpty) {
                      setState(() {
                        _isErrorTitle = true;
                      });
                    } else if (content.isEmpty) {
                      setState(() {
                        _isError = true;
                      });
                    } else {
                      
                      Navigator.pop(
                        context,
                        Note(
                          title: title,
                          content: content,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 53, 88, 231),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
