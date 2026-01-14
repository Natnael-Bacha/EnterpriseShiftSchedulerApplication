import 'package:flutter/material.dart';
import 'package:shiftmanager/models/adminModel.dart';
import 'package:shiftmanager/utility/mongoDB.dart';

class AdminRepository {
  final _collection = MongoDatabase().getCollection('admins');

  Future<bool> addAdmin(AdminModel admin) async {
    try {
      var result = await _collection.insertOne(admin.toMap());
      return result.isSuccess;
    } catch (e) {
      debugPrint("Error adding admin: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAdminById(String authId) async {
    return await _collection.findOne({'firebaseAuthId': authId});
  }
}
