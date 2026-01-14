import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shiftmanager/models/scheduleModel.dart';
import 'package:shiftmanager/utility/mongoDB.dart';

class ScheduleRepository {
  final _collection = MongoDatabase().getCollection('schedules');

  Future<void> ensureIndexes() async {
    await _collection.createIndex(keys: {'userId': 1, 'startTime': 1});
  }

  Future<bool> assignSchedule(ScheduleModel schedule) async {
    try {
      final overlapSelector = where
          .eq('userId', schedule.userId)
          .lt('startTime', schedule.endTime)
          .gt('endTime', schedule.startTime);

      final overlappingSchedules = await _collection
          .find(overlapSelector)
          .toList();

      if (overlappingSchedules.isNotEmpty) {
        debugPrint(
          "Schedule overlap detected. Count: ${overlappingSchedules.length}",
        );
        return false;
      }

      final result = await _collection.insertOne(schedule.toMap());
      return result.isSuccess;
    } catch (e) {
      debugPrint("Error assigning schedule: $e");
      return false;
    }
  }

  Future<List<ScheduleModel>> getSchedulesForUser(String userId) async {
    try {
      final selector = where.eq('userId', userId).sortBy('startTime');
      final data = await _collection.find(selector).toList();

      return data.map((e) => ScheduleModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error fetching schedules: $e");
      return [];
    }
  }
}
