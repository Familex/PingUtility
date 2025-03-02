import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../structs/settings.dart';

class DatabaseService extends ChangeNotifier {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'data.db');

    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("create table settings(interval integer)");
    await db.insert('settings', {'interval': 1000});
  }

  Future<Database> getDatabase() async {
    return await _databaseService.database;
  }

  Future setInterval(int interval) async {
    var db = await _databaseService.database;
    await db.update('settings', {'interval': interval});
    notifyListeners();
  }

  Future<Settings> getSettings() async {
    var db = await _databaseService.database;
    var settings = await db.query('settings');
    return Settings(
      interval: settings.first['interval'] as int,
    );
  }
}
