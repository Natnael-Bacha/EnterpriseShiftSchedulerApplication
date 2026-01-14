import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shiftmanager/utility/constant.dart';

class MongoDatabase {
  static final MongoDatabase _instance = MongoDatabase._internal();
  factory MongoDatabase() => _instance;

  MongoDatabase._internal();

  Db? db;

  Future<void> connect() async {
    if (db != null && db!.isConnected) return;

    db = await Db.create(MONGO_URL);
    await db!.open();
    debugPrint("✅ Database connected");
  }

  DbCollection getCollection(String colName) {
    if (db == null || !db!.isConnected) {
      throw Exception("Database not connected");
    }
    return db!.collection(colName);
  }

  Future<void> disconnect() async {
    await db?.close();
  }
}
