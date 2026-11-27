
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
  final match =
  RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(value);

  if (match == null) return null;

  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);

  return '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
