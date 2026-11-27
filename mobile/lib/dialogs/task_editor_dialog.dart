
import 'package:flutter/material.dart';
import '../../models/task_data.dart';

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

    final match = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$')
        .firstMatch(deadlineController.text);

    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      final year = int.tryParse(match.group(3)!);

      if (day != null && month != null && year != null) {
        final candidate = DateTime(year, month, day);
        if (candidate.year == year &&
            candidate.month == month &&
            candidate.day == day &&
            !candidate.isBefore(firstDate) &&
            !candidate.isAfter(lastDate)) {
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
        '${selectedDate.day.toString().padLeft(2, '0')}.'
            '${selectedDate.month.toString().padLeft(2, '0')}.'
            '${selectedDate.year}';
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
                    .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (value) => setState(() => status = value ?? status),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Приоритет'),
                items: ['Низкий', 'Средний', 'Высокий']
                    .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
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
