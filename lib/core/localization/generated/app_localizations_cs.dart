// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'Classio';

  @override
  String get welcomeMessage => 'Vitejte v Classio';

  @override
  String get settings => 'Nastaveni';

  @override
  String get language => 'Jazyk';

  @override
  String get theme => 'Motiv';

  @override
  String get cleanTheme => 'Cisty';

  @override
  String get playfulTheme => 'Hravy';

  @override
  String get home => 'Domov';

  @override
  String get dashboard => 'Prehled';

  @override
  String get selectLanguage => 'Vyberte jazyk';

  @override
  String get selectTheme => 'Vyberte motiv';

  @override
  String get save => 'Ulozit';

  @override
  String get cancel => 'Zrusit';

  @override
  String get login => 'Prihlasit se';

  @override
  String get logout => 'Odhlasit se';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Heslo';

  @override
  String get welcomeBack => 'Vitejte zpet';

  @override
  String get signInToContinue => 'Prihlaste se pro pokracovani';

  @override
  String get forgotPassword => 'Zapomneli jste heslo?';

  @override
  String get loginError => 'Prihlaseni selhalo. Zkontrolujte prosim sve udaje.';

  @override
  String get emailRequired => 'E-mail je povinny';

  @override
  String get emailInvalid => 'Zadejte prosim platny e-mail';

  @override
  String get passwordRequired => 'Heslo je povinne';

  @override
  String get passwordTooShort => 'Heslo musi mit alespon 6 znaku';

  @override
  String get loggingIn => 'Prihlasuji se...';

  @override
  String get dashboardGreetingMorning => 'Dobre rano';

  @override
  String get dashboardGreetingAfternoon => 'Dobre odpoledne';

  @override
  String get dashboardGreetingEvening => 'Dobry vecer';

  @override
  String get dashboardUpNext => 'Nasleduje';

  @override
  String get dashboardTodaySchedule => 'Dnesni rozvrh';

  @override
  String get dashboardDueSoon => 'Blizi se termin';

  @override
  String get lessonCancelled => 'Zruseno';

  @override
  String get lessonSubstitution => 'Suplovani';

  @override
  String get lessonInProgress => 'Probiha';

  @override
  String lessonUpcoming(int minutes) {
    return 'Zacina za $minutes min';
  }

  @override
  String lessonRoom(String room) {
    return 'Ucebna $room';
  }

  @override
  String get assignmentDueToday => 'Odevzdat dnes';

  @override
  String get assignmentDueTomorrow => 'Odevzdat zitra';

  @override
  String assignmentDueIn(int days) {
    return 'Odevzdat za $days dni';
  }

  @override
  String get assignmentCompleted => 'Dokonceno';

  @override
  String get assignmentOverdue => 'Po terminu';

  @override
  String get noLessonsToday => 'Dnes zadne hodiny';

  @override
  String get noUpcomingAssignments => 'Zadne blizici se ukoly';

  @override
  String get allDoneForToday => 'Na dnes vse hotovo!';

  @override
  String get freeTime => 'Volno';

  @override
  String get dashboardLoading => 'Nacitam nastenku...';

  @override
  String get dashboardError => 'Neco se pokazilo';

  @override
  String get dashboardRetry => 'Zkusit znovu';

  @override
  String get navHome => 'Domu';

  @override
  String get navSchedule => 'Rozvrh';

  @override
  String get navGrades => 'Znamky';

  @override
  String get navProfile => 'Profil';

  @override
  String get scheduleTitle => 'Tydenni rozvrh';

  @override
  String get scheduleMonday => 'Po';

  @override
  String get scheduleTuesday => 'Ut';

  @override
  String get scheduleWednesday => 'St';

  @override
  String get scheduleThursday => 'Ct';

  @override
  String get scheduleFriday => 'Pa';

  @override
  String get scheduleSaturday => 'So';

  @override
  String get scheduleSunday => 'Ne';

  @override
  String get scheduleMondayFull => 'Pondeli';

  @override
  String get scheduleTuesdayFull => 'Utery';

  @override
  String get scheduleWednesdayFull => 'Streda';

  @override
  String get scheduleThursdayFull => 'Ctvrtek';

  @override
  String get scheduleFridayFull => 'Patek';

  @override
  String get scheduleNoLessons => 'Zadne hodiny';

  @override
  String get scheduleBreak => 'Prestavka';

  @override
  String get gradesTitle => 'Znamky';

  @override
  String get gradesComingSoon => 'Znamky jiz brzy';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileThemeSection => 'Vzhled';

  @override
  String get profileLanguageSection => 'Jazyk';

  @override
  String get profileLogout => 'Odhlasit se';

  @override
  String get profileLogoutConfirm => 'Opravdu se chcete odhlasit?';

  @override
  String get gradesAverage => 'Prumer';

  @override
  String get gradesWeight => 'Vaha';

  @override
  String get gradesDate => 'Datum';

  @override
  String get gradesOverallAverage => 'Celkovy prumer';

  @override
  String get gradesNoGrades => 'Zatim zadne znamky';

  @override
  String gradesWeightFormat(String weight) {
    return 'Vaha $weight';
  }

  @override
  String get subjectDetailStream => 'Prispevky';

  @override
  String get subjectDetailStreamDescription => 'Oznameni a aktuality z hodiny';

  @override
  String get subjectDetailAssignments => 'Ukoly';

  @override
  String get subjectDetailAssignmentsDescription => 'Vase ukoly a domaci prace';

  @override
  String get subjectDetailMaterials => 'Materialy';

  @override
  String get subjectDetailMaterialsDescription => 'Materialy a soubory kurzu';

  @override
  String get subjectDetailAnnouncement => 'Oznameni';

  @override
  String get subjectDetailAssignment => 'Ukol';

  @override
  String get subjectDetailSubmit => 'Odevzdat';

  @override
  String get subjectDetailSubmitted => 'Ukol odevzdan!';

  @override
  String get subjectDetailNoStream => 'Zatim zadna oznameni';

  @override
  String get subjectDetailNoAssignments => 'Zatim zadne ukoly';

  @override
  String get subjectDetailNoMaterials => 'Zatim zadne materialy';

  @override
  String subjectDetailDueDate(String date) {
    return 'Termin $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Pridal/a $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Zobrazit material';

  @override
  String get dashboardInProgress => 'Probiha';

  @override
  String get dashboardUpNextLabel => 'Dalsi';

  @override
  String get dashboardStarted => 'Zacalo';

  @override
  String get dashboardStartingNow => 'Zacina nyni';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'za ${hours}h ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'za ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Zruseno';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Suplovani: $teacher';
  }

  @override
  String get dashboardAllDone => 'Vse hotovo na dnesek!';

  @override
  String get dashboardNoMoreLessons => 'Zadne dalsi hodiny naplanovany';

  @override
  String get dashboardNoClassesToday => 'Dnes zadne hodiny';

  @override
  String get dashboardEnjoyFreeDay => 'Uzijte si volny den!';

  @override
  String get dashboardSub => 'SUP';

  @override
  String get dashboardToday => 'Dnes';

  @override
  String get dashboardTomorrow => 'Zitra';

  @override
  String get dashboardLater => 'Pozdeji';

  @override
  String get dashboardAllCaughtUp => 'Vse zvladnuto!';

  @override
  String get dashboardNoAssignmentsDue => 'Zadne ukoly brzy nesplatne';

  @override
  String get dashboardSomethingWrong => 'Neco se pokazilo';

  @override
  String get dashboardStudent => 'Student';

  @override
  String get dashboardAnError => 'Doslo k chybe';

  @override
  String get dashboardNoData => 'Zadna data k dispozici';

  @override
  String scheduleLessonCount(int count) {
    return '$count hodina';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count hodin';
  }

  @override
  String get scheduleWeekend => 'Vikend!';

  @override
  String get scheduleEnjoyTimeOff => 'Uzijte si volno!';

  @override
  String get scheduleFreeDay => 'Mate volny den. Cas odpocivat!';

  @override
  String get scheduleUnknown => 'Neznamy';

  @override
  String get gradesNoGradesYet => 'Zatim zadne znamky';

  @override
  String get gradesWillAppear =>
      'Vase znamky se zde zobrazi, jakmile budou k dispozici.';

  @override
  String get gradesFailedToLoad => 'Nepodarilo se nacist znamky';

  @override
  String get gradesRetry => 'Opakovat';

  @override
  String get gradesExcellent => 'Vyborne';

  @override
  String get gradesGood => 'Dobre';

  @override
  String get gradesFair => 'Dostatecne';

  @override
  String get gradesNeedsWork => 'Potrebuje zlepsit';

  @override
  String gradesWeightLabel(String weight) {
    return 'Vaha $weight';
  }

  @override
  String get subjectStream => 'Aktuality';

  @override
  String get subjectAssignments => 'Ukoly';

  @override
  String get subjectMaterials => 'Materialy';

  @override
  String get subjectNoPostsYet => 'Zatim zadne prispevky';

  @override
  String get subjectPostsWillAppear =>
      'Prispevky se zde zobrazi, kdyz ucitel sdili aktualizace';

  @override
  String subjectTodayAt(String time) {
    return 'Dnes v $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Vcera v $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day v $time';
  }

  @override
  String get subjectNoAssignments => 'Zadne ukoly';

  @override
  String get subjectAssignmentsWillAppear =>
      'Ukoly se zde zobrazi, kdyz je ucitel zada';

  @override
  String get subjectDueToday => 'Splatne dnes';

  @override
  String get subjectDueTomorrow => 'Splatne zitra';

  @override
  String subjectDueDate(String date) {
    return 'Splatne $date';
  }

  @override
  String get subjectSubmitted => 'Ukol odevzdan!';

  @override
  String get subjectSubmit => 'Odevzdat';

  @override
  String get subjectNoMaterials => 'Zadne materialy';

  @override
  String get subjectMaterialsWillAppear =>
      'Materialy kurzu se zde zobrazi, kdyz je ucitel sdili';

  @override
  String subjectOpening(String url) {
    return 'Oteviram: $url';
  }

  @override
  String get subjectFailedToLoad => 'Nepodarilo se nacist predmet';

  @override
  String get accessDenied => 'Pristup odepren';

  @override
  String get noSchoolAssigned => 'Neni prirazena zadna skola';

  @override
  String get schoolAdmin => 'Spravce skoly';

  @override
  String get users => 'Uzivatele';

  @override
  String get classes => 'Tridy';

  @override
  String get subjects => 'Predmety';

  @override
  String get inviteCodes => 'Pozvanky';

  @override
  String get schoolDetails => 'Udaje o skole';

  @override
  String get principalDashboard => 'Panel reditele';

  @override
  String get deputyDashboard => 'Panel zastupce';

  @override
  String get deputyPanel => 'Panel zastupce';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Heslo';

  @override
  String get inviteCodeLabel => 'Kod pozvanky';

  @override
  String get signIn => 'Prihlasit se';

  @override
  String get signUp => 'Registrovat se';

  @override
  String get register => 'Registrovat';

  @override
  String get registerWithInviteCode => 'Registrace s kodem pozvanky';

  @override
  String get dontHaveAccount => 'Nemate ucet?';

  @override
  String get alreadyHaveAccount => 'Uz mate ucet?';

  @override
  String get iDontHaveAccount => 'Nemam ucet';

  @override
  String get inviteCodeRequiredError => 'Prosim zadejte kod pozvanky';

  @override
  String get inviteCodeTooShort => 'Kod pozvanky musi mit alespon 6 znaku';

  @override
  String get firstNameLabel => 'Jmeno';

  @override
  String get lastNameLabel => 'Prijmeni';

  @override
  String get confirmPasswordLabel => 'Potvrdit heslo';

  @override
  String get pleaseConfirmPassword => 'Prosim potvrdte heslo';

  @override
  String get passwordsDoNotMatch => 'Hesla se neshoduji';

  @override
  String get firstNameRequired => 'Prosim zadejte sve jmeno';

  @override
  String get firstNameTooShort => 'Jmeno musi mit alespon 2 znaky';

  @override
  String get lastNameRequired => 'Prosim zadejte sve prijmeni';

  @override
  String get lastNameTooShort => 'Prijmeni musi mit alespon 2 znaky';

  @override
  String get enterYourEmail => 'Zadejte svuj e-mail';

  @override
  String get enterYourPassword => 'Zadejte sve heslo';

  @override
  String get enterYourInviteCode => 'Zadejte kod pozvanky';

  @override
  String get enterYourFirstName => 'Zadejte sve jmeno';

  @override
  String get enterYourLastName => 'Zadejte sve prijmeni';

  @override
  String get reEnterPassword => 'Znovu zadejte heslo';

  @override
  String get welcomeToClassio => 'Vitejte v Classio';

  @override
  String get joinClassio => 'Pripojte se ke Classio';

  @override
  String get createAccountToGetStarted => 'Vytvorte si ucet a zacnete';

  @override
  String get dismiss => 'Zavrrit';

  @override
  String get resetPassword => 'Obnovit heslo';

  @override
  String get resetPasswordInstructions =>
      'Zadejte svou e-mailovou adresu a posleme vam odkaz pro obnoveni hesla.';

  @override
  String get sendResetLink => 'Odeslat odkaz pro obnoveni';

  @override
  String get passwordResetLinkSent =>
      'Odkaz pro obnoveni hesla odeslan! Zkontrolujte svou e-mailovou schranku.';

  @override
  String get failedToSendResetLink =>
      'Nepodarilo se odeslat odkaz. Zkuste to prosim znovu.';

  @override
  String get noPermissionToAccessPage =>
      'Nemate opravneni pristupovat k teto strance.';

  @override
  String get notAssignedToSchool => 'Nejste prirazeni k zadne skole.';

  @override
  String get generateInvite => 'Vygenerovat pozvanku';

  @override
  String get createClass => 'Vytvorit tridu';

  @override
  String get overview => 'Prehled';

  @override
  String get schedule => 'Rozvrh';

  @override
  String get parents => 'Rodice';

  @override
  String get staff => 'Zamestnanci';

  @override
  String get invites => 'Pozvanky';

  @override
  String get scheduleWeekPrevious => 'Previous Week';

  @override
  String get scheduleWeekCurrent => 'This Week';

  @override
  String get scheduleWeekNext => 'Next Week';

  @override
  String get scheduleWeekAfterNext => 'Week After';

  @override
  String get scheduleWeekStable => 'Stable';

  @override
  String get scheduleLessonModified => 'Modified';

  @override
  String get scheduleLessonTime => 'Time';

  @override
  String get scheduleLessonRoom => 'Room';

  @override
  String get scheduleLessonDate => 'Date';

  @override
  String get scheduleLessonSubstitute => 'Substitute Teacher';

  @override
  String get scheduleLessonNote => 'Note';

  @override
  String get scheduleLessonChangesFromStable => 'Changes from Stable Timetable';

  @override
  String get scheduleLessonStableDescription =>
      'This is a stable lesson that repeats every week';

  @override
  String get scheduleLessonSubject => 'Subject';

  @override
  String get scheduleLessonStartTime => 'Start Time';

  @override
  String get scheduleLessonEndTime => 'End Time';

  @override
  String get scheduleLessonTeacher => 'Teacher';

  @override
  String get scheduleLessonCancelled => 'Cancelled';

  @override
  String get scheduleLessonSubstitution => 'Substitution';

  @override
  String get close => 'Close';
}
