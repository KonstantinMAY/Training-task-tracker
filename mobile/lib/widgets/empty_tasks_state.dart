
import 'package:flutter/material.dart';

class EmptyTasksState extends StatelessWidget {
  final bool hasAnyTasks;
  final VoidCallback onReset;

  const EmptyTasksState({
    super.key,
    required this.hasAnyTasks,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasAnyTasks ? Icons.search_off : Icons.task_alt,
              size: 52,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              hasAnyTasks ? 'Ничего не найдено' : 'Задач пока нет',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
              OutlinedButton(
                onPressed: onReset,
                child: const Text('Сбросить фильтры'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
