import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/note.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._createInstance();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}notes.db';

    // Open / Create Database
    var noteDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return noteDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT',
    );
  }

  // Todo: wrie crud Operations down below
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    /*
    var reault = await db.rawQuery(
      'SELECT * FROM $noteTable order by $colPriority ASC',
    );
    */
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    Database db = await database;
    var result = db.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
    return result;
  }

  Future<int> deleteNote(int id) async {
    Database db = await database;
    var result = db.delete(noteTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  // Get Number of objects in Database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db.rawQuery(
      'SELECT COUNT (*) from $noteTable',
    );
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;
    List<Note> noteList = [];

    noteMapList.map((noteMap) {
      noteList.add(Note.fromMapObject(noteMap));
    });
    return noteList;
  }
}
