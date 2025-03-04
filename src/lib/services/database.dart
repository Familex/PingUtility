import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/hosts.dart';
import '../models/settings.dart';

class DatabaseService {
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
    await db.execute('''
      create table settings
        ( interval integer not null
        )
    ''');
    await db.insert('settings', {'interval': 1});

    await db.execute('''
      create table hosts
        ( id integer primary key autoincrement
        , hostname text not null
        , display_name text
        , ping_interval integer
        )
    ''');
    await db.insert('hosts', {'hostname': 'localhost'});
    await db.insert('hosts', {'hostname': '127.0.0.1'});
    await db.insert('hosts', {'hostname': '1.1.1.1'});
    await db.insert('hosts', {'hostname': 'google.com'});
  }

  Future<Database> getDatabase() async {
    return await _databaseService.database;
  }

  Future setInterval(int interval) async {
    var db = await _databaseService.database;
    await db.update('settings', {'interval': interval});
  }

  Future<Settings> getSettings() async {
    var db = await _databaseService.database;
    var settings = await db.query('settings');
    return Settings(
      interval: settings.first['interval'] as int,
    );
  }

  Future<List<Host>> getHosts() async {
    var db = await _databaseService.database;
    var hosts = await db.query('hosts');
    return hosts
        .map(
          (e) => Host(
            hostname: e['hostname'] as String,
            displayName: e['display_name'] as String?,
            pingInterval: e['ping_interval'] as int?,
          ),
        )
        .toList();
  }
}
