import 'package:mongo_dart/mongo_dart.dart';

class ScheduleModel {
  final ObjectId id;
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;
  final String shiftType;
  final ObjectId createdBy;
  final DateTime createdAt;

  ScheduleModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.startTime,
    required this.endTime,
    required this.shiftType,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'startTime': startTime,
      'endTime': endTime,
      'shiftType': shiftType,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['_id'] as ObjectId,
      userId: map['userId'] as String,
      userName: map['userName'] ?? '',
      startTime: map['startTime'] is DateTime
          ? map['startTime']
          : DateTime.parse(map['startTime']),
      endTime: map['endTime'] is DateTime
          ? map['endTime']
          : DateTime.parse(map['endTime']),
      shiftType: map['shiftType'] ?? '',
      createdBy: map['createdBy'] as ObjectId,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.parse(map['createdAt']),
    );
  }
}
