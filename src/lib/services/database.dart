import 'package:flutter/material.dart';
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
      onUpgrade: _onUpgrade,
      version: 2,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      create table settings
        ( interval integer not null
        , theme_mode integer
        , theme_color integer
        )
    ''');
    await db.insert('settings', {
      'interval': 1,
      'theme_mode': 0,
      'theme_color': Colors.deepPurple.value
    });

    await db.execute('''
      create table hosts
        ( id integer primary key autoincrement
        , hostname text not null unique
        , display_name text
        , ping_interval integer
        )
    ''');
    await db.insert('hosts', {'hostname': 'localhost'});
    await db.insert('hosts', {'hostname': '127.0.0.1'});
    await db.insert('hosts', {'hostname': '1.1.1.1'});
    await db.insert('hosts', {'hostname': 'google.com'});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Test versions
    if (oldVersion < 2) {
      await db.execute('drop table settings');
      await db.execute('drop table hosts');
    }
  }

  Future<Settings> getSettings() async {
    var db = await _databaseService.database;
    var settings = await db.query('settings');
    return Settings(
      interval: settings.first['interval'] as int,
      themeMode: settings.first['theme_mode'] as int,
      themeColor: Color(settings.first['theme_color'] as int),
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

  Future setInterval(int interval) async {
    var db = await _databaseService.database;
    await db.update('settings', {'interval': interval});
  }

  Future setThemeMode(ThemeMode themeMode) async {
    var db = await _databaseService.database;
    await db.update('settings', {'theme_mode': themeMode.index});
  }

  Future setThemeColor(Color themeColor) async {
    var db = await _databaseService.database;
    await db.update('settings', {'theme_color': themeColor.value});
  }

  Future<bool> addHost(Host host) async {
    var db = await _databaseService.database;
    var insertRes = await db.insert('hosts', {
      'hostname': host.hostname,
      'display_name': host.displayName,
      'ping_interval': host.pingInterval,
    });
    return insertRes != 0;
  }

  Future<bool> editHost(String oldHostname, Host host) async {
    var db = await _databaseService.database;
    // ignore: unused_local_variable
    var deleteRes = await db
        .delete('hosts', where: 'hostname = ?', whereArgs: [oldHostname]);
    var insertRes = await db.insert('hosts', {
      'hostname': host.hostname,
      'display_name': host.displayName,
      'ping_interval': host.pingInterval,
    });
    return insertRes != 0;
  }

  Future<bool> deleteHost(Host host) async {
    var db = await _databaseService.database;
    var res = await db
        .delete('hosts', where: 'hostname = ?', whereArgs: [host.hostname]);
    return res == 1;
  }
}
