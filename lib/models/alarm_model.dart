import 'package:intl/intl.dart';

class Alarm {
  int id;
  DateTime time;
  String label;
  bool isActive;
  List<int> repeatDays;
  String? location;

  Alarm({
    required this.id,
    required this.time,
    this.label = 'Alarm',
    this.isActive = true,
    this.repeatDays = const [],
    this.location,
  });

  String get formattedTime {
    return DateFormat('h:mm a').format(time);
  }

  String get formattedDate {
    return DateFormat('EEE d MMM yyyy').format(time);
  }

  String get formattedDateTime {
    return '$formattedTime    $formattedDate';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'label': label,
      'isActive': isActive,
      'repeatDays': repeatDays,
      'location': location,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      time: DateTime.parse(map['time']),
      label: map['label'],
      isActive: map['isActive'],
      repeatDays: List<int>.from(map['repeatDays']),
      location: map['location'],
    );
  }
}