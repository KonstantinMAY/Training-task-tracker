
import 'package:flutter/material.dart';
import '../models/task_data.dart';

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
        border: Border.all(
          color: overdue
              ? const Color(0xFFF2B8B5)
              : Theme.of(context).dividerColor,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 21,
                ),
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
                    : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black87),
              ),
              InfoChip(
                icon: Icons.flag_outlined,
                label: task.priority,
                color: priorityColor,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Icon(
                overdue
                    ? Icons.warning_amber_rounded
                    : Icons.calendar_today_outlined,
                size: 16,
                color: overdue ? Colors.red : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  overdue
                      ? 'Просрочено · ${task.deadline}'
                      : 'Дедлайн: ${task.deadline}',
                  style: TextStyle(
                    fontSize: 12,
                    color: overdue
                        ? Colors.red.shade700
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                    overdue ? FontWeight.w600 : FontWeight.normal,
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

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

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
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
