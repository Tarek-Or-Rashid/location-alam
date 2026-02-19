import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_alarm_app/constants/app_constants.dart';

class LocationProvider extends ChangeNotifier {
  String _location = 'Add your location';
  bool _isLoading = false;
  String _error = '';
  Position? _currentPosition;

  String get location => _location;
  bool get isLoading => _isLoading;
  String get error => _error;
  Position? get currentPosition => _currentPosition;

  LocationProvider() {
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocation = prefs.getString(AppConstants.locationKey);
    if (savedLocation != null && savedLocation.isNotEmpty) {
      _location = savedLocation;
      notifyListeners();
    }
  }

  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Location services are disabled. Please enable them.';
      notifyListeners();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Location permissions are denied';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error =
      'Location permissions are permanently denied. Please enable from app settings.';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> fetchCurrentLocation() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      bool hasPermission = await _checkPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String street = place.street ?? '';
        String locality = place.locality ?? '';
        String country = place.country ?? '';

        if (street.isNotEmpty || locality.isNotEmpty || country.isNotEmpty) {
          List<String> parts = [];
          if (street.isNotEmpty) parts.add(street);
          if (locality.isNotEmpty) parts.add(locality);
          if (country.isNotEmpty) parts.add(country);

          _location = parts.join(', ');
        } else {
          _location = 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
              'Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}';
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.locationKey, _location);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to get location: ${e.toString()}';
      notifyListeners();
    }
  }

  void updateManualLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}