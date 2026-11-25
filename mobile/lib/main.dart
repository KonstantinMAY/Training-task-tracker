import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

void main() {
  runApp(const TaskTrackerApp());
}

class TaskTrackerApp extends StatefulWidget {
  const TaskTrackerApp({super.key});

  @override
  State<TaskTrackerApp> createState() => _TaskTrackerAppState();
}

class _TaskTrackerAppState extends State<TaskTrackerApp> {
  ThemeMode themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;
    if (mounted) setState(() => themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final nextMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setState(() => themeMode = nextMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', nextMode == ThemeMode.dark);
  }

  ThemeData buildLightTheme() {
    const background = Color(0xFFF1F2F5);
    const foreground = Color(0xFF202938);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: foreground, brightness: Brightness.light,
          surface: Colors.white, primary: foreground),
      appBarTheme: const AppBarTheme(backgroundColor: background, foregroundColor: foreground,
          elevation: 0, centerTitle: false),
      cardColor: Colors.white,
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFFF7F7F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD5D9E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD5D9E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: foreground, width: 1.4)),
      ),
    );
  }

  ThemeData buildDarkTheme() {
    const background = Color(0xFF000000);
    const surface = Color(0xFF1F1F1F);
    const accent = Color(0xFFFFD21F);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark,
          surface: surface, primary: accent, onPrimary: Colors.black),
      appBarTheme: const AppBarTheme(backgroundColor: surface, foregroundColor: accent,
          elevation: 0, centerTitle: false),
      cardColor: surface,
      dialogTheme: const DialogThemeData(backgroundColor: surface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFF292929),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF444444))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF444444))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accent, width: 1.4)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskTracker',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      home: AuthGate(onToggleTheme: toggleTheme),
    );
  }
}


class TaskData {
  final String? id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String deadline;

  const TaskData({
    this.id,
    required this.title,
    this.description = '',
    required this.status,
    required this.priority,
    required this.deadline,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'deadline': deadline,
      };

  factory TaskData.fromJson(Map<String, dynamic> json) {
    return TaskData(
      id: json['id']?.toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: statusFromApi((json['status'] ?? 'todo').toString()),
      priority: priorityFromApi((json['priority'] ?? 'medium').toString()),
      deadline: deadlineFromApi(json['deadline']?.toString()),
    );
  }
}

String statusFromApi(String value) {
  switch (value) {
    case 'todo':
      return 'К выполнению';
    case 'in_progress':
      return 'В работе';
    case 'review':
      return 'На проверке';
    case 'done':
      return 'Готово';
    default:
      return value;
  }
}

String statusToApi(String value) {
  switch (value) {
    case 'К выполнению':
      return 'todo';
    case 'В работе':
      return 'in_progress';
    case 'На проверке':
      return 'review';
    case 'Готово':
      return 'done';
    default:
      return 'todo';
  }
}

String priorityFromApi(String value) {
  switch (value) {
    case 'low':
      return 'Низкий';
    case 'medium':
      return 'Средний';
    case 'high':
      return 'Высокий';
    default:
      return value;
  }
}

String priorityToApi(String value) {
  switch (value) {
    case 'Низкий':
      return 'low';
    case 'Средний':
      return 'medium';
    case 'Высокий':
      return 'high';
    default:
      return 'medium';
  }
}

String deadlineFromApi(String? value) {
  if (value == null || value.isEmpty) return 'Не указан';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${parsed.day.toString().padLeft(2, '0')}.'
      '${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
}

String? deadlineToApi(String value) {
  final match = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(value);
  if (match == null) return null;
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  return '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

class AuthGate extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AuthGate({super.key, required this.onToggleTheme});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    restoreSession();
  }

  Future<void> restoreSession() async {
    try {
      await ApiService.loadToken();
      if (ApiService.token != null) {
        user = await ApiService.getProfile();
      }
    } catch (_) {
      await ApiService.logout();
      user = null;
    }
    if (mounted) setState(() => loading = false);
  }

  void onAuthenticated(Map<String, dynamic> data) {
    setState(() {
      user = Map<String, dynamic>.from(data['user'] as Map);
    });
  }

  Future<void> logout() async {
    await ApiService.logout();
    if (!mounted) return;
    setState(() => user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null) {
      return AuthScreen(onAuthenticated: onAuthenticated);
    }
    return TaskListScreen(
      onToggleTheme: widget.onToggleTheme,
      user: user!,
      onLogout: logout,
    );
  }
}

