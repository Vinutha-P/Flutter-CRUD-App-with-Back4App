import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/task_model.dart';
import '../services/back4app_service.dart';
import '../widgets/app_toast.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _service = Back4AppService();
  final List<TaskModel> _tasks = <TaskModel>[];
  bool _isInitialLoading = true;
  bool _isBusy = false;
  String _busyMessage = 'Processing...';
  Subscription<ParseObject>? _liveSubscription;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _setupLiveQuery();
  }

  @override
  void dispose() {
    _disposeLiveQuery();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final fetchedTasks = await _service.getTasksForCurrentUser();
    if (!mounted) return;
    setState(() {
      _tasks
        ..clear()
        ..addAll(fetchedTasks);
      _isInitialLoading = false;
    });
  }

  Future<void> _setupLiveQuery() async {
    final currentUser = await _service.getCurrentUser();
    if (currentUser == null) return;

    final query = _service.buildCurrentUserTaskQuery(currentUser);
    _liveSubscription = await _service.createLiveQuerySubscription(
      query: query,
      onChange: () {
        if (!mounted) return;
        _loadTasks();
      },
    );
  }

  Future<void> _disposeLiveQuery() async {
    if (_liveSubscription != null) {
      await _service.closeLiveQuerySubscription(
        subscription: _liveSubscription!,
      );
    }
  }

  Future<void> _openTaskForm({TaskModel? task}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
    if (changed == true) {
      _loadTasks();
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    setState(() {
      _isBusy = true;
      _busyMessage = 'Deleting task...';
    });
    final success = await _service.deleteTask(task.objectId);
    if (!mounted) return;
    setState(() => _isBusy = false);

    AppToast.show(
      context,
      message: success ? 'Task deleted' : 'Failed to delete task',
      type: success ? ToastType.success : ToastType.error,
    );
    if (success) _loadTasks();
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _busyMessage = task.isCompleted ? 'Marking as pending...' : 'Marking as completed...';
    });
    final success = await _service.toggleTaskCompletion(task);
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (!success) {
      AppToast.show(
        context,
        message: 'Failed to update task status',
        type: ToastType.error,
      );
      return;
    }

    final index = _tasks.indexWhere((item) => item.objectId == task.objectId);
    if (index >= 0) {
      _tasks[index] = TaskModel(
        objectId: task.objectId,
        title: task.title,
        description: task.description,
        isCompleted: !task.isCompleted,
      );
      setState(() {});
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isBusy = true;
      _busyMessage = 'Logging out...';
    });
    await _service.logout();
    if (!mounted) return;
    setState(() => _isBusy = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            onPressed: _isBusy ? null : _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B4BFF), Color(0xFF7B6DFF)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Productivity Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_tasks.length} tasks • Pull down to sync',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: _isInitialLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _tasks.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 140),
                                Icon(Icons.task_alt_rounded, size: 72, color: Color(0xFF9AA3C3)),
                                SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    'No tasks yet.\nTap + to create one.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7392)),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _tasks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                return Card(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        task.description.isEmpty
                                            ? 'No description provided'
                                            : task.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    leading: Checkbox(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      value: task.isCompleted,
                                      onChanged: (_) => _toggleTaskCompletion(task),
                                    ),
                                    onTap: () => _openTaskForm(task: task),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded),
                                      onPressed: _isBusy ? null : () => _deleteTask(task),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
          if (_isBusy) ...[
            const ModalBarrier(dismissible: false, color: Colors.black38),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(_busyMessage, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isBusy ? null : () => _openTaskForm(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
