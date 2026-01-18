// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Classio';

  @override
  String get welcomeMessage => 'Welcome to Classio';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get cleanTheme => 'Clean';

  @override
  String get playfulTheme => 'Playful';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginError => 'Login failed. Please check your credentials.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get loggingIn => 'Logging in...';

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
  String get gradesTitle => 'Grades';

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
  String get gradesAverage => 'Average';

  @override
  String get gradesWeight => 'Weight';

  @override
  String get gradesDate => 'Date';

  @override
  String get gradesOverallAverage => 'Overall Average';

  @override
  String get gradesNoGrades => 'No grades yet';

  @override
  String gradesWeightFormat(String weight) {
    return 'Weight $weight';
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

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get noSchoolAssigned => 'No School Assigned';

  @override
  String get schoolAdmin => 'School Admin';

  @override
  String get users => 'Users';

  @override
  String get classes => 'Classes';

  @override
  String get subjects => 'Subjects';

  @override
  String get inviteCodes => 'Invite Codes';

  @override
  String get schoolDetails => 'School Details';

  @override
  String get principalDashboard => 'Principal Dashboard';

  @override
  String get deputyDashboard => 'Deputy Dashboard';

  @override
  String get deputyPanel => 'Deputy Panel';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get inviteCodeLabel => 'Invite Code';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get register => 'Register';

  @override
  String get registerWithInviteCode => 'Register with Invite Code';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get iDontHaveAccount => 'I don\'t have an account';

  @override
  String get inviteCodeRequiredError => 'Please enter your invite code';

  @override
  String get inviteCodeTooShort => 'Invite code must be at least 6 characters';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get lastNameLabel => 'Last Name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get firstNameRequired => 'Please enter your first name';

  @override
  String get firstNameTooShort => 'First name must be at least 2 characters';

  @override
  String get lastNameRequired => 'Please enter your last name';

  @override
  String get lastNameTooShort => 'Last name must be at least 2 characters';

  @override
  String get enterYourEmail => 'Enter your email address';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get enterYourInviteCode => 'Enter your invite code';

  @override
  String get enterYourFirstName => 'Enter your first name';

  @override
  String get enterYourLastName => 'Enter your last name';

  @override
  String get reEnterPassword => 'Re-enter your password';

  @override
  String get welcomeToClassio => 'Welcome to Classio';

  @override
  String get joinClassio => 'Join Classio';

  @override
  String get createAccountToGetStarted => 'Create your account to get started';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInstructions =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get passwordResetLinkSent =>
      'Password reset link sent! Check your email inbox.';

  @override
  String get failedToSendResetLink =>
      'Failed to send reset link. Please try again.';

  @override
  String get noPermissionToAccessPage =>
      'You do not have permission to access this page.';

  @override
  String get notAssignedToSchool => 'You are not assigned to any school.';

  @override
  String get generateInvite => 'Generate Invite';

  @override
  String get createClass => 'Create Class';

  @override
  String get overview => 'Overview';

  @override
  String get schedule => 'Schedule';

  @override
  String get parents => 'Parents';

  @override
  String get staff => 'Staff';

  @override
  String get invites => 'Invites';

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
