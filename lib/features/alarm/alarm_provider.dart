import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_alarm_app/constants/app_constants.dart';
import 'package:travel_alarm_app/models/alarm_model.dart';
import 'package:travel_alarm_app/helpers/notification_helper.dart';

class AlarmProvider extends ChangeNotifier {
  List<Alarm> _alarms = [];
  String _currentLocation = 'Add your location';
  bool _isLoading = false;

  List<Alarm> get alarms => List.unmodifiable(_alarms);
  String get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;

  AlarmProvider() {
    _init();
  }

  // ─── Init

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    await _loadLocation();
    await _loadAlarms();

    _isLoading = false;
    notifyListeners();
  }

  // ─── Load

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsString = prefs.getString(AppConstants.alarmsKey);

    if (alarmsString != null && alarmsString.isNotEmpty) {
      try {
        final List<dynamic> alarmsJson = json.decode(alarmsString);
        _alarms = alarmsJson.map((j) => Alarm.fromMap(j)).toList();
        _alarms.sort((a, b) => a.time.compareTo(b.time));

        //  future alarm
        for (final alarm in _alarms.where(
          (a) => a.isActive && a.time.isAfter(DateTime.now()),
        )) {
          await _scheduleNotification(alarm);
        }
      } catch (e) {
        debugPrint('Error loading alarms: $e');
        _alarms = [];
      }
    }

    notifyListeners();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final location = prefs.getString(AppConstants.locationKey);
    if (location != null && location.isNotEmpty) {
      _currentLocation = location;
    }
  }

  // ─── Save

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = _alarms.map((a) => a.toMap()).toList();
    await prefs.setString(AppConstants.alarmsKey, json.encode(alarmsJson));
  }

  // ─── Notification

  Future<void> _scheduleNotification(Alarm alarm) async {
    if (alarm.time.isBefore(DateTime.now())) return;

    await NotificationHelper.scheduleAlarmNotification(
      id: alarm.id,
      title: 'Travel Alarm 🔔',
      body: alarm.label,
      scheduledTime: alarm.time,
    );
  }

  // ─── CRUD

  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    _alarms.sort((a, b) => a.time.compareTo(b.time));

    notifyListeners();

    await _saveAlarms();
    if (alarm.isActive && alarm.time.isAfter(DateTime.now())) {
      await _scheduleNotification(alarm);
    }
  }

  Future<void> deleteAlarm(int id) async {
    _alarms.removeWhere((alarm) => alarm.id == id);

    notifyListeners();

    await NotificationHelper.cancelNotification(id);
    await _saveAlarms();
  }

  Future<void> toggleAlarm(int id) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final old = _alarms[index];
    _alarms[index] = Alarm(
      id: old.id,
      time: old.time,
      label: old.label,
      isActive: !old.isActive,
      repeatDays: old.repeatDays,
      location: old.location,
    );

    notifyListeners();

    await _saveAlarms();
    if (_alarms[index].isActive) {
      await _scheduleNotification(_alarms[index]);
    } else {
      await NotificationHelper.cancelNotification(id);
    }
  }

  Future<void> updateAlarm(Alarm updated) async {
    final index = _alarms.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;

    await NotificationHelper.cancelNotification(_alarms[index].id);
    _alarms[index] = updated;
    _alarms.sort((a, b) => a.time.compareTo(b.time));

    notifyListeners();

    await _saveAlarms();
    if (updated.isActive && updated.time.isAfter(DateTime.now())) {
      await _scheduleNotification(updated);
    }
  }

  // ─── Location

  Future<void> updateLocation(String location) async {
    _currentLocation = location;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.locationKey, location);
  }

  void updateLocationFromProvider(String location) {
    _currentLocation = location;
    notifyListeners();
  }

  // ─── Helper

  ///  ID overflow ঠেকাতে modulo — notification ID max 100000
  int generateAlarmId() {
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }
}
