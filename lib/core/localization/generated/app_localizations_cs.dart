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
  String get subjectDetailStream => 'Příspěvky';

  @override
  String get subjectDetailStreamDescription => 'Oznámení a aktuality z hodiny';

  @override
  String get subjectDetailAssignments => 'Úkoly';

  @override
  String get subjectDetailAssignmentsDescription => 'Vaše úkoly a domácí práce';

  @override
  String get subjectDetailMaterials => 'Materiály';

  @override
  String get subjectDetailMaterialsDescription => 'Materiály a soubory kurzu';

  @override
  String get subjectDetailAnnouncement => 'Oznámení';

  @override
  String get subjectDetailAssignment => 'Úkol';

  @override
  String get subjectDetailSubmit => 'Odevzdat';

  @override
  String get subjectDetailSubmitted => 'Úkol odevzdán!';

  @override
  String get subjectDetailNoStream => 'Zatím žádná oznámení';

  @override
  String get subjectDetailNoAssignments => 'Zatím žádné úkoly';

  @override
  String get subjectDetailNoMaterials => 'Zatím žádné materiály';

  @override
  String subjectDetailDueDate(String date) {
    return 'Termín $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Přidal/a $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Zobrazit materiál';

  @override
  String get dashboardInProgress => 'Probíhá';

  @override
  String get dashboardUpNextLabel => 'Další';

  @override
  String get dashboardStarted => 'Začalo';

  @override
  String get dashboardStartingNow => 'Začíná nyní';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'za ${hours}h ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'za ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Zrušeno';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Suplování: $teacher';
  }

  @override
  String get dashboardAllDone => 'Vše hotovo na dnešek!';

  @override
  String get dashboardNoMoreLessons => 'Žádné další hodiny naplánovány';

  @override
  String get dashboardNoClassesToday => 'Dnes žádné hodiny';

  @override
  String get dashboardEnjoyFreeDay => 'Užijte si volný den!';

  @override
  String get dashboardSub => 'SUP';

  @override
  String get dashboardToday => 'Dnes';

  @override
  String get dashboardTomorrow => 'Zítra';

  @override
  String get dashboardLater => 'Později';

  @override
  String get dashboardAllCaughtUp => 'Vše zvládnuto!';

  @override
  String get dashboardNoAssignmentsDue => 'Žádné úkoly brzy nesplatné';

  @override
  String get dashboardSomethingWrong => 'Něco se pokazilo';

  @override
  String get dashboardStudent => 'Student';

  @override
  String get dashboardAnError => 'Došlo k chybě';

  @override
  String get dashboardNoData => 'Žádná data k dispozici';

  @override
  String scheduleLessonCount(int count) {
    return '$count hodina';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count hodin';
  }

  @override
  String get scheduleWeekend => 'Víkend!';

  @override
  String get scheduleEnjoyTimeOff => 'Užijte si volno!';

  @override
  String get scheduleFreeDay => 'Máte volný den. Čas odpočívat!';

  @override
  String get scheduleUnknown => 'Neznámý';

  @override
  String get gradesNoGradesYet => 'Zatím žádné známky';

  @override
  String get gradesWillAppear =>
      'Vaše známky se zde zobrazí, jakmile budou k dispozici.';

  @override
  String get gradesFailedToLoad => 'Nepodařilo se načíst známky';

  @override
  String get gradesRetry => 'Opakovat';

  @override
  String get gradesExcellent => 'Výborně';

  @override
  String get gradesGood => 'Dobře';

  @override
  String get gradesFair => 'Dostatečně';

  @override
  String get gradesNeedsWork => 'Potřebuje zlepšit';

  @override
  String gradesWeightLabel(String weight) {
    return 'Váha $weight';
  }

  @override
  String get subjectStream => 'Aktuality';

  @override
  String get subjectAssignments => 'Úkoly';

  @override
  String get subjectMaterials => 'Materiály';

  @override
  String get subjectNoPostsYet => 'Zatím žádné příspěvky';

  @override
  String get subjectPostsWillAppear =>
      'Příspěvky se zde zobrazí, když učitel sdílí aktualizace';

  @override
  String subjectTodayAt(String time) {
    return 'Dnes v $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Včera v $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day v $time';
  }

  @override
  String get subjectNoAssignments => 'Žádné úkoly';

  @override
  String get subjectAssignmentsWillAppear =>
      'Úkoly se zde zobrazí, když je učitel zadá';

  @override
  String get subjectDueToday => 'Splatné dnes';

  @override
  String get subjectDueTomorrow => 'Splatné zítra';

  @override
  String subjectDueDate(String date) {
    return 'Splatné $date';
  }

  @override
  String get subjectSubmitted => 'Úkol odevzdán!';

  @override
  String get subjectSubmit => 'Odevzdat';

  @override
  String get subjectNoMaterials => 'Žádné materiály';

  @override
  String get subjectMaterialsWillAppear =>
      'Materiály kurzu se zde zobrazí, když je učitel sdílí';

  @override
  String subjectOpening(String url) {
    return 'Otevírám: $url';
  }

  @override
  String get subjectFailedToLoad => 'Nepodařilo se načíst předmět';
}
