// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Classio';

  @override
  String get welcomeMessage => 'Willkommen bei Classio';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String get cleanTheme => 'Schlicht';

  @override
  String get playfulTheme => 'Verspielt';

  @override
  String get home => 'Startseite';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get selectLanguage => 'Sprache auswahlen';

  @override
  String get selectTheme => 'Design auswahlen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get welcomeBack => 'Willkommen zuruck';

  @override
  String get signInToContinue => 'Melden Sie sich an, um fortzufahren';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get loginError =>
      'Anmeldung fehlgeschlagen. Bitte uberprufen Sie Ihre Anmeldedaten.';

  @override
  String get emailRequired => 'E-Mail ist erforderlich';

  @override
  String get emailInvalid => 'Bitte geben Sie eine gultige E-Mail ein';

  @override
  String get passwordRequired => 'Passwort ist erforderlich';

  @override
  String get passwordTooShort => 'Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get loggingIn => 'Anmeldung lauft...';

  @override
  String get dashboardGreetingMorning => 'Guten Morgen';

  @override
  String get dashboardGreetingAfternoon => 'Guten Tag';

  @override
  String get dashboardGreetingEvening => 'Guten Abend';

  @override
  String get dashboardUpNext => 'Als Nachstes';

  @override
  String get dashboardTodaySchedule => 'Heutiger Stundenplan';

  @override
  String get dashboardDueSoon => 'Bald fallig';

  @override
  String get lessonCancelled => 'Abgesagt';

  @override
  String get lessonSubstitution => 'Vertretung';

  @override
  String get lessonInProgress => 'Lauft gerade';

  @override
  String lessonUpcoming(int minutes) {
    return 'Beginnt in $minutes Min';
  }

  @override
  String lessonRoom(String room) {
    return 'Raum $room';
  }

  @override
  String get assignmentDueToday => 'Heute fallig';

  @override
  String get assignmentDueTomorrow => 'Morgen fallig';

  @override
  String assignmentDueIn(int days) {
    return 'Fallig in $days Tagen';
  }

  @override
  String get assignmentCompleted => 'Abgeschlossen';

  @override
  String get assignmentOverdue => 'Uberfalllig';

  @override
  String get noLessonsToday => 'Heute keine Unterrichtsstunden';

  @override
  String get noUpcomingAssignments => 'Keine anstehenden Aufgaben';

  @override
  String get allDoneForToday => 'Fur heute alles erledigt!';

  @override
  String get freeTime => 'Freizeit';

  @override
  String get dashboardLoading => 'Dashboard wird geladen...';

  @override
  String get dashboardError => 'Etwas ist schiefgelaufen';

  @override
  String get dashboardRetry => 'Erneut versuchen';

  @override
  String get navHome => 'Startseite';

  @override
  String get navSchedule => 'Stundenplan';

  @override
  String get navGrades => 'Noten';

  @override
  String get navProfile => 'Profil';

  @override
  String get scheduleTitle => 'Wochenstundenplan';

  @override
  String get scheduleMonday => 'Mo';

  @override
  String get scheduleTuesday => 'Di';

  @override
  String get scheduleWednesday => 'Mi';

  @override
  String get scheduleThursday => 'Do';

  @override
  String get scheduleFriday => 'Fr';

  @override
  String get scheduleSaturday => 'Sa';

  @override
  String get scheduleSunday => 'So';

  @override
  String get scheduleMondayFull => 'Montag';

  @override
  String get scheduleTuesdayFull => 'Dienstag';

  @override
  String get scheduleWednesdayFull => 'Mittwoch';

  @override
  String get scheduleThursdayFull => 'Donnerstag';

  @override
  String get scheduleFridayFull => 'Freitag';

  @override
  String get scheduleNoLessons => 'Keine Unterrichtsstunden';

  @override
  String get scheduleBreak => 'Pause';

  @override
  String get gradesTitle => 'Noten';

  @override
  String get gradesComingSoon => 'Noten kommen bald';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileThemeSection => 'Erscheinungsbild';

  @override
  String get profileLanguageSection => 'Sprache';

  @override
  String get profileLogout => 'Abmelden';

  @override
  String get profileLogoutConfirm => 'Mochten Sie sich wirklich abmelden?';

  @override
  String get gradesAverage => 'Durchschnitt';

  @override
  String get gradesWeight => 'Gewichtung';

  @override
  String get gradesDate => 'Datum';

  @override
  String get gradesOverallAverage => 'Gesamtdurchschnitt';

  @override
  String get gradesNoGrades => 'Noch keine Noten';

  @override
  String gradesWeightFormat(String weight) {
    return 'Gewichtung $weight';
  }

  @override
  String get subjectDetailStream => 'Neuigkeiten';

  @override
  String get subjectDetailStreamDescription =>
      'Ankundigungen und Updates der Klasse';

  @override
  String get subjectDetailAssignments => 'Aufgaben';

  @override
  String get subjectDetailAssignmentsDescription =>
      'Ihre Aufgaben und Hausaufgaben';

  @override
  String get subjectDetailMaterials => 'Materialien';

  @override
  String get subjectDetailMaterialsDescription => 'Kursmaterialien und Dateien';

  @override
  String get subjectDetailAnnouncement => 'Ankundigung';

  @override
  String get subjectDetailAssignment => 'Aufgabe';

  @override
  String get subjectDetailSubmit => 'Einreichen';

  @override
  String get subjectDetailSubmitted => 'Aufgabe eingereicht!';

  @override
  String get subjectDetailNoStream => 'Noch keine Ankundigungen';

  @override
  String get subjectDetailNoAssignments => 'Noch keine Aufgaben';

  @override
  String get subjectDetailNoMaterials => 'Noch keine Materialien';

  @override
  String subjectDetailDueDate(String date) {
    return 'Fallig am $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Gepostet von $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Material anzeigen';

  @override
  String get dashboardInProgress => 'Lauft gerade';

  @override
  String get dashboardUpNextLabel => 'Als Nachstes';

  @override
  String get dashboardStarted => 'Gestartet';

  @override
  String get dashboardStartingNow => 'Beginnt jetzt';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'in ${hours}h ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'in ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Abgesagt';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Vertretung: $teacher';
  }

  @override
  String get dashboardAllDone => 'Fur heute alles erledigt!';

  @override
  String get dashboardNoMoreLessons => 'Keine weiteren Stunden geplant';

  @override
  String get dashboardNoClassesToday => 'Heute kein Unterricht';

  @override
  String get dashboardEnjoyFreeDay => 'Geniessen Sie Ihren freien Tag!';

  @override
  String get dashboardSub => 'VERTR';

  @override
  String get dashboardToday => 'Heute';

  @override
  String get dashboardTomorrow => 'Morgen';

  @override
  String get dashboardLater => 'Spater';

  @override
  String get dashboardAllCaughtUp => 'Alles erledigt!';

  @override
  String get dashboardNoAssignmentsDue => 'Keine Aufgaben bald fallig';

  @override
  String get dashboardSomethingWrong => 'Etwas ist schiefgelaufen';

  @override
  String get dashboardStudent => 'Schuler';

  @override
  String get dashboardAnError => 'Ein Fehler ist aufgetreten';

  @override
  String get dashboardNoData => 'Keine Daten verfugbar';

  @override
  String scheduleLessonCount(int count) {
    return '$count Stunde';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count Stunden';
  }

  @override
  String get scheduleWeekend => 'Wochenende!';

  @override
  String get scheduleEnjoyTimeOff => 'Geniessen Sie Ihre freie Zeit!';

  @override
  String get scheduleFreeDay =>
      'Sie haben einen freien Tag. Zeit zum Entspannen!';

  @override
  String get scheduleUnknown => 'Unbekannt';

  @override
  String get gradesNoGradesYet => 'Noch keine Noten';

  @override
  String get gradesWillAppear =>
      'Ihre Noten werden hier angezeigt, sobald sie verfugbar sind.';

  @override
  String get gradesFailedToLoad => 'Noten konnten nicht geladen werden';

  @override
  String get gradesRetry => 'Erneut versuchen';

  @override
  String get gradesExcellent => 'Ausgezeichnet';

  @override
  String get gradesGood => 'Gut';

  @override
  String get gradesFair => 'Befriedigend';

  @override
  String get gradesNeedsWork => 'Verbesserung notig';

  @override
  String gradesWeightLabel(String weight) {
    return 'Gewichtung $weight';
  }

  @override
  String get subjectStream => 'Neuigkeiten';

  @override
  String get subjectAssignments => 'Aufgaben';

  @override
  String get subjectMaterials => 'Materialien';

  @override
  String get subjectNoPostsYet => 'Noch keine Beitrage';

  @override
  String get subjectPostsWillAppear =>
      'Beitrage erscheinen hier, wenn Ihr Lehrer Updates teilt';

  @override
  String subjectTodayAt(String time) {
    return 'Heute um $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Gestern um $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day um $time';
  }

  @override
  String get subjectNoAssignments => 'Keine Aufgaben';

  @override
  String get subjectAssignmentsWillAppear =>
      'Aufgaben erscheinen hier, wenn Ihr Lehrer sie postet';

  @override
  String get subjectDueToday => 'Heute fallig';

  @override
  String get subjectDueTomorrow => 'Morgen fallig';

  @override
  String subjectDueDate(String date) {
    return 'Fallig am $date';
  }

  @override
  String get subjectSubmitted => 'Aufgabe eingereicht!';

  @override
  String get subjectSubmit => 'Einreichen';

  @override
  String get subjectNoMaterials => 'Keine Materialien';

  @override
  String get subjectMaterialsWillAppear =>
      'Kursmaterialien erscheinen hier, wenn Ihr Lehrer sie teilt';

  @override
  String subjectOpening(String url) {
    return 'Offne: $url';
  }

  @override
  String get subjectFailedToLoad => 'Fach konnte nicht geladen werden';

  @override
  String get accessDenied => 'Zugriff verweigert';

  @override
  String get noSchoolAssigned => 'Keine Schule zugewiesen';

  @override
  String get schoolAdmin => 'Schulverwaltung';

  @override
  String get users => 'Benutzer';

  @override
  String get classes => 'Klassen';

  @override
  String get subjects => 'Facher';

  @override
  String get inviteCodes => 'Einladungscodes';

  @override
  String get schoolDetails => 'Schuldetails';

  @override
  String get principalDashboard => 'Schulleiter-Dashboard';

  @override
  String get deputyDashboard => 'Stellvertreter-Dashboard';

  @override
  String get deputyPanel => 'Stellvertreter-Panel';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get inviteCodeLabel => 'Einladungscode';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get register => 'Registrieren';

  @override
  String get registerWithInviteCode => 'Mit Einladungscode registrieren';

  @override
  String get dontHaveAccount => 'Noch kein Konto?';

  @override
  String get alreadyHaveAccount => 'Bereits ein Konto?';

  @override
  String get iDontHaveAccount => 'Ich habe kein Konto';

  @override
  String get inviteCodeRequiredError =>
      'Bitte geben Sie Ihren Einladungscode ein';

  @override
  String get inviteCodeTooShort =>
      'Einladungscode muss mindestens 6 Zeichen haben';

  @override
  String get firstNameLabel => 'Vorname';

  @override
  String get lastNameLabel => 'Nachname';

  @override
  String get confirmPasswordLabel => 'Passwort bestatigen';

  @override
  String get pleaseConfirmPassword => 'Bitte bestatigen Sie Ihr Passwort';

  @override
  String get passwordsDoNotMatch => 'Passworter stimmen nicht uberein';

  @override
  String get firstNameRequired => 'Bitte geben Sie Ihren Vornamen ein';

  @override
  String get firstNameTooShort => 'Vorname muss mindestens 2 Zeichen haben';

  @override
  String get lastNameRequired => 'Bitte geben Sie Ihren Nachnamen ein';

  @override
  String get lastNameTooShort => 'Nachname muss mindestens 2 Zeichen haben';

  @override
  String get enterYourEmail => 'Geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get enterYourPassword => 'Geben Sie Ihr Passwort ein';

  @override
  String get enterYourInviteCode => 'Geben Sie Ihren Einladungscode ein';

  @override
  String get enterYourFirstName => 'Geben Sie Ihren Vornamen ein';

  @override
  String get enterYourLastName => 'Geben Sie Ihren Nachnamen ein';

  @override
  String get reEnterPassword => 'Passwort erneut eingeben';

  @override
  String get welcomeToClassio => 'Willkommen bei Classio';

  @override
  String get joinClassio => 'Classio beitreten';

  @override
  String get createAccountToGetStarted =>
      'Erstellen Sie ein Konto, um loszulegen';

  @override
  String get dismiss => 'Schliessen';

  @override
  String get resetPassword => 'Passwort zurucksetzen';

  @override
  String get resetPasswordInstructions =>
      'Geben Sie Ihre E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurucksetzen Ihres Passworts.';

  @override
  String get sendResetLink => 'Link senden';

  @override
  String get passwordResetLinkSent =>
      'Link zum Zurucksetzen gesendet! Uberprufen Sie Ihren Posteingang.';

  @override
  String get failedToSendResetLink =>
      'Link konnte nicht gesendet werden. Bitte versuchen Sie es erneut.';

  @override
  String get noPermissionToAccessPage =>
      'Sie haben keine Berechtigung, auf diese Seite zuzugreifen.';

  @override
  String get notAssignedToSchool => 'Sie sind keiner Schule zugewiesen.';

  @override
  String get generateInvite => 'Einladung erstellen';

  @override
  String get createClass => 'Klasse erstellen';

  @override
  String get overview => 'Ubersicht';

  @override
  String get schedule => 'Stundenplan';

  @override
  String get parents => 'Eltern';

  @override
  String get staff => 'Personal';

  @override
  String get invites => 'Einladungen';

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