class AuthScreen extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => error = 'Заполни электронную почту и пароль.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = isLogin
          ? await ApiService.login(email, password)
          : await ApiService.register(email, password);
      widget.onAuthenticated(result);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.checklist_rounded, size: 58),
                  const SizedBox(height: 18),
                  const Text(
                    'TaskTracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin ? 'Войди в свой аккаунт' : 'Создай новый аккаунт',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Электронная почта',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onSubmitted: (_) => loading ? null : submit(),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: loading ? null : submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isLogin ? 'Войти' : 'Зарегистрироваться'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () => setState(() {
                              isLogin = !isLogin;
                              error = null;
                            }),
                    child: Text(
                      isLogin
                          ? 'Нет аккаунта? Зарегистрироваться'
                          : 'Уже есть аккаунт? Войти',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

class TaskCard extends StatelessWidget {
  final TaskData task;
  final bool overdue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.overdue,
    required this.onEdit,
    required this.onDelete,
  });

  Color get priorityColor {
    switch (task.priority) {
      case 'Высокий':
        return const Color(0xFFB42318);
      case 'Средний':
        return const Color(0xFFB54708);
      default:
        return const Color(0xFF027A48);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: overdue ? const Color(0xFFF2B8B5) : Theme.of(context).dividerColor),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Редактировать',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 21),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Удалить',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 21),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: [
              InfoChip(
                icon: Icons.circle,
                label: task.status,
                color: task.status == 'Готово'
                    ? const Color(0xFF027A48)
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
              ),
              InfoChip(icon: Icons.flag_outlined, label: task.priority, color: priorityColor),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Icon(
                overdue ? Icons.warning_amber_rounded : Icons.calendar_today_outlined,
                size: 16,
                color: overdue ? Colors.red : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  overdue ? 'Просрочено · ${task.deadline}' : 'Дедлайн: ${task.deadline}',
                  style: TextStyle(
                    fontSize: 12,
                    color: overdue ? Colors.red.shade700 : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: overdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const InfoChip({super.key, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class EmptyTasksState extends StatelessWidget {
  final bool hasAnyTasks;
  final VoidCallback onReset;

  const EmptyTasksState({super.key, required this.hasAnyTasks, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hasAnyTasks ? Icons.search_off : Icons.task_alt, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              hasAnyTasks ? 'Ничего не найдено' : 'Задач пока нет',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              hasAnyTasks
                  ? 'Попробуй изменить запрос или фильтры.'
                  : 'Добавь первую задачу, нажав на кнопку ниже.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (hasAnyTasks) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onReset, child: const Text('Сбросить фильтры')),
            ],
          ],
        ),
      ),
    );
  }
}

class TaskEditorDialog extends StatefulWidget {
  final TaskData? task;

  const TaskEditorDialog({super.key, this.task});

  @override
  State<TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController deadlineController;
  late String status;
  late String priority;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? '');
    descriptionController = TextEditingController(text: widget.task?.description ?? '');
    deadlineController = TextEditingController(text: widget.task?.deadline ?? '');
    status = widget.task?.status ?? 'К выполнению';
    priority = widget.task?.priority ?? 'Средний';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  Future<void> chooseDeadline() async {
    final now = DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2035);
    var initialDate = now;
    final match = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(deadlineController.text);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      final year = int.tryParse(match.group(3)!);
      if (day != null && month != null && year != null) {
        final candidate = DateTime(year, month, day);
        if (candidate.year == year && candidate.month == month && candidate.day == day &&
            !candidate.isBefore(firstDate) && !candidate.isAfter(lastDate)) {
          initialDate = candidate;
        }
      }
    }
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Выбери дедлайн',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );
    if (selectedDate != null) {
      setState(() {
        deadlineController.text =
            '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Редактировать задачу' : 'Новая задача'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Название задачи'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Статус'),
                items: ['К выполнению', 'В работе', 'На проверке', 'Готово']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => status = value ?? status),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Приоритет'),
                items: ['Низкий', 'Средний', 'Высокий']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => priority = value ?? priority),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deadlineController,
                readOnly: true,
                onTap: chooseDeadline,
                decoration: const InputDecoration(
                  labelText: 'Дедлайн',
                  hintText: 'Выбери дату',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            if (titleController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              TaskData(
                id: widget.task?.id,
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                status: status,
                priority: priority,
                deadline: deadlineController.text.trim().isEmpty
                    ? 'Не указан'
                    : deadlineController.text.trim(),
              ),
            );
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}


class ProfileDialog extends StatelessWidget {
  final String email;

  const ProfileDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Профиль пользователя'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(email, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              'Ты вошла в аккаунт TaskTracker.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Закрыть'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Выйти из аккаунта'),
        ),
      ],
    );
  }
}
