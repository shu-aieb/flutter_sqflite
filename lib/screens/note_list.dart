import 'package:flutter/material.dart';
import 'package:flutter_sqflite/models/note.dart';
import 'package:flutter_sqflite/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'note_detail.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<Note> noteList = [];
  DatabaseHelper databaseHelper = DatabaseHelper();
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList.isEmpty) {
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade300,
        foregroundColor: Colors.blue.shade900,
        elevation: 7.0,
        shape: CircleBorder(),
        onPressed: () {
          navigateToDetail('Add Note', Note('', 2, ''));
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.headlineMedium!;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(noteList[position].priority),
              child: getPriorityIcon(noteList[position].priority),
            ),
            title: Text(noteList[position].title, style: titleStyle),
            subtitle: Text(noteList[position].date),
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey),
              onTap: () => _delete(context, noteList[position]),
            ),
            onTap: () {
              navigateToDetail('Edit Note', noteList[position]);
            },
          ),
        );
      },
    );
  }

  Icon getPriorityIcon(int priority) {
    if (priority == 1) {
      return Icon(Icons.play_arrow);
    } else {
      return Icon(Icons.keyboard_arrow_right);
    }
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void navigateToDetail(String title, Note note) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return NoteDetail(appBarTitle: title, note: note);
        },
      ),
    );
    if (result == true) {
      updateListView();
    }
  }
}
