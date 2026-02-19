import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_alarm_app/constants/colors.dart';
import 'package:travel_alarm_app/features/alarm/alarm_provider.dart';
import 'package:travel_alarm_app/features/alarm/add_alarm_screen.dart';
import 'package:travel_alarm_app/features/location/location_screen.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  void _showDeleteDialog(BuildContext context, int alarmId, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Alarm',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text('"$label" alarm টি মুছে ফেলবেন?',
            style: GoogleFonts.poppins(color: AppColors.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              
              context.read<AlarmProvider>().deleteAlarm(alarmId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alarm deleted',
                      style: GoogleFonts.poppins(color: Colors.white)),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.backgroundBottom,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ── Header ──
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Selected Location",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),

                      // Location button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LocationScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.inputDark,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Selector<AlarmProvider, String>(
                            selector: (_, p) => p.currentLocation,
                            builder: (_, location, __) => Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    color: AppColors.textGrey),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(location,
                                      style: GoogleFonts.poppins(
                                          color: AppColors.textGrey)),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.textGrey),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Alarms header with count
                      Selector<AlarmProvider, int>(
                        selector: (_, p) => p.alarms.length,
                        builder: (_, count, __) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Alarms",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                            if (count > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('$count total',
                                    style: GoogleFonts.poppins(
                                        color: AppColors.primaryPurple,
                                        fontSize: 13)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Alarm List ──
                Expanded(
                  child: Consumer<AlarmProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryPurple),
                        );
                      }

                      if (provider.alarms.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.alarm_off_rounded,
                                  color: AppColors.textGrey.withOpacity(0.4),
                                  size: 70),
                              const SizedBox(height: 20),
                              Text('No alarms set',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textGrey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              Text('Tap + to add an alarm',
                                  style: GoogleFonts.poppins(
                                      color:
                                          AppColors.textGrey.withOpacity(0.6),
                                      fontSize: 14)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: provider.alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = provider.alarms[index];

                          return Dismissible(
                            key: ValueKey('alarm_${alarm.id}'),
                            direction: DismissDirection.endToStart,
                            
                            confirmDismiss: (_) async {
                              await provider.deleteAlarm(alarm.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Alarm deleted',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white)),
                                    backgroundColor: Colors.redAccent,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              }
                              return true;
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_rounded,
                                      color: Colors.white, size: 28),
                                  SizedBox(height: 4),
                                  Text('Delete',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: alarm.isActive
                                      ? AppColors.primaryPurple.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.05),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Time & label
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alarm.formattedTime.toLowerCase(),
                                        style: GoogleFonts.poppins(
                                          color: alarm.isActive
                                              ? Colors.white
                                              : AppColors.textGrey,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        Icon(Icons.label_outline_rounded,
                                            color: AppColors.textGrey,
                                            size: 14),
                                        const SizedBox(width: 4),
                                        Text(alarm.label,
                                            style: GoogleFonts.poppins(
                                                color: AppColors.textGrey,
                                                fontSize: 13)),
                                      ]),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        Icon(Icons.calendar_today_rounded,
                                            color: AppColors.textGrey,
                                            size: 12),
                                        const SizedBox(width: 4),
                                        Text(alarm.formattedDate,
                                            style: GoogleFonts.poppins(
                                                color: AppColors.textGrey,
                                                fontSize: 12)),
                                      ]),
                                    ],
                                  ),

                                  // Switch + Delete
                                  Column(
                                    children: [
                                      Switch(
                                        value: alarm.isActive,
                                        onChanged: (_) =>
                                            provider.toggleAlarm(alarm.id),
                                        activeColor: Colors.white,
                                        activeTrackColor:
                                            AppColors.primaryPurple,
                                      ),
                                      GestureDetector(
                                        onTap: () => _showDeleteDialog(
                                            context, alarm.id, alarm.label),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.redAccent,
                                              size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAlarmScreen()),
          ),
          backgroundColor: AppColors.primaryPurple,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}