import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../back4app_config.dart';
import '../models/task_model.dart';

class Back4AppService {
  static const String _taskClass = 'Task';
  static const String _studentEmailDomain = '@wilp.bits-pilani.ac.in';

  static Future<void> init() async {
    await Parse().initialize(
      Back4AppConfig.applicationId,
      Back4AppConfig.serverUrl,
      clientKey: Back4AppConfig.clientKey,
      autoSendSessionId: true,
      debug: false,
    );
  }

  Future<ParseResponse> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = ParseUser(normalizedEmail, password, normalizedEmail);
    return user.signUp();
  }

  Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      await user.logout();
    }
  }

  Future<ParseResponse> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final loginUser = ParseUser(normalizedEmail, password, null);
    return loginUser.login();
  }

  bool isStudentEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return normalized.endsWith(_studentEmailDomain);
  }

  QueryBuilder<ParseObject> buildCurrentUserTaskQuery(ParseUser user) {
    return QueryBuilder<ParseObject>(ParseObject(_taskClass))
      ..whereEqualTo('owner', user.toPointer())
      ..orderByDescending('updatedAt');
  }

  Future<ParseUser?> getCurrentUser() async {
    return await ParseUser.currentUser() as ParseUser?;
  }

  Future<Subscription<ParseObject>> createLiveQuerySubscription({
    required QueryBuilder<ParseObject> query,
    required void Function() onChange,
  }) async {
    final subscription = await LiveQuery().client.subscribe(query);
    subscription.on(LiveQueryEvent.create, (_) => onChange());
    subscription.on(LiveQueryEvent.update, (_) => onChange());
    subscription.on(LiveQueryEvent.delete, (_) => onChange());
    subscription.on(LiveQueryEvent.enter, (_) => onChange());
    subscription.on(LiveQueryEvent.leave, (_) => onChange());
    return subscription;
  }

  Future<void> closeLiveQuerySubscription({
    required Subscription<ParseObject> subscription,
  }) async {
    LiveQuery().client.unSubscribe(subscription);
  }

  Future<List<TaskModel>> getTasksForCurrentUser() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) return <TaskModel>[];

    final query = buildCurrentUserTaskQuery(user);
    final response = await query.query();
    if (!response.success || response.results == null) {
      return <TaskModel>[];
    }

    final data = response.results!.cast<ParseObject>();
    return data.map(TaskModel.fromParseObject).toList();
  }

  Future<bool> createTask({
    required String title,
    required String description,
  }) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) return false;

    final task = ParseObject(_taskClass)
      ..set<String>('title', title)
      ..set<String>('description', description)
      ..set<bool>('isCompleted', false)
      ..set('owner', user.toPointer());

    final response = await task.save();
    return response.success;
  }

  Future<bool> updateTask({
    required String objectId,
    required String title,
    required String description,
    required bool isCompleted,
  }) async {
    final task = ParseObject(_taskClass)
      ..objectId = objectId
      ..set<String>('title', title)
      ..set<String>('description', description)
      ..set<bool>('isCompleted', isCompleted);

    final response = await task.save();
    return response.success;
  }

  Future<bool> toggleTaskCompletion(TaskModel task) {
    return updateTask(
      objectId: task.objectId,
      title: task.title,
      description: task.description,
      isCompleted: !task.isCompleted,
    );
  }

  Future<bool> deleteTask(String objectId) async {
    final task = ParseObject(_taskClass)..objectId = objectId;
    final response = await task.delete();
    return response.success;
  }

  Future<bool> hasActiveSession() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    return user != null && user.sessionToken != null;
  }
}
