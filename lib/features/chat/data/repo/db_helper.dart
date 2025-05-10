// lib/helpers/dbHelper.dart
import 'package:notte_chat/features/chat/data/model/chat_model.dart';
import 'package:notte_chat/features/chat/data/repo/db_helper_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper implements DBHelperInterface {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'nottechat.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            createdAt TEXT,
            pdfTexts TEXT,
            pdfPaths TEXT,
            shareId TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId INTEGER,
            text TEXT,
            isUser INTEGER,
            isAudio INTEGER,
            createdAt TEXT,
            FOREIGN KEY (sessionId) REFERENCES sessions (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS messages');
        await db.execute('DROP TABLE IF EXISTS sessions');
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            createdAt TEXT,
            pdfTexts TEXT,
            pdfPaths TEXT,
            shareId TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId INTEGER,
            text TEXT,
            isUser INTEGER,
            isAudio INTEGER,
            createdAt TEXT,
            FOREIGN KEY (sessionId) REFERENCES sessions (id)
          )
        ''');
      },
      version: 3,
    );
  }

  @override
  Future<void> init() async {
    await database; // Initialize the database
  }

  @override
  Future<List<ChatSession>> loadSessions() async {
    final db = await database;
    final sessionMaps = await db.query('sessions');
    List<ChatSession> sessions = [];
    for (var sessionMap in sessionMaps) {
      final messageMaps = await db.query('messages', where: 'sessionId = ?', whereArgs: [sessionMap['id']]);
      final messages = messageMaps.map((m) => ChatMessage.fromMap(m)).toList();
      sessions.add(ChatSession.fromMap(sessionMap, messages));
    }
    return sessions;
  }

  @override
  Future<int> insertSession(ChatSession session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  @override
  Future<int> insertMessage(ChatMessage message, int sessionId) async {
    final db = await database;
    return await db.insert('messages', message.toMap(sessionId));
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    final db = await database;
    await db.delete('messages', where: 'sessionId = ?', whereArgs: [sessionId]);
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }
}
