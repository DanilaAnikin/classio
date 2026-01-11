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
  String get dashboardGreetingMorning => 'Good Morning';

  @override
  String get dashboardGreetingAfternoon => 'Good Afternoon';

  @override
  String get dashboardGreetingEvening => 'Good Evening';

  @override
  String get dashboardUpNext => 'Up Next';

  @override
  String get dashboardTodaySchedule => 'Today\'s Schedule';

  @override
  String get dashboardDueSoon => 'Due Soon';

  @override
  String get lessonCancelled => 'Cancelled';

  @override
  String get lessonSubstitution => 'Substitution';

  @override
  String get lessonInProgress => 'In Progress';

  @override
  String lessonUpcoming(int minutes) {
    return 'Starting in $minutes min';
  }

  @override
  String lessonRoom(String room) {
    return 'Room $room';
  }

  @override
  String get assignmentDueToday => 'Due Today';

  @override
  String get assignmentDueTomorrow => 'Due Tomorrow';

  @override
  String assignmentDueIn(int days) {
    return 'Due in $days days';
  }

  @override
  String get assignmentCompleted => 'Completed';

  @override
  String get assignmentOverdue => 'Overdue';

  @override
  String get noLessonsToday => 'No lessons today';

  @override
  String get noUpcomingAssignments => 'No upcoming assignments';

  @override
  String get allDoneForToday => 'All done for today!';

  @override
  String get freeTime => 'Free Time';

  @override
  String get dashboardLoading => 'Loading your dashboard...';

  @override
  String get dashboardError => 'Something went wrong';

  @override
  String get dashboardRetry => 'Retry';

  @override
  String get navHome => 'Home';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navGrades => 'Grades';

  @override
  String get navProfile => 'Profile';

  @override
  String get scheduleTitle => 'Weekly Schedule';

  @override
  String get scheduleMonday => 'Mon';

  @override
  String get scheduleTuesday => 'Tue';

  @override
  String get scheduleWednesday => 'Wed';

  @override
  String get scheduleThursday => 'Thu';

  @override
  String get scheduleFriday => 'Fri';

  @override
  String get scheduleSaturday => 'Sat';

  @override
  String get scheduleSunday => 'Sun';

  @override
  String get scheduleMondayFull => 'Monday';

  @override
  String get scheduleTuesdayFull => 'Tuesday';

  @override
  String get scheduleWednesdayFull => 'Wednesday';

  @override
  String get scheduleThursdayFull => 'Thursday';

  @override
  String get scheduleFridayFull => 'Friday';

  @override
  String get scheduleNoLessons => 'No lessons scheduled';

  @override
  String get scheduleBreak => 'Break';

  @override
  String get gradesTitle => 'Noten';

  @override
  String get gradesComingSoon => 'Grades coming soon';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileThemeSection => 'Appearance';

  @override
  String get profileLanguageSection => 'Language';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to log out?';

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
  String get subjectDetailStream => 'Stream';

  @override
  String get subjectDetailStreamDescription =>
      'Class announcements and updates';

  @override
  String get subjectDetailAssignments => 'Assignments';

  @override
  String get subjectDetailAssignmentsDescription => 'Your tasks and homework';

  @override
  String get subjectDetailMaterials => 'Materials';

  @override
  String get subjectDetailMaterialsDescription => 'Course resources and files';

  @override
  String get subjectDetailAnnouncement => 'Announcement';

  @override
  String get subjectDetailAssignment => 'Assignment';

  @override
  String get subjectDetailSubmit => 'Submit';

  @override
  String get subjectDetailSubmitted => 'Assignment Submitted!';

  @override
  String get subjectDetailNoStream => 'No announcements yet';

  @override
  String get subjectDetailNoAssignments => 'No assignments yet';

  @override
  String get subjectDetailNoMaterials => 'No materials yet';

  @override
  String subjectDetailDueDate(String date) {
    return 'Due $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Posted by $author';
  }

  @override
  String get subjectDetailViewMaterial => 'View Material';

  @override
  String get dashboardInProgress => 'In Progress';

  @override
  String get dashboardUpNextLabel => 'Up Next';

  @override
  String get dashboardStarted => 'Started';

  @override
  String get dashboardStartingNow => 'Starting now';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'in ${hours}h ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'in ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Cancelled';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Substitution: $teacher';
  }

  @override
  String get dashboardAllDone => 'All done for today!';

  @override
  String get dashboardNoMoreLessons => 'No more lessons scheduled';

  @override
  String get dashboardNoClassesToday => 'No classes today';

  @override
  String get dashboardEnjoyFreeDay => 'Enjoy your free day!';

  @override
  String get dashboardSub => 'SUB';

  @override
  String get dashboardToday => 'Today';

  @override
  String get dashboardTomorrow => 'Tomorrow';

  @override
  String get dashboardLater => 'Later';

  @override
  String get dashboardAllCaughtUp => 'All caught up!';

  @override
  String get dashboardNoAssignmentsDue => 'No assignments due soon';

  @override
  String get dashboardSomethingWrong => 'Something went wrong';

  @override
  String get dashboardStudent => 'Student';

  @override
  String get dashboardAnError => 'An error occurred';

  @override
  String get dashboardNoData => 'No data available';

  @override
  String scheduleLessonCount(int count) {
    return '$count lesson';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count lessons';
  }

  @override
  String get scheduleWeekend => 'Weekend!';

  @override
  String get scheduleEnjoyTimeOff => 'Enjoy your time off!';

  @override
  String get scheduleFreeDay => 'You have a free day. Time to relax!';

  @override
  String get scheduleUnknown => 'Unknown';

  @override
  String get gradesNoGradesYet => 'No grades yet';

  @override
  String get gradesWillAppear =>
      'Your grades will appear here once they are available.';

  @override
  String get gradesFailedToLoad => 'Failed to load grades';

  @override
  String get gradesRetry => 'Retry';

  @override
  String get gradesExcellent => 'Excellent';

  @override
  String get gradesGood => 'Good';

  @override
  String get gradesFair => 'Fair';

  @override
  String get gradesNeedsWork => 'Needs Work';

  @override
  String gradesWeightLabel(String weight) {
    return 'Weight $weight';
  }

  @override
  String get subjectStream => 'Stream';

  @override
  String get subjectAssignments => 'Assignments';

  @override
  String get subjectMaterials => 'Materials';

  @override
  String get subjectNoPostsYet => 'No posts yet';

  @override
  String get subjectPostsWillAppear =>
      'Posts will appear here when your teacher shares updates';

  @override
  String subjectTodayAt(String time) {
    return 'Today at $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day at $time';
  }

  @override
  String get subjectNoAssignments => 'No assignments';

  @override
  String get subjectAssignmentsWillAppear =>
      'Assignments will appear here when your teacher posts them';

  @override
  String get subjectDueToday => 'Due today';

  @override
  String get subjectDueTomorrow => 'Due tomorrow';

  @override
  String subjectDueDate(String date) {
    return 'Due $date';
  }

  @override
  String get subjectSubmitted => 'Assignment Submitted!';

  @override
  String get subjectSubmit => 'Submit';

  @override
  String get subjectNoMaterials => 'No materials';

  @override
  String get subjectMaterialsWillAppear =>
      'Course materials will appear here when your teacher shares them';

  @override
  String subjectOpening(String url) {
    return 'Opening: $url';
  }

  @override
  String get subjectFailedToLoad => 'Failed to load subject';
}
