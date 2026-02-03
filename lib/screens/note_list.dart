import 'package:flutter/material.dart';
import 'package:flutter_sqflite/models/note.dart';
import 'package:flutter_sqflite/utils/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes - Sqflite',
          style: GoogleFonts.mochiyPopPOne(fontSize: 18),
        ),
      ),
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
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        final note = noteList[position];
        return Dismissible(
          key: Key(noteList[position].id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(top: 6, bottom: 5),
            alignment: Alignment.centerRight,
            color: Colors.redAccent,
            child: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          onDismissed: (_) => _delete(context, note),
          child: Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getPriorityColor(note.priority),
                child: _getPriorityIcon(note.priority),
              ),
              title: Text(
                note.title,
                style: GoogleFonts.deliusSwashCaps(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                note.date,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // trailing: GestureDetector(
              //   child: Icon(Icons.delete, color: Colors.grey),
              //   onTap: () => _delete(context, noteList[position]),
              // ),
              onTap: () {
                navigateToDetail('Edit Note', noteList[position]);
              },
            ),
          ),
        );
      },
    );
  }

  Icon _getPriorityIcon(int priority) {
    if (priority == 1) {
      return Icon(Icons.priority_high, color: Colors.red.shade800);
    }
    return Icon(Icons.low_priority, color: Colors.yellow.shade800);
  }

  Color _getPriorityColor(int priority) {
    if (priority == 1) return Colors.red;
    return Colors.yellow;

    // switch (priority) {
    //   case 1:
    //     return Colors.red;
    //   case 2:
    //     return Colors.yellow;
    //   default:
    //     return Colors.yellow;
    // }
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

  void updateListView() async {
    final noteList = await databaseHelper.getNoteList();
    setState(() {
      this.noteList = noteList;
      count = noteList.length;
    });

    // final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    // dbFuture.then((database) {
    //   Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
    //   noteListFuture.then((noteList) {
    //     setState(() {
    //       this.noteList = noteList;
    //       count = noteList.length;
    //     });
    //   });
    // });
  }

  void navigateToDetail(String title, Note note) async {
    bool? result = await Navigator.push(
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
