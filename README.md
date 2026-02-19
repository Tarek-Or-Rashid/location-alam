# ✈️ Travel Alarm App

A Flutter mobile app that lets travelers set location-based alarms with local notifications.

---

## 📸 Screenshots, Demo Video & APK

🔗 [Click here to view](https://drive.google.com/drive/folders/1hZnLk8Dkm1YRXqOKCU89__bUeqGbTawd)

---

## 📱 Features

- **Onboarding Screens** — 3-page intro with skip option
- **Location Access** — fetches current GPS location using Geolocator
- **Set Alarms** — pick date & time, add a label
- **Local Notifications** — scheduled notifications using `flutter_local_notifications`
- **Alarm Management** — toggle on/off, swipe to delete, delete dialog
- **Persistent Storage** — alarms & location saved with SharedPreferences

---

## 🛠️ Packages Used

| Package | Purpose |
|---|---|
| `provider` | State management |
| `shared_preferences` | Local storage for alarms & location |
| `flutter_local_notifications` | Scheduled alarm notifications |
| `timezone` | Timezone-aware notification scheduling |
| `geolocator` | GPS location access |
| `geocoding` | Convert coordinates to address |
| `permission_handler` | Runtime permissions |
| `google_fonts` | Poppins font |
| `intl` | Date & time formatting |

---

## 🚀 Setup Instructions

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/travel_alarm_app.git
cd travel_alarm_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

> Minimum Android SDK: **API 29 (Android 10)**

---

## 📂 Project Structure

```
lib/
├── common_widgets/
│   └── onboarding_page.dart
├── constants/
│   ├── app_constants.dart
│   └── colors.dart
├── features/
│   ├── alarm/
│   │   ├── alarm_provider.dart
│   │   ├── alarm_screen.dart
│   │   └── add_alarm_screen.dart
│   ├── location/
│   │   ├── location_provider.dart
│   │   └── location_screen.dart
│   └── onboarding/
│       └── onboarding_screen.dart
├── helpers/
│   ├── notification_helper.dart
│   └── permission_helper.dart
├── models/
│   └── alarm_model.dart
└── main.dart
```

---

## 📋 Notes

- Notifications use `exactAllowWhileIdle` mode — works even in Doze mode (Android 10+)
- Boot receiver included — alarms restore after phone restart
- Alarm IDs use modulo `% 100000` to prevent integer overflow
