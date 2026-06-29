// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'هونست سكواش';

  @override
  String get clubName => 'نادي هونست الرياضي';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get loginSubtitle =>
      'احجز الملاعب، وأدِر الجلسات، وحافظ على كل مباراة في موعدها.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get continueAsGuest => 'المتابعة كزائر';

  @override
  String get createMembershipAccount => 'إنشاء حساب عضوية';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get heroTitle => 'وصول مميز للملاعب مع التوفر المباشر.';

  @override
  String get heroSubtitle =>
      'ملعبان بطولة، جلسات مع مدربين، تسجيل دخول بـ QR، وعمليات إدارية في منتج واحد متكامل.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get createAccountButton => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get registrationFailed => 'فشل التسجيل';

  @override
  String get clubMember => 'عضو النادي';

  @override
  String get honestAcademy => 'أكاديمية هونست';

  @override
  String get fitnessSquashAcademy => 'أكاديمية اللياقة والسكواش';

  @override
  String get home => 'الرئيسية';

  @override
  String get coaches => 'المدربون';

  @override
  String get bookings => 'الحجوزات';

  @override
  String get admin => 'الإدارة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get refresh => 'تحديث';

  @override
  String get courtReservations => 'حجوزات الملاعب';

  @override
  String get liveAvailability => 'التوفر المباشر لجميع ملاعب السكواش.';

  @override
  String get couldNotLoadCourts => 'تعذّر تحميل الملاعب.';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String bookTime(String time) {
    return 'احجز $time';
  }

  @override
  String pricePerHour(String price) {
    return '$price ج.م / ساعة';
  }

  @override
  String get courtNotSelected => 'لم يتم اختيار ملعب';

  @override
  String get returnToBookingDashboard => 'ارجع إلى لوحة الحجز واختر ملعباً.';

  @override
  String get bookedTimes => 'الأوقات المحجوزة';

  @override
  String get selectBookingTime => 'اختر وقت الحجز';

  @override
  String get noSlotsAvailable => 'لا توجد فترات متاحة لهذا اليوم.';

  @override
  String get noBookingsAllAvailable =>
      'لا توجد حجوزات بعد — جميع الأوقات متاحة!';

  @override
  String get failedToLoadBookings => 'فشل تحميل الحجوزات.';

  @override
  String get selectTimeSlot => 'اختر فترة زمنية';

  @override
  String bookTimeRange(String start, String end) {
    return 'احجز $start – $end';
  }

  @override
  String get unavailable => 'غير متاح';

  @override
  String get duration => 'المدة';

  @override
  String get rate => 'السعر';

  @override
  String get total => 'الإجمالي';

  @override
  String pricePerHourRate(String price) {
    return '$price\$ / ساعة';
  }

  @override
  String get reserveCourt => 'احجز الملعب';

  @override
  String get bookingCreated => 'تم إنشاء الحجز';

  @override
  String get bookingFailed => 'فشل الحجز';

  @override
  String get confirmBookingTitle => 'تأكيد الحجز';

  @override
  String get confirmingBooking => 'جارٍ التأكيد...';

  @override
  String get confirmBookingButton => 'تأكيد الحجز';

  @override
  String get coach => 'المدرب';

  @override
  String get invalidCoachSelection =>
      'اختيار مدرب غير صالح. يرجى الاختيار مرة أخرى.';

  @override
  String get coachSelectionMismatch =>
      'عدم تطابق في اختيار المدرب. يرجى الاختيار مرة أخرى.';

  @override
  String get noCoach => 'بدون كابتن';

  @override
  String get noBookingSelected => 'لم يتم اختيار حجز';

  @override
  String get returnToDashboardSlot => 'ارجع إلى لوحة التحكم واختر فترة.';

  @override
  String get reservationSummary => 'ملخص الحجز';

  @override
  String get court => 'الملعب';

  @override
  String get date => 'التاريخ';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cash => 'نقدي';

  @override
  String get instaPay => 'إنستا باي';

  @override
  String get confirmReservation => 'تأكيد الحجز';

  @override
  String get bookingHistory => 'سجل الحجوزات';

  @override
  String get bookingCancelledSuccessfully => 'تم إلغاء الحجز بنجاح';

  @override
  String get bookingRescheduledSuccessfully => 'تمت إعادة جدولة الحجز بنجاح';

  @override
  String get operationFailed => 'فشلت العملية';

  @override
  String get noBookingsYet => 'لا توجد حجوزات بعد';

  @override
  String get bookingsWillAppearHere => 'ستظهر حجوزاتك المؤكدة والمعلقة هنا.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get editTime => 'تعديل الوقت';

  @override
  String get cancelBooking => 'إلغاء الحجز';

  @override
  String cancelBookingConfirmation(String courtName, String time) {
    return 'هل أنت متأكد من إلغاء حجزك لـ $courtName في الساعة $time؟';
  }

  @override
  String get keep => 'الاحتفاظ';

  @override
  String coachLabel(String name) {
    return 'المدرب: $name';
  }

  @override
  String get rescheduleBooking => 'إعادة جدولة الحجز';

  @override
  String currentTime(String start, String end) {
    return 'الحالي: $start – $end';
  }

  @override
  String get selectNewTimeSlot => 'اختر فترة زمنية جديدة';

  @override
  String get noAvailableSlots => 'لا توجد فترات متاحة لهذا اليوم.';

  @override
  String get failedToLoadSlots => 'فشل تحميل الفترات.';

  @override
  String get rescheduling => 'جارٍ إعادة الجدولة...';

  @override
  String get selectNewTime => 'اختر وقتاً جديداً';

  @override
  String confirmTime(String start, String end) {
    return 'تأكيد $start – $end';
  }

  @override
  String get current => 'الحالي';

  @override
  String get missingPaymentDetails => 'تفاصيل الدفع مفقودة';

  @override
  String get returnAndTryAgain => 'ارجع وحاول مرة أخرى.';

  @override
  String get instaPayPayment => 'الدفع عبر إنستا باي';

  @override
  String get couldNotLoadPaymentInfo => 'تعذّر تحميل معلومات الدفع.';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get payWithInstaPay => 'ادفع عبر إنستا باي';

  @override
  String get instaPayInstructions =>
      '١. اضغط على \"ادفع الآن\" أدناه لفتح إنستا باي.\n٢. أكمل التحويل.\n٣. ارجع إلى هذه الشاشة واضغط \"لقد أكملت الدفع\".';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get completedPayment => 'لقد أكملت الدفع';

  @override
  String get bookingConfirmed => 'تم تأكيد الحجز';

  @override
  String get bookingPendingReview => 'الحجز قيد المراجعة';

  @override
  String get waitingForAdminConfirmation => 'في انتظار تأكيد الإدارة';

  @override
  String get backToDashboard => 'العودة إلى الرئيسية';

  @override
  String get selectSlotFirst => 'اختر فترة أولاً';

  @override
  String get chooseAvailableSlot => 'اختر فترة متاحة من لوحة الملاعب.';

  @override
  String get bookingDetails => 'تفاصيل الحجز';

  @override
  String get time => 'الوقت';

  @override
  String get selectDuringBooking => 'اختر أثناء الحجز';

  @override
  String get courtFee => 'رسوم الملعب';

  @override
  String get continueToCoachSelection => 'المتابعة لاختيار المدرب';

  @override
  String get guestMember => 'عضو زائر';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get membershipStatus => 'حالة العضوية';

  @override
  String get pushNotifications => 'الإشعارات الفورية';

  @override
  String get fcmReady => 'خدمة الإشعارات جاهزة';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get guestAccess => 'وصول زائر';

  @override
  String get standardMember => 'عضو عادي';

  @override
  String get premiumMember => 'عضو مميز';

  @override
  String get clubAdministrator => 'مدير النادي';

  @override
  String get coachesUnavailable => 'المدربون غير متاحين';

  @override
  String get couldNotLoadCoaches => 'تعذّر تحميل مدربي الأكاديمية.';

  @override
  String get noCoachesFound => 'لا يوجد مدربون';

  @override
  String get noActiveCoaches => 'لا يوجد مدربون نشطون حالياً في الأكاديمية.';

  @override
  String get viewProfile => 'عرض الملف';

  @override
  String get available => 'متاح';

  @override
  String yearsShort(int count) {
    return '$count سنوات';
  }

  @override
  String get coachNotFound => 'المدرب غير موجود';

  @override
  String get selectCoachFromList => 'اختر مدرباً من قائمة الأكاديمية.';

  @override
  String get aboutCoach => 'عن المدرب';

  @override
  String get trainingSpecialty => 'تخصص التدريب';

  @override
  String get weeklyAvailability => 'التوفر الأسبوعي';

  @override
  String get coachReservations => 'حجوزات المدرب';

  @override
  String get noReservationsYet => 'لا توجد حجوزات بعد';

  @override
  String get noWeeklyAvailability => 'لم يتم تحديد التوفر الأسبوعي';

  @override
  String yearsExperience(int count) {
    return '$count سنوات خبرة';
  }

  @override
  String get pendingPayment => 'في انتظار الدفع';

  @override
  String get pendingReview => 'قيد المراجعة';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get rejected => 'مرفوض';

  @override
  String get cancelled => 'ملغي';

  @override
  String get adminBookings => 'حجوزات الإدارة';

  @override
  String get refreshDay => 'تحديث اليوم';

  @override
  String get failedToLoadReservations => 'فشل تحميل الحجوزات';

  @override
  String get dailyReservations => 'الحجوزات اليومية';

  @override
  String get pickDate => 'اختر تاريخ';

  @override
  String get confirmedReservations => 'الحجوزات المؤكدة';

  @override
  String get pendingConfirmations => 'في انتظار التأكيد';

  @override
  String get awaitingAdminReview => 'في انتظار مراجعة الإدارة';

  @override
  String get noConfirmedReservations => 'لا توجد حجوزات مؤكدة';

  @override
  String get noReservationsOnDay => 'لا توجد حجوزات في هذا اليوم';

  @override
  String get confirm => 'تأكيد';

  @override
  String get reject => 'رفض';

  @override
  String paymentLabel(String status) {
    return 'الدفع: $status';
  }

  @override
  String methodLabel(String method) {
    return 'الطريقة: $method';
  }

  @override
  String get paid => 'مدفوع';

  @override
  String get paymentUnderReview => 'الدفع قيد المراجعة';

  @override
  String get awaitingPayment => 'في انتظار الدفع';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات بعد.';

  @override
  String get somethingNeedsAttention => 'يحتاج شيء ما إلى انتباهك';

  @override
  String get pendingPaymentBadge => 'في انتظار الدفع';

  @override
  String get paymentReviewBadge => 'مراجعة الدفع';

  @override
  String get confirmedBadge => 'مؤكد';

  @override
  String get rejectedBadge => 'مرفوض';

  @override
  String get cancelledBadge => 'ملغي';

  @override
  String totalAmount(String amount) {
    return 'الإجمالي: $amount ج.م';
  }

  @override
  String get pending => 'معلق';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get clientName => 'إسم العميل';

  @override
  String get clientNameRequired => 'من فضلك أدخل إسمك';
}
