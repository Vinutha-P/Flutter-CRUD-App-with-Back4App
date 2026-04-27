import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TaskModel {
  TaskModel({
    required this.objectId,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  final String objectId;
  final String title;
  final String description;
  final bool isCompleted;

  factory TaskModel.fromParseObject(ParseObject object) {
    return TaskModel(
      objectId: object.objectId ?? '',
      title: object.get<String>('title') ?? '',
      description: object.get<String>('description') ?? '',
      isCompleted: object.get<bool>('isCompleted') ?? false,
    );
  }
}
