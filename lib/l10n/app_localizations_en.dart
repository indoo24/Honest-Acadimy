// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Honset Squash';

  @override
  String get clubName => 'Honset Sports Club';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Reserve courts, manage sessions, and keep every rally on schedule.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get createMembershipAccount => 'Create a membership account';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get heroTitle => 'Premium court access with live availability.';

  @override
  String get heroSubtitle =>
      'Two championship courts, coach-led sessions, QR check-in, and admin operations in one focused product.';

  @override
  String get createAccount => 'Create account';

  @override
  String get fullName => 'Full name';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get clubMember => 'Club Member';

  @override
  String get honestAcademy => 'HONEST ACADEMY';

  @override
  String get fitnessSquashAcademy => 'FITNESS & SQUASH ACADEMY';

  @override
  String get home => 'Home';

  @override
  String get coaches => 'Coaches';

  @override
  String get bookings => 'Bookings';

  @override
  String get admin => 'Admin';

  @override
  String get profile => 'Profile';

  @override
  String get refresh => 'Refresh';

  @override
  String get courtReservations => 'Court reservations';

  @override
  String get liveAvailability => 'Live availability across all squash courts.';

  @override
  String get couldNotLoadCourts => 'Could not load courts.';

  @override
  String get viewDetails => 'View details';

  @override
  String bookTime(String time) {
    return 'Book $time';
  }

  @override
  String pricePerHour(String price) {
    return '${price}LE / hour';
  }

  @override
  String get courtNotSelected => 'Court not selected';

  @override
  String get returnToBookingDashboard =>
      'Return to the booking dashboard and choose a court.';

  @override
  String get bookedTimes => 'Booked times';

  @override
  String get selectBookingTime => 'Select your booking time';

  @override
  String get noSlotsAvailable => 'No slots available for this date.';

  @override
  String get noBookingsAllAvailable => 'No bookings yet — all times available!';

  @override
  String get failedToLoadBookings => 'Failed to load bookings.';

  @override
  String get selectTimeSlot => 'Select a time slot';

  @override
  String bookTimeRange(String start, String end) {
    return 'Book $start – $end';
  }

  @override
  String get unavailable => 'Unavailable';

  @override
  String get duration => 'Duration';

  @override
  String get rate => 'Rate';

  @override
  String get total => 'Total';

  @override
  String pricePerHourRate(String price) {
    return '\$$price / hour';
  }

  @override
  String get reserveCourt => 'Reserve court';

  @override
  String get bookingCreated => 'Booking created';

  @override
  String get bookingFailed => 'Booking failed';

  @override
  String get confirmBookingTitle => 'Confirm booking';

  @override
  String get confirmingBooking => 'Confirming...';

  @override
  String get confirmBookingButton => 'Confirm booking';

  @override
  String get coach => 'Coach';

  @override
  String get invalidCoachSelection =>
      'Invalid coach selection. Please choose again.';

  @override
  String get coachSelectionMismatch =>
      'Coach selection mismatch. Please choose again.';

  @override
  String get noCoach => 'No Coach';

  @override
  String get noBookingSelected => 'No booking selected';

  @override
  String get returnToDashboardSlot =>
      'Return to the dashboard and choose a slot.';

  @override
  String get reservationSummary => 'Reservation summary';

  @override
  String get court => 'Court';

  @override
  String get date => 'Date';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get instaPay => 'InstaPay';

  @override
  String get confirmReservation => 'Confirm reservation';

  @override
  String get bookingHistory => 'Booking history';

  @override
  String get bookingCancelledSuccessfully => 'Booking cancelled successfully';

  @override
  String get bookingRescheduledSuccessfully =>
      'Booking rescheduled successfully';

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get noBookingsYet => 'No bookings yet';

  @override
  String get bookingsWillAppearHere =>
      'Your confirmed and pending reservations will appear here.';

  @override
  String get cancel => 'Cancel';

  @override
  String get editTime => 'Edit Time';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String cancelBookingConfirmation(String courtName, String time) {
    return 'Are you sure you want to cancel your booking for $courtName at $time?';
  }

  @override
  String get keep => 'Keep';

  @override
  String coachLabel(String name) {
    return 'Coach: $name';
  }

  @override
  String get rescheduleBooking => 'Reschedule Booking';

  @override
  String currentTime(String start, String end) {
    return 'Current: $start – $end';
  }

  @override
  String get selectNewTimeSlot => 'Select new time slot';

  @override
  String get noAvailableSlots => 'No available slots for this date.';

  @override
  String get failedToLoadSlots => 'Failed to load slots.';

  @override
  String get rescheduling => 'Rescheduling...';

  @override
  String get selectNewTime => 'Select a new time';

  @override
  String confirmTime(String start, String end) {
    return 'Confirm $start – $end';
  }

  @override
  String get current => 'Current';

  @override
  String get missingPaymentDetails => 'Missing payment details';

  @override
  String get returnAndTryAgain => 'Return and try again.';

  @override
  String get instaPayPayment => 'InstaPay Payment';

  @override
  String get couldNotLoadPaymentInfo => 'Could not load payment info.';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get retry => 'Retry';

  @override
  String get payWithInstaPay => 'Pay with InstaPay';

  @override
  String get instaPayInstructions =>
      '1. Click \"Pay Now\" below to open InstaPay.\n2. Complete the transfer.\n3. Return to this screen and click \"I have completed payment\".';

  @override
  String get payNow => 'Pay Now';

  @override
  String get completedPayment => 'I have completed payment';

  @override
  String get bookingConfirmed => 'Booking confirmed';

  @override
  String get bookingPendingReview => 'Booking pending review';

  @override
  String get waitingForAdminConfirmation => 'Waiting for admin confirmation';

  @override
  String get backToDashboard => 'Back to dashboard';

  @override
  String get selectSlotFirst => 'Select a slot first';

  @override
  String get chooseAvailableSlot =>
      'Choose an available slot from the court dashboard.';

  @override
  String get bookingDetails => 'Booking details';

  @override
  String get time => 'Time';

  @override
  String get selectDuringBooking => 'Select during booking';

  @override
  String get courtFee => 'Court fee';

  @override
  String get continueToCoachSelection => 'Continue to coach selection';

  @override
  String get guestMember => 'Guest Member';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get membershipStatus => 'Membership status';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get fcmReady => 'Firebase Cloud Messaging ready';

  @override
  String get signOut => 'Sign out';

  @override
  String get guestAccess => 'Guest access';

  @override
  String get standardMember => 'Standard member';

  @override
  String get premiumMember => 'Premium member';

  @override
  String get clubAdministrator => 'Club administrator';

  @override
  String get coachesUnavailable => 'Coaches unavailable';

  @override
  String get couldNotLoadCoaches => 'We could not load the academy coaches.';

  @override
  String get noCoachesFound => 'No coaches found';

  @override
  String get noActiveCoaches => 'The academy has no active coaches right now.';

  @override
  String get viewProfile => 'View profile';

  @override
  String get available => 'Available';

  @override
  String yearsShort(int count) {
    return '$count yrs';
  }

  @override
  String get coachNotFound => 'Coach not found';

  @override
  String get selectCoachFromList => 'Select a coach from the academy list.';

  @override
  String get aboutCoach => 'About coach';

  @override
  String get trainingSpecialty => 'Training specialty';

  @override
  String get weeklyAvailability => 'Weekly availability';

  @override
  String get coachReservations => 'Coach reservations';

  @override
  String get noReservationsYet => 'No reservations yet';

  @override
  String get noWeeklyAvailability => 'No weekly availability set';

  @override
  String yearsExperience(int count) {
    return '$count years experience';
  }

  @override
  String get pendingPayment => 'Pending payment';

  @override
  String get pendingReview => 'Pending review';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get rejected => 'Rejected';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get adminBookings => 'Admin bookings';

  @override
  String get refreshDay => 'Refresh day';

  @override
  String get failedToLoadReservations => 'Failed to load reservations';

  @override
  String get dailyReservations => 'Daily reservations';

  @override
  String get pickDate => 'Pick date';

  @override
  String get confirmedReservations => 'Confirmed reservations';

  @override
  String get pendingConfirmations => 'Pending confirmations';

  @override
  String get awaitingAdminReview => 'Awaiting admin review';

  @override
  String get noConfirmedReservations => 'No confirmed reservations';

  @override
  String get noReservationsOnDay => 'No reservations on this day';

  @override
  String get confirm => 'Confirm';

  @override
  String get reject => 'Reject';

  @override
  String paymentLabel(String status) {
    return 'Payment: $status';
  }

  @override
  String methodLabel(String method) {
    return 'Method: $method';
  }

  @override
  String get paid => 'Paid';

  @override
  String get paymentUnderReview => 'Payment under review';

  @override
  String get awaitingPayment => 'Awaiting payment';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotificationsYet => 'No notifications yet.';

  @override
  String get somethingNeedsAttention => 'Something needs attention';

  @override
  String get pendingPaymentBadge => 'PENDING PAYMENT';

  @override
  String get paymentReviewBadge => 'PAYMENT REVIEW';

  @override
  String get confirmedBadge => 'CONFIRMED';

  @override
  String get rejectedBadge => 'REJECTED';

  @override
  String get cancelledBadge => 'CANCELLED';

  @override
  String totalAmount(String amount) {
    return 'Total: ${amount}LE';
  }

  @override
  String get pending => 'Pending';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get clientName => 'Client Name';

  @override
  String get clientNameRequired => 'Please enter your name';
}
