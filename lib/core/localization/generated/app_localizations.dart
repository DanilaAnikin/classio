import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl'),
    Locale('ru'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Classio'**
  String get appName;

  /// Welcome message displayed on the home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Classio'**
  String get welcomeMessage;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme selection label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Clean theme option
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get cleanTheme;

  /// Playful theme option
  ///
  /// In en, this message translates to:
  /// **'Playful'**
  String get playfulTheme;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Dashboard navigation item
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Theme selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Welcome back message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Sign in prompt message
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginError;

  /// Email validation error message
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Email format validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// Password validation error message
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Password length validation error message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Login progress message
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// Morning greeting on dashboard
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get dashboardGreetingMorning;

  /// Afternoon greeting on dashboard
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get dashboardGreetingAfternoon;

  /// Evening greeting on dashboard
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get dashboardGreetingEvening;

  /// Section header for upcoming item
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get dashboardUpNext;

  /// Section header for today's schedule
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get dashboardTodaySchedule;

  /// Section header for items due soon
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get dashboardDueSoon;

  /// Status for cancelled lesson
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get lessonCancelled;

  /// Status for substitution lesson
  ///
  /// In en, this message translates to:
  /// **'Substitution'**
  String get lessonSubstitution;

  /// Status for lesson currently in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get lessonInProgress;

  /// Status for upcoming lesson with time
  ///
  /// In en, this message translates to:
  /// **'Starting in {minutes} min'**
  String lessonUpcoming(int minutes);

  /// Room number display
  ///
  /// In en, this message translates to:
  /// **'Room {room}'**
  String lessonRoom(String room);

  /// Assignment due today status
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get assignmentDueToday;

  /// Assignment due tomorrow status
  ///
  /// In en, this message translates to:
  /// **'Due Tomorrow'**
  String get assignmentDueTomorrow;

  /// Assignment due in specified days
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days'**
  String assignmentDueIn(int days);

  /// Assignment completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get assignmentCompleted;

  /// Assignment overdue status
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get assignmentOverdue;

  /// Empty state for no lessons
  ///
  /// In en, this message translates to:
  /// **'No lessons today'**
  String get noLessonsToday;

  /// Empty state for no assignments
  ///
  /// In en, this message translates to:
  /// **'No upcoming assignments'**
  String get noUpcomingAssignments;

  /// Empty state when all tasks are complete
  ///
  /// In en, this message translates to:
  /// **'All done for today!'**
  String get allDoneForToday;

  /// Indicates free time period
  ///
  /// In en, this message translates to:
  /// **'Free Time'**
  String get freeTime;

  /// Loading state message for dashboard
  ///
  /// In en, this message translates to:
  /// **'Loading your dashboard...'**
  String get dashboardLoading;

  /// Error state message for dashboard
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get dashboardError;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dashboardRetry;

  /// Navigation tab for home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Navigation tab for schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// Navigation tab for grades
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get navGrades;

  /// Navigation tab for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Title for the schedule screen
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get scheduleTitle;

  /// Short form of Monday
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get scheduleMonday;

  /// Short form of Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get scheduleTuesday;

  /// Short form of Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get scheduleWednesday;

  /// Short form of Thursday
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get scheduleThursday;

  /// Short form of Friday
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get scheduleFriday;

  /// Short form of Saturday
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get scheduleSaturday;

  /// Short form of Sunday
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get scheduleSunday;

  /// Full name of Monday
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get scheduleMondayFull;

  /// Full name of Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get scheduleTuesdayFull;

  /// Full name of Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get scheduleWednesdayFull;

  /// Full name of Thursday
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get scheduleThursdayFull;

  /// Full name of Friday
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get scheduleFridayFull;

  /// Empty state for no lessons in schedule
  ///
  /// In en, this message translates to:
  /// **'No lessons scheduled'**
  String get scheduleNoLessons;

  /// Break time between lessons
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get scheduleBreak;

  /// Title for the grades screen
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get gradesTitle;

  /// Placeholder message for grades feature
  ///
  /// In en, this message translates to:
  /// **'Grades coming soon'**
  String get gradesComingSoon;

  /// Title for the profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Section header for theme settings in profile
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileThemeSection;

  /// Section header for language settings in profile
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageSection;

  /// Logout button in profile
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutConfirm;

  /// Label for average grade
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get gradesAverage;

  /// Label for grade weight
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get gradesWeight;

  /// Label for grade date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get gradesDate;

  /// Label for overall average across all subjects
  ///
  /// In en, this message translates to:
  /// **'Overall Average'**
  String get gradesOverallAverage;

  /// Message when there are no grades
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get gradesNoGrades;

  /// Format for displaying weight
  ///
  /// In en, this message translates to:
  /// **'Weight {weight}'**
  String gradesWeightFormat(String weight);

  /// Subject detail stream tab label
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get subjectDetailStream;

  /// Subject detail stream tab description
  ///
  /// In en, this message translates to:
  /// **'Class announcements and updates'**
  String get subjectDetailStreamDescription;

  /// Subject detail assignments tab label
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get subjectDetailAssignments;

  /// Subject detail assignments tab description
  ///
  /// In en, this message translates to:
  /// **'Your tasks and homework'**
  String get subjectDetailAssignmentsDescription;

  /// Subject detail materials tab label
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get subjectDetailMaterials;

  /// Subject detail materials tab description
  ///
  /// In en, this message translates to:
  /// **'Course resources and files'**
  String get subjectDetailMaterialsDescription;

  /// Subject detail announcement label
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get subjectDetailAnnouncement;

  /// Subject detail assignment label
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get subjectDetailAssignment;

  /// Subject detail submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get subjectDetailSubmit;

  /// Subject detail assignment submitted confirmation message
  ///
  /// In en, this message translates to:
  /// **'Assignment Submitted!'**
  String get subjectDetailSubmitted;

  /// Subject detail empty state for no announcements
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get subjectDetailNoStream;

  /// Subject detail empty state for no assignments
  ///
  /// In en, this message translates to:
  /// **'No assignments yet'**
  String get subjectDetailNoAssignments;

  /// Subject detail empty state for no materials
  ///
  /// In en, this message translates to:
  /// **'No materials yet'**
  String get subjectDetailNoMaterials;

  /// Subject detail due date format
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String subjectDetailDueDate(String date);

  /// Subject detail posted by author format
  ///
  /// In en, this message translates to:
  /// **'Posted by {author}'**
  String subjectDetailPostedBy(String author);

  /// Subject detail view material button text
  ///
  /// In en, this message translates to:
  /// **'View Material'**
  String get subjectDetailViewMaterial;

  /// Status for lesson currently in progress on dashboard
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get dashboardInProgress;

  /// Label for the next upcoming item
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get dashboardUpNextLabel;

  /// Status when lesson has already started
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get dashboardStarted;

  /// Status when lesson is starting now
  ///
  /// In en, this message translates to:
  /// **'Starting now'**
  String get dashboardStartingNow;

  /// Time until lesson in hours and minutes
  ///
  /// In en, this message translates to:
  /// **'in {hours}h {minutes}m'**
  String dashboardInHoursMinutes(int hours, int minutes);

  /// Time until lesson in minutes
  ///
  /// In en, this message translates to:
  /// **'in {minutes}m'**
  String dashboardInMinutes(int minutes);

  /// Status for cancelled lesson on dashboard
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get dashboardCancelled;

  /// Substitution status with teacher name
  ///
  /// In en, this message translates to:
  /// **'Substitution: {teacher}'**
  String dashboardSubstitution(String teacher);

  /// Message when all lessons are complete
  ///
  /// In en, this message translates to:
  /// **'All done for today!'**
  String get dashboardAllDone;

  /// Message when there are no more lessons
  ///
  /// In en, this message translates to:
  /// **'No more lessons scheduled'**
  String get dashboardNoMoreLessons;

  /// Message when there are no classes today
  ///
  /// In en, this message translates to:
  /// **'No classes today'**
  String get dashboardNoClassesToday;

  /// Message encouraging user to enjoy free day
  ///
  /// In en, this message translates to:
  /// **'Enjoy your free day!'**
  String get dashboardEnjoyFreeDay;

  /// Short label for substitution
  ///
  /// In en, this message translates to:
  /// **'SUB'**
  String get dashboardSub;

  /// Today label for assignments
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardToday;

  /// Tomorrow label for assignments
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dashboardTomorrow;

  /// Later label for assignments
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get dashboardLater;

  /// Message when all assignments are complete
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get dashboardAllCaughtUp;

  /// Message when no assignments are due soon
  ///
  /// In en, this message translates to:
  /// **'No assignments due soon'**
  String get dashboardNoAssignmentsDue;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get dashboardSomethingWrong;

  /// Default student label
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get dashboardStudent;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get dashboardAnError;

  /// Message when no data is available
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get dashboardNoData;

  /// Singular lesson count
  ///
  /// In en, this message translates to:
  /// **'{count} lesson'**
  String scheduleLessonCount(int count);

  /// Plural lessons count
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String scheduleLessonsCount(int count);

  /// Weekend message
  ///
  /// In en, this message translates to:
  /// **'Weekend!'**
  String get scheduleWeekend;

  /// Message to enjoy time off
  ///
  /// In en, this message translates to:
  /// **'Enjoy your time off!'**
  String get scheduleEnjoyTimeOff;

  /// Free day message
  ///
  /// In en, this message translates to:
  /// **'You have a free day. Time to relax!'**
  String get scheduleFreeDay;

  /// Unknown value placeholder
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get scheduleUnknown;

  /// Message when there are no grades yet
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get gradesNoGradesYet;

  /// Message explaining grades will appear when available
  ///
  /// In en, this message translates to:
  /// **'Your grades will appear here once they are available.'**
  String get gradesWillAppear;

  /// Error message when grades fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load grades'**
  String get gradesFailedToLoad;

  /// Retry button text for grades
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get gradesRetry;

  /// Excellent grade label
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get gradesExcellent;

  /// Good grade label
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get gradesGood;

  /// Fair grade label
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get gradesFair;

  /// Needs work grade label
  ///
  /// In en, this message translates to:
  /// **'Needs Work'**
  String get gradesNeedsWork;

  /// Weight label with value
  ///
  /// In en, this message translates to:
  /// **'Weight {weight}'**
  String gradesWeightLabel(String weight);

  /// Stream tab label
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get subjectStream;

  /// Assignments tab label
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get subjectAssignments;

  /// Materials tab label
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get subjectMaterials;

  /// Empty state for no posts
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get subjectNoPostsYet;

  /// Explanation for empty posts state
  ///
  /// In en, this message translates to:
  /// **'Posts will appear here when your teacher shares updates'**
  String get subjectPostsWillAppear;

  /// Today at specific time
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String subjectTodayAt(String time);

  /// Yesterday at specific time
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String subjectYesterdayAt(String time);

  /// Day at specific time
  ///
  /// In en, this message translates to:
  /// **'{day} at {time}'**
  String subjectDayAt(String day, String time);

  /// Empty state for no assignments
  ///
  /// In en, this message translates to:
  /// **'No assignments'**
  String get subjectNoAssignments;

  /// Explanation for empty assignments state
  ///
  /// In en, this message translates to:
  /// **'Assignments will appear here when your teacher posts them'**
  String get subjectAssignmentsWillAppear;

  /// Due today status
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get subjectDueToday;

  /// Due tomorrow status
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get subjectDueTomorrow;

  /// Due date with date value
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String subjectDueDate(String date);

  /// Assignment submitted confirmation
  ///
  /// In en, this message translates to:
  /// **'Assignment Submitted!'**
  String get subjectSubmitted;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get subjectSubmit;

  /// Empty state for no materials
  ///
  /// In en, this message translates to:
  /// **'No materials'**
  String get subjectNoMaterials;

  /// Explanation for empty materials state
  ///
  /// In en, this message translates to:
  /// **'Course materials will appear here when your teacher shares them'**
  String get subjectMaterialsWillAppear;

  /// Opening URL message
  ///
  /// In en, this message translates to:
  /// **'Opening: {url}'**
  String subjectOpening(String url);

  /// Error message when subject fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load subject'**
  String get subjectFailedToLoad;

  /// Access denied message
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// Message when user has no school assigned
  ///
  /// In en, this message translates to:
  /// **'No School Assigned'**
  String get noSchoolAssigned;

  /// School admin page title
  ///
  /// In en, this message translates to:
  /// **'School Admin'**
  String get schoolAdmin;

  /// Users tab label
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// Classes tab label
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// Subjects label
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// Invite codes section label
  ///
  /// In en, this message translates to:
  /// **'Invite Codes'**
  String get inviteCodes;

  /// School details page title
  ///
  /// In en, this message translates to:
  /// **'School Details'**
  String get schoolDetails;

  /// Principal dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Principal Dashboard'**
  String get principalDashboard;

  /// Deputy dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Deputy Dashboard'**
  String get deputyDashboard;

  /// Deputy panel page title
  ///
  /// In en, this message translates to:
  /// **'Deputy Panel'**
  String get deputyPanel;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Invite code field label
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCodeLabel;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Registration with invite code heading
  ///
  /// In en, this message translates to:
  /// **'Register with Invite Code'**
  String get registerWithInviteCode;

  /// Prompt for users without account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Prompt for users with account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Link text for users without account
  ///
  /// In en, this message translates to:
  /// **'I don\'t have an account'**
  String get iDontHaveAccount;

  /// Validation error when invite code is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your invite code'**
  String get inviteCodeRequiredError;

  /// Validation error when invite code is too short
  ///
  /// In en, this message translates to:
  /// **'Invite code must be at least 6 characters'**
  String get inviteCodeTooShort;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Validation error when confirm password is empty
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Validation error when passwords do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Validation error when first name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get firstNameRequired;

  /// Validation error when first name is too short
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 2 characters'**
  String get firstNameTooShort;

  /// Validation error when last name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get lastNameRequired;

  /// Validation error when last name is too short
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 2 characters'**
  String get lastNameTooShort;

  /// Email hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmail;

  /// Password hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Invite code hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your invite code'**
  String get enterYourInviteCode;

  /// First name hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterYourFirstName;

  /// Last name hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterYourLastName;

  /// Confirm password hint text
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterPassword;

  /// Welcome message on login page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Classio'**
  String get welcomeToClassio;

  /// Join message on registration page
  ///
  /// In en, this message translates to:
  /// **'Join Classio'**
  String get joinClassio;

  /// Subtitle on registration page
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get createAccountToGetStarted;

  /// Dismiss button text
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Reset password dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset password instructions
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordInstructions;

  /// Send reset link button text
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Success message after sending reset link
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your email inbox.'**
  String get passwordResetLinkSent;

  /// Error message when reset link fails to send
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link. Please try again.'**
  String get failedToSendResetLink;

  /// Message when user lacks permission
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this page.'**
  String get noPermissionToAccessPage;

  /// Message when user is not assigned to a school
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to any school.'**
  String get notAssignedToSchool;

  /// Generate invite button label
  ///
  /// In en, this message translates to:
  /// **'Generate Invite'**
  String get generateInvite;

  /// Create class button label
  ///
  /// In en, this message translates to:
  /// **'Create Class'**
  String get createClass;

  /// Overview tab label
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Schedule tab label
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Parents tab label
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get parents;

  /// Staff tab label
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// Invites tab label
  ///
  /// In en, this message translates to:
  /// **'Invites'**
  String get invites;

  /// Previous week label for week selector
  ///
  /// In en, this message translates to:
  /// **'Previous Week'**
  String get scheduleWeekPrevious;

  /// Current week label for week selector
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get scheduleWeekCurrent;

  /// Next week label for week selector
  ///
  /// In en, this message translates to:
  /// **'Next Week'**
  String get scheduleWeekNext;

  /// Week after next label for week selector
  ///
  /// In en, this message translates to:
  /// **'Week After'**
  String get scheduleWeekAfterNext;

  /// Stable timetable label for week selector
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get scheduleWeekStable;

  /// Label indicating a lesson was modified from stable
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get scheduleLessonModified;

  /// Time label for lesson detail
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get scheduleLessonTime;

  /// Room label for lesson detail
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get scheduleLessonRoom;

  /// Date label for lesson detail
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get scheduleLessonDate;

  /// Substitute teacher label for lesson detail
  ///
  /// In en, this message translates to:
  /// **'Substitute Teacher'**
  String get scheduleLessonSubstitute;

  /// Note label for lesson detail
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get scheduleLessonNote;

  /// Section header for changes from stable
  ///
  /// In en, this message translates to:
  /// **'Changes from Stable Timetable'**
  String get scheduleLessonChangesFromStable;

  /// Description for stable lesson indicator
  ///
  /// In en, this message translates to:
  /// **'This is a stable lesson that repeats every week'**
  String get scheduleLessonStableDescription;

  /// Subject label for changes
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get scheduleLessonSubject;

  /// Start time label for changes
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get scheduleLessonStartTime;

  /// End time label for changes
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get scheduleLessonEndTime;

  /// Teacher label for changes
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get scheduleLessonTeacher;

  /// Cancelled status for lesson
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get scheduleLessonCancelled;

  /// Substitution status for lesson
  ///
  /// In en, this message translates to:
  /// **'Substitution'**
  String get scheduleLessonSubstitution;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'cs',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pl',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
