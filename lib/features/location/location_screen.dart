import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_alarm_app/constants/colors.dart';
import 'package:travel_alarm_app/features/alarm/alarm_screen.dart';
import 'package:travel_alarm_app/features/location/location_provider.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.backgroundBottom,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
               const SizedBox(height: 10),
                const SizedBox(height: 40),
                Text(
                  "Welcome! Your Smart\nTravel Alarm",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Stay on schedule and enjoy every moment of your journey.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: AppColors.textGrey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 40),

                Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(125),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primaryPurple,
                    size: 100,
                  ),
                ),
                const Spacer(),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60),
                          side: const BorderSide(color: Colors.white30),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          locationProvider.fetchCurrentLocation();
                        },
                        child: locationProvider.isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Use Current Location",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_outlined,
                                color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AlarmScreen(),
                            ),
                          );
                        },
                        child: const Text("Home",
                            style:
                            TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}