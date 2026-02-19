import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_alarm_app/constants/colors.dart';
import 'package:travel_alarm_app/features/alarm/alarm_provider.dart';
import 'package:travel_alarm_app/models/alarm_model.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({super.key});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;
  String _alarmLabel = 'Alarm';
  bool _isActive = true;

  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(now);
    _selectedDate = now;
    _labelController.text = _alarmLabel;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              surface: AppColors.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryPurple,
              surface: AppColors.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveAlarm(BuildContext context) {
    final provider = context.read<AlarmProvider>();
    final alarmDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (alarmDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a future time'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    provider.addAlarm(Alarm(
      id: provider.generateAlarmId(),
      time: alarmDateTime,
      label: _alarmLabel,
      isActive: _isActive,
      location: provider.currentLocation,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = _selectedTime.format(context).toLowerCase();
    final formattedDate = DateFormat('EEE d MMM yyyy').format(_selectedDate);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Alarm',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Time Display Card
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Text('Time',
                            style: GoogleFonts.poppins(
                                color: AppColors.textGrey, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          formattedTime,
                          style: GoogleFonts.poppins(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Date Picker Button
                _buildActionRow(
                  icon: Icons.calendar_today_rounded,
                  label: formattedDate,
                  onTap: () => _selectDate(context),
                  trailing: Text('Change',
                      style: TextStyle(color: AppColors.primaryPurple)),
                ),

                const SizedBox(height: 24),

                // Label Input
                Text('Label',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                TextField(
                  controller: _labelController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Work, Morning, Travel...',
                    hintStyle: TextStyle(
                        color: AppColors.textGrey.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.inputDark,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => _alarmLabel = v,
                ),

                const SizedBox(height: 24),

                // Active Toggle
                _buildActionRow(
                  icon: Icons.notifications_active_rounded,
                  label: 'Enabled',
                  trailing: Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.primaryPurple,
                  ),
                ),

                const SizedBox(height: 48),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => _saveAlarm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save Alarm',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(
      {required IconData icon,
        required String label,
        Widget? trailing,
        VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryPurple),
            const SizedBox(width: 16),
            Expanded(
                child: Text(label,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 16))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}