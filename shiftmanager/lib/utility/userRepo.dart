import 'package:flutter/material.dart';
import 'package:shiftmanager/models/userModel.dart';
import 'package:shiftmanager/utility/mongoDB.dart';

class UserRepository {
  final _collection = MongoDatabase().getCollection('users');

  Future<bool> addUser(UserModel user) async {
    try {
      final result = await _collection.insertOne(user.toMap());
      return result.isSuccess;
    } catch (e) {
      debugPrint("Error adding user: $e");
      return false;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final users = await _collection.find().toList();
      return users.map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error fetching users: $e");
      return [];
    }
  }
}
