
import '../utils/task_helpers.dart';

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
