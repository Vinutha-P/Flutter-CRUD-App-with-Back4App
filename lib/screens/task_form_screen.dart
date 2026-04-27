import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/back4app_service.dart';
import '../widgets/app_toast.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final TaskModel? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _service = Back4AppService();
  bool _isCompleted = false;
  bool _isLoading = false;

  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _isCompleted = widget.task!.isCompleted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    bool isSuccess;

    if (_isEditMode) {
      isSuccess = await _service.updateTask(
        objectId: widget.task!.objectId,
        title: title,
        description: description,
        isCompleted: _isCompleted,
      );
    } else {
      isSuccess = await _service.createTask(
        title: title,
        description: description,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isSuccess) {
      Navigator.of(context).pop(true);
      return;
    }

    AppToast.show(
      context,
      message: _isEditMode ? 'Failed to update task' : 'Failed to create task',
      type: ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Task' : 'Create Task'),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFFF5F7FF)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Text(
                          _isEditMode ? 'Update your task details' : 'Add a new task quickly',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            prefixIcon: Icon(Icons.title_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                        if (_isEditMode) ...[
                          const SizedBox(height: 6),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Mark as completed'),
                            value: _isCompleted,
                            onChanged: (value) => setState(() => _isCompleted = value),
                          ),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submit,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(_isEditMode ? 'Update Task' : 'Create Task'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) ...[
            const ModalBarrier(dismissible: false, color: Colors.black26),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
