flutterfire --versionflutterfire configure --project=honest-academy# Honset Squash

Premium Flutter squash court reservation app built with feature-first Clean Architecture, Bloc/Cubit, GoRouter, dependency injection, Material 3, and Firebase-ready repositories.

## Firebase setup

The app runs with production-shaped demo data until Firebase is configured. To enable Firebase:

1. Run `flutterfire configure` for the target Firebase project.
2. Add the generated `firebase_options.dart` and native Firebase config files.
3. Deploy rules and indexes with `firebase deploy --only firestore`.

## Firestore structure

- `users/{userId}`: profile, email, phone, membership tier, admin flag.
- `admins/{adminId}`: staff metadata and operational permissions.
- `courts/{courtId}`: court profile, surface, hourly rate, active state, embedded coach snapshot.
- `courtAvailability/{availabilityId}`: per-court scheduling rules, working days, hours, breaks.
- `bookings/{bookingId}`: reservation owner, court snapshot, coach snapshot, amount, status, QR payload.

## App structure

- `lib/config`: routing and Material 3 theme system.
- `lib/core`: dependency injection, Firebase bootstrap, constants, errors, utilities.
- `lib/shared`: reusable app shell, logo, buttons, status badges, skeleton, empty and error states.
- `lib/features`: auth, courts, booking, admin, and profile modules.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
