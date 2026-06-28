import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Honset Squash'**
  String get appName;

  /// No description provided for @clubName.
  ///
  /// In en, this message translates to:
  /// **'Honset Sports Club'**
  String get clubName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reserve courts, manage sessions, and keep every rally on schedule.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @createMembershipAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a membership account'**
  String get createMembershipAccount;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium court access with live availability.'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Two championship courts, coach-led sessions, QR check-in, and admin operations in one focused product.'**
  String get heroSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @clubMember.
  ///
  /// In en, this message translates to:
  /// **'Club Member'**
  String get clubMember;

  /// No description provided for @honestAcademy.
  ///
  /// In en, this message translates to:
  /// **'HONEST ACADEMY'**
  String get honestAcademy;

  /// No description provided for @fitnessSquashAcademy.
  ///
  /// In en, this message translates to:
  /// **'FITNESS & SQUASH ACADEMY'**
  String get fitnessSquashAcademy;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @coaches.
  ///
  /// In en, this message translates to:
  /// **'Coaches'**
  String get coaches;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @courtReservations.
  ///
  /// In en, this message translates to:
  /// **'Court reservations'**
  String get courtReservations;

  /// No description provided for @liveAvailability.
  ///
  /// In en, this message translates to:
  /// **'Live availability across all squash courts.'**
  String get liveAvailability;

  /// No description provided for @couldNotLoadCourts.
  ///
  /// In en, this message translates to:
  /// **'Could not load courts.'**
  String get couldNotLoadCourts;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @bookTime.
  ///
  /// In en, this message translates to:
  /// **'Book {time}'**
  String bookTime(String time);

  /// No description provided for @pricePerHour.
  ///
  /// In en, this message translates to:
  /// **'{price}LE / hour'**
  String pricePerHour(String price);

  /// No description provided for @courtNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Court not selected'**
  String get courtNotSelected;

  /// No description provided for @returnToBookingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Return to the booking dashboard and choose a court.'**
  String get returnToBookingDashboard;

  /// No description provided for @bookedTimes.
  ///
  /// In en, this message translates to:
  /// **'Booked times'**
  String get bookedTimes;

  /// No description provided for @selectBookingTime.
  ///
  /// In en, this message translates to:
  /// **'Select your booking time'**
  String get selectBookingTime;

  /// No description provided for @noSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No slots available for this date.'**
  String get noSlotsAvailable;

  /// No description provided for @noBookingsAllAvailable.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet — all times available!'**
  String get noBookingsAllAvailable;

  /// No description provided for @failedToLoadBookings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookings.'**
  String get failedToLoadBookings;

  /// No description provided for @selectTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Select a time slot'**
  String get selectTimeSlot;

  /// No description provided for @bookTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Book {start} – {end}'**
  String bookTimeRange(String start, String end);

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @pricePerHourRate.
  ///
  /// In en, this message translates to:
  /// **'\${price} / hour'**
  String pricePerHourRate(String price);

  /// No description provided for @reserveCourt.
  ///
  /// In en, this message translates to:
  /// **'Reserve court'**
  String get reserveCourt;

  /// No description provided for @bookingCreated.
  ///
  /// In en, this message translates to:
  /// **'Booking created'**
  String get bookingCreated;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed'**
  String get bookingFailed;

  /// No description provided for @confirmBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBookingTitle;

  /// No description provided for @confirmingBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirming...'**
  String get confirmingBooking;

  /// No description provided for @confirmBookingButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBookingButton;

  /// No description provided for @coach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// No description provided for @invalidCoachSelection.
  ///
  /// In en, this message translates to:
  /// **'Invalid coach selection. Please choose again.'**
  String get invalidCoachSelection;

  /// No description provided for @coachSelectionMismatch.
  ///
  /// In en, this message translates to:
  /// **'Coach selection mismatch. Please choose again.'**
  String get coachSelectionMismatch;

  /// No description provided for @noBookingSelected.
  ///
  /// In en, this message translates to:
  /// **'No booking selected'**
  String get noBookingSelected;

  /// No description provided for @returnToDashboardSlot.
  ///
  /// In en, this message translates to:
  /// **'Return to the dashboard and choose a slot.'**
  String get returnToDashboardSlot;

  /// No description provided for @reservationSummary.
  ///
  /// In en, this message translates to:
  /// **'Reservation summary'**
  String get reservationSummary;

  /// No description provided for @court.
  ///
  /// In en, this message translates to:
  /// **'Court'**
  String get court;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @instaPay.
  ///
  /// In en, this message translates to:
  /// **'InstaPay'**
  String get instaPay;

  /// No description provided for @confirmReservation.
  ///
  /// In en, this message translates to:
  /// **'Confirm reservation'**
  String get confirmReservation;

  /// No description provided for @bookingHistory.
  ///
  /// In en, this message translates to:
  /// **'Booking history'**
  String get bookingHistory;

  /// No description provided for @bookingCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled successfully'**
  String get bookingCancelledSuccessfully;

  /// No description provided for @bookingRescheduledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booking rescheduled successfully'**
  String get bookingRescheduledSuccessfully;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get operationFailed;

  /// No description provided for @noBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookingsYet;

  /// No description provided for @bookingsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your confirmed and pending reservations will appear here.'**
  String get bookingsWillAppearHere;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @editTime.
  ///
  /// In en, this message translates to:
  /// **'Edit Time'**
  String get editTime;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @cancelBookingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel your booking for {courtName} at {time}?'**
  String cancelBookingConfirmation(String courtName, String time);

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @coachLabel.
  ///
  /// In en, this message translates to:
  /// **'Coach: {name}'**
  String coachLabel(String name);

  /// No description provided for @rescheduleBooking.
  ///
  /// In en, this message translates to:
  /// **'Reschedule Booking'**
  String get rescheduleBooking;

  /// No description provided for @currentTime.
  ///
  /// In en, this message translates to:
  /// **'Current: {start} – {end}'**
  String currentTime(String start, String end);

  /// No description provided for @selectNewTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Select new time slot'**
  String get selectNewTimeSlot;

  /// No description provided for @noAvailableSlots.
  ///
  /// In en, this message translates to:
  /// **'No available slots for this date.'**
  String get noAvailableSlots;

  /// No description provided for @failedToLoadSlots.
  ///
  /// In en, this message translates to:
  /// **'Failed to load slots.'**
  String get failedToLoadSlots;

  /// No description provided for @rescheduling.
  ///
  /// In en, this message translates to:
  /// **'Rescheduling...'**
  String get rescheduling;

  /// No description provided for @selectNewTime.
  ///
  /// In en, this message translates to:
  /// **'Select a new time'**
  String get selectNewTime;

  /// No description provided for @confirmTime.
  ///
  /// In en, this message translates to:
  /// **'Confirm {start} – {end}'**
  String confirmTime(String start, String end);

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @missingPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Missing payment details'**
  String get missingPaymentDetails;

  /// No description provided for @returnAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Return and try again.'**
  String get returnAndTryAgain;

  /// No description provided for @instaPayPayment.
  ///
  /// In en, this message translates to:
  /// **'InstaPay Payment'**
  String get instaPayPayment;

  /// No description provided for @couldNotLoadPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Could not load payment info.'**
  String get couldNotLoadPaymentInfo;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @payWithInstaPay.
  ///
  /// In en, this message translates to:
  /// **'Pay with InstaPay'**
  String get payWithInstaPay;

  /// No description provided for @instaPayInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. Click \"Pay Now\" below to open InstaPay.\n2. Complete the transfer.\n3. Return to this screen and click \"I have completed payment\".'**
  String get instaPayInstructions;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @completedPayment.
  ///
  /// In en, this message translates to:
  /// **'I have completed payment'**
  String get completedPayment;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Booking pending review'**
  String get bookingPendingReview;

  /// No description provided for @waitingForAdminConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for admin confirmation'**
  String get waitingForAdminConfirmation;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get backToDashboard;

  /// No description provided for @selectSlotFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a slot first'**
  String get selectSlotFirst;

  /// No description provided for @chooseAvailableSlot.
  ///
  /// In en, this message translates to:
  /// **'Choose an available slot from the court dashboard.'**
  String get chooseAvailableSlot;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetails;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @selectDuringBooking.
  ///
  /// In en, this message translates to:
  /// **'Select during booking'**
  String get selectDuringBooking;

  /// No description provided for @courtFee.
  ///
  /// In en, this message translates to:
  /// **'Court fee'**
  String get courtFee;

  /// No description provided for @continueToCoachSelection.
  ///
  /// In en, this message translates to:
  /// **'Continue to coach selection'**
  String get continueToCoachSelection;

  /// No description provided for @guestMember.
  ///
  /// In en, this message translates to:
  /// **'Guest Member'**
  String get guestMember;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @membershipStatus.
  ///
  /// In en, this message translates to:
  /// **'Membership status'**
  String get membershipStatus;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @fcmReady.
  ///
  /// In en, this message translates to:
  /// **'Firebase Cloud Messaging ready'**
  String get fcmReady;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @guestAccess.
  ///
  /// In en, this message translates to:
  /// **'Guest access'**
  String get guestAccess;

  /// No description provided for @standardMember.
  ///
  /// In en, this message translates to:
  /// **'Standard member'**
  String get standardMember;

  /// No description provided for @premiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium member'**
  String get premiumMember;

  /// No description provided for @clubAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Club administrator'**
  String get clubAdministrator;

  /// No description provided for @coachesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Coaches unavailable'**
  String get coachesUnavailable;

  /// No description provided for @couldNotLoadCoaches.
  ///
  /// In en, this message translates to:
  /// **'We could not load the academy coaches.'**
  String get couldNotLoadCoaches;

  /// No description provided for @noCoachesFound.
  ///
  /// In en, this message translates to:
  /// **'No coaches found'**
  String get noCoachesFound;

  /// No description provided for @noActiveCoaches.
  ///
  /// In en, this message translates to:
  /// **'The academy has no active coaches right now.'**
  String get noActiveCoaches;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @yearsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} yrs'**
  String yearsShort(int count);

  /// No description provided for @coachNotFound.
  ///
  /// In en, this message translates to:
  /// **'Coach not found'**
  String get coachNotFound;

  /// No description provided for @selectCoachFromList.
  ///
  /// In en, this message translates to:
  /// **'Select a coach from the academy list.'**
  String get selectCoachFromList;

  /// No description provided for @aboutCoach.
  ///
  /// In en, this message translates to:
  /// **'About coach'**
  String get aboutCoach;

  /// No description provided for @trainingSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Training specialty'**
  String get trainingSpecialty;

  /// No description provided for @weeklyAvailability.
  ///
  /// In en, this message translates to:
  /// **'Weekly availability'**
  String get weeklyAvailability;

  /// No description provided for @coachReservations.
  ///
  /// In en, this message translates to:
  /// **'Coach reservations'**
  String get coachReservations;

  /// No description provided for @noReservationsYet.
  ///
  /// In en, this message translates to:
  /// **'No reservations yet'**
  String get noReservationsYet;

  /// No description provided for @noWeeklyAvailability.
  ///
  /// In en, this message translates to:
  /// **'No weekly availability set'**
  String get noWeeklyAvailability;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'{count} years experience'**
  String yearsExperience(int count);

  /// No description provided for @pendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending payment'**
  String get pendingPayment;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get pendingReview;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @adminBookings.
  ///
  /// In en, this message translates to:
  /// **'Admin bookings'**
  String get adminBookings;

  /// No description provided for @refreshDay.
  ///
  /// In en, this message translates to:
  /// **'Refresh day'**
  String get refreshDay;

  /// No description provided for @failedToLoadReservations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reservations'**
  String get failedToLoadReservations;

  /// No description provided for @dailyReservations.
  ///
  /// In en, this message translates to:
  /// **'Daily reservations'**
  String get dailyReservations;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDate;

  /// No description provided for @confirmedReservations.
  ///
  /// In en, this message translates to:
  /// **'Confirmed reservations'**
  String get confirmedReservations;

  /// No description provided for @pendingConfirmations.
  ///
  /// In en, this message translates to:
  /// **'Pending confirmations'**
  String get pendingConfirmations;

  /// No description provided for @awaitingAdminReview.
  ///
  /// In en, this message translates to:
  /// **'Awaiting admin review'**
  String get awaitingAdminReview;

  /// No description provided for @noConfirmedReservations.
  ///
  /// In en, this message translates to:
  /// **'No confirmed reservations'**
  String get noConfirmedReservations;

  /// No description provided for @noReservationsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No reservations on this day'**
  String get noReservationsOnDay;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment: {status}'**
  String paymentLabel(String status);

  /// No description provided for @methodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method: {method}'**
  String methodLabel(String method);

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @paymentUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Payment under review'**
  String get paymentUnderReview;

  /// No description provided for @awaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get awaitingPayment;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @somethingNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Something needs attention'**
  String get somethingNeedsAttention;

  /// No description provided for @pendingPaymentBadge.
  ///
  /// In en, this message translates to:
  /// **'PENDING PAYMENT'**
  String get pendingPaymentBadge;

  /// No description provided for @paymentReviewBadge.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT REVIEW'**
  String get paymentReviewBadge;

  /// No description provided for @confirmedBadge.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get confirmedBadge;

  /// No description provided for @rejectedBadge.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get rejectedBadge;

  /// No description provided for @cancelledBadge.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelledBadge;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}LE'**
  String totalAmount(String amount);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
