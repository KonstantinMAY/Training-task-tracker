
import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models/task_data.dart';
import '../utils/task_helpers.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_tasks_state.dart';
import '../dialogs/task_editor_dialog.dart';
import '../dialogs/profile_dialog.dart';

class TaskListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final Map<String, dynamic> user;
  final Future<void> Function() onLogout;

  const TaskListScreen({
    super.key,
    required this.onToggleTheme,
    required this.user,
    required this.onLogout,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedStatus = 'Все';
  String selectedPriority = 'Все';
  bool isLoading = true;
  bool isSaving = false;
  late String profileEmail;
  List<TaskData> tasks = [];

  @override
  void initState() {
    super.initState();
    profileEmail = (widget.user['email'] ?? '').toString();
    loadTasks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Future<void> loadTasks() async {
    try {
      final data = await ApiService.getTasks();
      final loaded = data
          .map((item) => TaskData.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      if (!mounted) return;
      setState(() {
        tasks = loaded;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showError(e);
    }
  }

  DateTime? parseDeadline(String value) {
    final match = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(value);
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;
    return date;
  }

  bool isOverdue(TaskData task) {
    if (task.status == 'Готово') return false;
    final date = parseDeadline(task.deadline);
    if (date == null) return false;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return date.isBefore(todayOnly);
  }

  List<TaskData> get visibleTasks {
    final query = searchController.text.trim().toLowerCase();
    return tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(query);
      final matchesStatus = selectedStatus == 'Все' || task.status == selectedStatus;
      final matchesPriority = selectedPriority == 'Все' || task.priority == selectedPriority;
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  Future<void> addTask() async {
    final newTask = await showDialog<TaskData>(
      context: context,
      builder: (_) => const TaskEditorDialog(),
    );
    if (newTask == null) return;

    setState(() => isSaving = true);
    try {
      final created = await ApiService.createTask(
        title: newTask.title,
        description: newTask.description,
        priority: priorityToApi(newTask.priority),
        deadline: deadlineToApi(newTask.deadline),
      );
      final task = TaskData.fromJson(created);
      if (task.status != newTask.status) {
        await ApiService.updateTaskStatus(task.id!, statusToApi(newTask.status));
        final updated = TaskData(
          id: task.id,
          title: task.title,
          description: task.description,
          status: newTask.status,
          priority: task.priority,
          deadline: task.deadline,
        );
        if (mounted) setState(() => tasks.insert(0, updated));
      } else if (mounted) {
        setState(() => tasks.insert(0, task));
      }
    } catch (e) {
      showError(e);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> editTask(TaskData task) async {
    final editedTask = await showDialog<TaskData>(
      context: context,
      builder: (_) => TaskEditorDialog(task: task),
    );
    if (editedTask == null || task.id == null) return;

    setState(() => isSaving = true);
    try {
      final updated = await ApiService.updateTask(
        task.id!,
        title: editedTask.title,
        description: editedTask.description,
        priority: priorityToApi(editedTask.priority),
      );
      if (editedTask.status != task.status) {
        await ApiService.updateTaskStatus(task.id!, statusToApi(editedTask.status));
      }
      if (!mounted) return;
      final serverTask = TaskData.fromJson(updated);
      setState(() {
        final index = tasks.indexOf(task);
        if (index != -1) {
          tasks[index] = TaskData(
            id: task.id,
            title: serverTask.title,
            description: serverTask.description,
            status: editedTask.status,
            priority: serverTask.priority,
            // Текущая схема PATCH не обновляет дедлайн, поэтому сохраняем серверное значение.
            deadline: task.deadline,
          );
        }
      });
      if (editedTask.deadline != task.deadline && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дедлайн при редактировании пока не обновляется на сервере.')),
        );
      }
    } catch (e) {
      showError(e);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> deleteTask(TaskData task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text('Задача «${task.title}» будет удалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || task.id == null) return;

    try {
      await ApiService.deleteTask(task.id!);
      if (mounted) setState(() => tasks.remove(task));
    } catch (e) {
      showError(e);
    }
  }

  Future<void> openProfile() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => ProfileDialog(email: profileEmail),
    );
    if (shouldLogout == true) await widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final shownTasks = visibleTasks;
    final overdueCount = tasks.where(isOverdue).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TaskTracker',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.4),
        ),
        actions: [
          IconButton(
            tooltip: Theme.of(context).brightness == Brightness.dark ? 'Светлая тема' : 'Тёмная тема',
            onPressed: widget.onToggleTheme,
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          IconButton(
            tooltip: 'Профиль',
            onPressed: openProfile,
            icon: const Icon(Icons.account_circle_outlined, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Мои задачи',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                '${tasks.length} ${taskWord(tasks.length)} · $overdueCount просрочено',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Поиск по названию задачи',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                    tooltip: 'Очистить поиск',
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Все', 'К выполнению', 'В работе', 'На проверке', 'Готово'].map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: selectedStatus == status,
                        onSelected: (_) => setState(() => selectedStatus = status),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: selectedStatus == status ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: selectedStatus == status ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Приоритет:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedPriority,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                      ),
                      items: ['Все', 'Высокий', 'Средний', 'Низкий']
                          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                          .toList(),
                      onChanged: (value) => setState(() => selectedPriority = value ?? 'Все'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : shownTasks.isEmpty
                    ? EmptyTasksState(
                  hasAnyTasks: tasks.isNotEmpty,
                  onReset: () {
                    searchController.clear();
                    setState(() {
                      selectedStatus = 'Все';
                      selectedPriority = 'Все';
                    });
                  },
                )
                    : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: shownTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = shownTasks[index];
                    return TaskCard(
                      task: task,
                      overdue: isOverdue(task),
                      onEdit: () => editTask(task),
                      onDelete: () => deleteTask(task),
                    );
                  },
                ),
              ),
              if (isSaving)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSaving ? null : addTask,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Добавить задачу'),
      ),
    );
  }

  String taskWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'задача';
    if ([2, 3, 4].contains(count % 10) && !(count % 100 >= 12 && count % 100 <= 14)) {
      return 'задачи';
    }
    return 'задач';
  }
}
