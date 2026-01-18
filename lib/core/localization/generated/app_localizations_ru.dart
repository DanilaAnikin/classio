// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Classio';

  @override
  String get welcomeMessage => 'Dobro pozhalovat v Classio';

  @override
  String get settings => 'Nastroyki';

  @override
  String get language => 'Yazik';

  @override
  String get theme => 'Tema';

  @override
  String get cleanTheme => 'Chistaya';

  @override
  String get playfulTheme => 'Igrivaya';

  @override
  String get home => 'Glavnaya';

  @override
  String get dashboard => 'Panel upravleniya';

  @override
  String get selectLanguage => 'Vibrat yazik';

  @override
  String get selectTheme => 'Vibrat temu';

  @override
  String get save => 'Sokhranit';

  @override
  String get cancel => 'Otmena';

  @override
  String get login => 'Vkhod';

  @override
  String get logout => 'Vikhod';

  @override
  String get email => 'Elektronnaya pochta';

  @override
  String get password => 'Parol';

  @override
  String get welcomeBack => 'S vozvrashcheniem';

  @override
  String get signInToContinue => 'Voydite, chtobi prodolzhit';

  @override
  String get forgotPassword => 'Zabili parol?';

  @override
  String get loginError => 'Oshibka vkhoda. Proverite svoi dannie.';

  @override
  String get emailRequired => 'Elektronnaya pochta obyazatelna';

  @override
  String get emailInvalid => 'Vvedite pravilniy adres elektronnoy pochti';

  @override
  String get passwordRequired => 'Parol obyazatelen';

  @override
  String get passwordTooShort => 'Parol dolzhen soderzhat ne menee 6 simvolov';

  @override
  String get loggingIn => 'Vkhod v sistemu...';

  @override
  String get dashboardGreetingMorning => 'Dobroe utro';

  @override
  String get dashboardGreetingAfternoon => 'Dobriy den';

  @override
  String get dashboardGreetingEvening => 'Dobriy vecher';

  @override
  String get dashboardUpNext => 'Dalee';

  @override
  String get dashboardTodaySchedule => 'Raspisanie na segodnya';

  @override
  String get dashboardDueSoon => 'Skoro srok sdachi';

  @override
  String get lessonCancelled => 'Otmeneno';

  @override
  String get lessonSubstitution => 'Zamena';

  @override
  String get lessonInProgress => 'Idet seychas';

  @override
  String lessonUpcoming(int minutes) {
    return 'Nachalo cherez $minutes min';
  }

  @override
  String lessonRoom(String room) {
    return 'Kabinet $room';
  }

  @override
  String get assignmentDueToday => 'Sdat segodnya';

  @override
  String get assignmentDueTomorrow => 'Sdat zavtra';

  @override
  String assignmentDueIn(int days) {
    return 'Sdat cherez $days dney';
  }

  @override
  String get assignmentCompleted => 'Vipolneno';

  @override
  String get assignmentOverdue => 'Prosrocheno';

  @override
  String get noLessonsToday => 'Segodnya net urokov';

  @override
  String get noUpcomingAssignments => 'Net predstoyashchikh zadaniy';

  @override
  String get allDoneForToday => 'Na segodnya vse!';

  @override
  String get freeTime => 'Svobodnoe vremya';

  @override
  String get dashboardLoading => 'Zagruzka paneli...';

  @override
  String get dashboardError => 'Chto-to poshlo ne tak';

  @override
  String get dashboardRetry => 'Povtorit';

  @override
  String get navHome => 'Glavnaya';

  @override
  String get navSchedule => 'Raspisanie';

  @override
  String get navGrades => 'Otsenki';

  @override
  String get navProfile => 'Profil';

  @override
  String get scheduleTitle => 'Nedelnoe raspisanie';

  @override
  String get scheduleMonday => 'Pn';

  @override
  String get scheduleTuesday => 'Vt';

  @override
  String get scheduleWednesday => 'Sr';

  @override
  String get scheduleThursday => 'Cht';

  @override
  String get scheduleFriday => 'Pt';

  @override
  String get scheduleSaturday => 'Sb';

  @override
  String get scheduleSunday => 'Vs';

  @override
  String get scheduleMondayFull => 'Ponedelnik';

  @override
  String get scheduleTuesdayFull => 'Vtornik';

  @override
  String get scheduleWednesdayFull => 'Sreda';

  @override
  String get scheduleThursdayFull => 'Chetverg';

  @override
  String get scheduleFridayFull => 'Pyatnitsa';

  @override
  String get scheduleNoLessons => 'Net urokov';

  @override
  String get scheduleBreak => 'Peremena';

  @override
  String get gradesTitle => 'Otsenki';

  @override
  String get gradesComingSoon => 'Otsenki skoro poyavyatsya';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileThemeSection => 'Vneshniy vid';

  @override
  String get profileLanguageSection => 'Yazik';

  @override
  String get profileLogout => 'Viyti';

  @override
  String get profileLogoutConfirm => 'Vi uvereni, chto khotite viyti?';

  @override
  String get gradesAverage => 'Sredniy ball';

  @override
  String get gradesWeight => 'Ves';

  @override
  String get gradesDate => 'Data';

  @override
  String get gradesOverallAverage => 'Obshchiy sredniy ball';

  @override
  String get gradesNoGrades => 'Poka net otsenok';

  @override
  String gradesWeightFormat(String weight) {
    return 'Ves $weight';
  }

  @override
  String get subjectDetailStream => 'Lenta';

  @override
  String get subjectDetailStreamDescription => 'Obyavleniya i novosti klassa';

  @override
  String get subjectDetailAssignments => 'Zadaniya';

  @override
  String get subjectDetailAssignmentsDescription =>
      'Vashi zadaniya i domashnyaya rabota';

  @override
  String get subjectDetailMaterials => 'Materiali';

  @override
  String get subjectDetailMaterialsDescription => 'Resursi i fayli kursa';

  @override
  String get subjectDetailAnnouncement => 'Obyavlenie';

  @override
  String get subjectDetailAssignment => 'Zadanie';

  @override
  String get subjectDetailSubmit => 'Otpravit';

  @override
  String get subjectDetailSubmitted => 'Zadanie sdano!';

  @override
  String get subjectDetailNoStream => 'Poka net obyavleniy';

  @override
  String get subjectDetailNoAssignments => 'Poka net zadaniy';

  @override
  String get subjectDetailNoMaterials => 'Poka net materialov';

  @override
  String subjectDetailDueDate(String date) {
    return 'Srok $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Opublikoval(a) $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Prosmotret material';

  @override
  String get dashboardInProgress => 'V protsesse';

  @override
  String get dashboardUpNextLabel => 'Dalee';

  @override
  String get dashboardStarted => 'Nachalos';

  @override
  String get dashboardStartingNow => 'Nachinaetsya seychas';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'cherez ${hours}ch ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'cherez ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Otmeneno';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Zamena: $teacher';
  }

  @override
  String get dashboardAllDone => 'Vse sdelano na segodnya!';

  @override
  String get dashboardNoMoreLessons => 'Bolshe net zaplanirovannikh urokov';

  @override
  String get dashboardNoClassesToday => 'Segodnya net zanyatiy';

  @override
  String get dashboardEnjoyFreeDay => 'Naslazhsaytes svobodnim dnem!';

  @override
  String get dashboardSub => 'ZAM';

  @override
  String get dashboardToday => 'Segodnya';

  @override
  String get dashboardTomorrow => 'Zavtra';

  @override
  String get dashboardLater => 'Pozzhe';

  @override
  String get dashboardAllCaughtUp => 'Vse vipolneno!';

  @override
  String get dashboardNoAssignmentsDue => 'Net zadaniy s blizkim srokom';

  @override
  String get dashboardSomethingWrong => 'Chto-to poshlo ne tak';

  @override
  String get dashboardStudent => 'Student';

  @override
  String get dashboardAnError => 'Proizoshla oshibka';

  @override
  String get dashboardNoData => 'Dannie nedostupni';

  @override
  String scheduleLessonCount(int count) {
    return '$count urok';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count urokov';
  }

  @override
  String get scheduleWeekend => 'Vikhodnie!';

  @override
  String get scheduleEnjoyTimeOff => 'Naslazhsaytes otdikhom!';

  @override
  String get scheduleFreeDay => 'U vas svobodniy den. Vremya otdokhnut!';

  @override
  String get scheduleUnknown => 'Neizvestno';

  @override
  String get gradesNoGradesYet => 'Otsenok poka net';

  @override
  String get gradesWillAppear =>
      'Vashi otsenki poyavyatsya zdes, kogda oni budut dostupni.';

  @override
  String get gradesFailedToLoad => 'Ne udalos zagruzit otsenki';

  @override
  String get gradesRetry => 'Povtorit';

  @override
  String get gradesExcellent => 'Otlichno';

  @override
  String get gradesGood => 'Khorosho';

  @override
  String get gradesFair => 'Udovletvoritelno';

  @override
  String get gradesNeedsWork => 'Trebuet uluchsheniya';

  @override
  String gradesWeightLabel(String weight) {
    return 'Ves $weight';
  }

  @override
  String get subjectStream => 'Lenta';

  @override
  String get subjectAssignments => 'Zadaniya';

  @override
  String get subjectMaterials => 'Materiali';

  @override
  String get subjectNoPostsYet => 'Poka net zapisey';

  @override
  String get subjectPostsWillAppear =>
      'Zapisi poyavyatsya zdes, kogda uchitel opublikuet obnovleniya';

  @override
  String subjectTodayAt(String time) {
    return 'Segodnya v $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Vchera v $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day v $time';
  }

  @override
  String get subjectNoAssignments => 'Net zadaniy';

  @override
  String get subjectAssignmentsWillAppear =>
      'Zadaniya poyavyatsya zdes, kogda uchitel ikh opublikuet';

  @override
  String get subjectDueToday => 'Srok segodnya';

  @override
  String get subjectDueTomorrow => 'Srok zavtra';

  @override
  String subjectDueDate(String date) {
    return 'Srok $date';
  }

  @override
  String get subjectSubmitted => 'Zadanie sdano!';

  @override
  String get subjectSubmit => 'Otpravit';

  @override
  String get subjectNoMaterials => 'Net materialov';

  @override
  String get subjectMaterialsWillAppear =>
      'Materiali kursa poyavyatsya zdes, kogda uchitel ikh opublikuet';

  @override
  String subjectOpening(String url) {
    return 'Otkryivayu: $url';
  }

  @override
  String get subjectFailedToLoad => 'Ne udalos zagruzit predmet';

  @override
  String get accessDenied => 'Dostup zapreshchen';

  @override
  String get noSchoolAssigned => 'Shkola ne naznachena';

  @override
  String get schoolAdmin => 'Administratsiya shkoli';

  @override
  String get users => 'Polzovateli';

  @override
  String get classes => 'Klassi';

  @override
  String get subjects => 'Predmeti';

  @override
  String get inviteCodes => 'Kodi priglasheniya';

  @override
  String get schoolDetails => 'Svedeniya o shkole';

  @override
  String get principalDashboard => 'Panel direktora';

  @override
  String get deputyDashboard => 'Panel zamestitelya direktora';

  @override
  String get deputyPanel => 'Panel zamestitelya direktora';

  @override
  String get emailLabel => 'Elektronnaya pochta';

  @override
  String get passwordLabel => 'Parol';

  @override
  String get inviteCodeLabel => 'Kod priglasheniya';

  @override
  String get signIn => 'Voyti';

  @override
  String get signUp => 'Zaregistrirovatsya';

  @override
  String get register => 'Zaregistrirovatsya';

  @override
  String get registerWithInviteCode => 'Registratsiya s kodom priglasheniya';

  @override
  String get dontHaveAccount => 'Net akkaunata?';

  @override
  String get alreadyHaveAccount => 'Uzhe est akkaunt?';

  @override
  String get iDontHaveAccount => 'U menya net akkaunta';

  @override
  String get inviteCodeRequiredError =>
      'Pozhaluysta, vvedite kod priglasheniya';

  @override
  String get inviteCodeTooShort =>
      'Kod priglasheniya dolzhen soderzhat ne menee 6 simvolov';

  @override
  String get firstNameLabel => 'Imya';

  @override
  String get lastNameLabel => 'Familiya';

  @override
  String get confirmPasswordLabel => 'Podtverdit parol';

  @override
  String get pleaseConfirmPassword => 'Pozhaluysta, podtverdite parol';

  @override
  String get passwordsDoNotMatch => 'Paroli ne sovpadayut';

  @override
  String get firstNameRequired => 'Pozhaluysta, vvedite imya';

  @override
  String get firstNameTooShort => 'Imya dolzhno soderzhat ne menee 2 simvolov';

  @override
  String get lastNameRequired => 'Pozhaluysta, vvedite familiyu';

  @override
  String get lastNameTooShort =>
      'Familiya dolzhna soderzhat ne menee 2 simvolov';

  @override
  String get enterYourEmail => 'Vvedite adres elektronnoy pochti';

  @override
  String get enterYourPassword => 'Vvedite parol';

  @override
  String get enterYourInviteCode => 'Vvedite kod priglasheniya';

  @override
  String get enterYourFirstName => 'Vvedite imya';

  @override
  String get enterYourLastName => 'Vvedite familiyu';

  @override
  String get reEnterPassword => 'Vvedite parol snova';

  @override
  String get welcomeToClassio => 'Dobro pozhalovat v Classio';

  @override
  String get joinClassio => 'Prisoedinitsya k Classio';

  @override
  String get createAccountToGetStarted => 'Sozdayte akkaunt, chtobi nachat';

  @override
  String get dismiss => 'Zakrit';

  @override
  String get resetPassword => 'Sbrosit parol';

  @override
  String get resetPasswordInstructions =>
      'Vvedite adres elektronnoy pochti, i mi otpravim vam ssilku dlya sbrosa parolya.';

  @override
  String get sendResetLink => 'Otpravit ssilku';

  @override
  String get passwordResetLinkSent =>
      'Ssilka otpravlena! Proverite pochtoviy yashchik.';

  @override
  String get failedToSendResetLink =>
      'Ne udalos otpravit ssilku. Poprobuite snova.';

  @override
  String get noPermissionToAccessPage =>
      'U vas net razresheniya na dostup k etoy stranitse.';

  @override
  String get notAssignedToSchool => 'Vi ne prikrepleni ni k kakoy shkole.';

  @override
  String get generateInvite => 'Sozdat priglashenie';

  @override
  String get createClass => 'Sozdat klass';

  @override
  String get overview => 'Obzor';

  @override
  String get schedule => 'Raspisanie';

  @override
  String get parents => 'Roditeli';

  @override
  String get staff => 'Personal';

  @override
  String get invites => 'Priglasheniya';

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
