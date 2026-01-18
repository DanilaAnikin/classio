// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Classio';

  @override
  String get welcomeMessage => 'Witamy w Classio';

  @override
  String get settings => 'Ustawienia';

  @override
  String get language => 'Jezyk';

  @override
  String get theme => 'Motyw';

  @override
  String get cleanTheme => 'Czysty';

  @override
  String get playfulTheme => 'Zabawny';

  @override
  String get home => 'Strona glowna';

  @override
  String get dashboard => 'Panel';

  @override
  String get selectLanguage => 'Wybierz jezyk';

  @override
  String get selectTheme => 'Wybierz motyw';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get login => 'Zaloguj sie';

  @override
  String get logout => 'Wyloguj sie';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Haslo';

  @override
  String get welcomeBack => 'Witaj ponownie';

  @override
  String get signInToContinue => 'Zaloguj sie, aby kontynuowac';

  @override
  String get forgotPassword => 'Zapomniales hasla?';

  @override
  String get loginError =>
      'Logowanie nie powiodlo sie. Sprawdz swoje dane logowania.';

  @override
  String get emailRequired => 'E-mail jest wymagany';

  @override
  String get emailInvalid => 'Prosze wprowadzic prawidlowy e-mail';

  @override
  String get passwordRequired => 'Haslo jest wymagane';

  @override
  String get passwordTooShort => 'Haslo musi miec co najmniej 6 znakow';

  @override
  String get loggingIn => 'Logowanie...';

  @override
  String get dashboardGreetingMorning => 'Dzien dobry';

  @override
  String get dashboardGreetingAfternoon => 'Dzien dobry';

  @override
  String get dashboardGreetingEvening => 'Dobry wieczor';

  @override
  String get dashboardUpNext => 'Nastepne';

  @override
  String get dashboardTodaySchedule => 'Dzisiejszy plan';

  @override
  String get dashboardDueSoon => 'Wkrotce do oddania';

  @override
  String get lessonCancelled => 'Odwolana';

  @override
  String get lessonSubstitution => 'Zastepstwo';

  @override
  String get lessonInProgress => 'W trakcie';

  @override
  String lessonUpcoming(int minutes) {
    return 'Zaczyna sie za $minutes min';
  }

  @override
  String lessonRoom(String room) {
    return 'Sala $room';
  }

  @override
  String get assignmentDueToday => 'Termin dzisiaj';

  @override
  String get assignmentDueTomorrow => 'Termin jutro';

  @override
  String assignmentDueIn(int days) {
    return 'Termin za $days dni';
  }

  @override
  String get assignmentCompleted => 'Ukonczone';

  @override
  String get assignmentOverdue => 'Po terminie';

  @override
  String get noLessonsToday => 'Dzis brak lekcji';

  @override
  String get noUpcomingAssignments => 'Brak nadchodzacych zadan';

  @override
  String get allDoneForToday => 'Wszystko zrobione na dzis!';

  @override
  String get freeTime => 'Czas wolny';

  @override
  String get dashboardLoading => 'Ladowanie panelu...';

  @override
  String get dashboardError => 'Cos poszlo nie tak';

  @override
  String get dashboardRetry => 'Ponow probe';

  @override
  String get navHome => 'Glowna';

  @override
  String get navSchedule => 'Plan';

  @override
  String get navGrades => 'Oceny';

  @override
  String get navProfile => 'Profil';

  @override
  String get scheduleTitle => 'Plan tygodniowy';

  @override
  String get scheduleMonday => 'Pn';

  @override
  String get scheduleTuesday => 'Wt';

  @override
  String get scheduleWednesday => 'Sr';

  @override
  String get scheduleThursday => 'Cz';

  @override
  String get scheduleFriday => 'Pt';

  @override
  String get scheduleSaturday => 'Sb';

  @override
  String get scheduleSunday => 'Nd';

  @override
  String get scheduleMondayFull => 'Poniedzialek';

  @override
  String get scheduleTuesdayFull => 'Wtorek';

  @override
  String get scheduleWednesdayFull => 'Sroda';

  @override
  String get scheduleThursdayFull => 'Czwartek';

  @override
  String get scheduleFridayFull => 'Piatek';

  @override
  String get scheduleNoLessons => 'Brak lekcji';

  @override
  String get scheduleBreak => 'Przerwa';

  @override
  String get gradesTitle => 'Oceny';

  @override
  String get gradesComingSoon => 'Oceny wkrotce';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileThemeSection => 'Wyglad';

  @override
  String get profileLanguageSection => 'Jezyk';

  @override
  String get profileLogout => 'Wyloguj sie';

  @override
  String get profileLogoutConfirm => 'Czy na pewno chcesz sie wylogowac?';

  @override
  String get gradesAverage => 'Srednia';

  @override
  String get gradesWeight => 'Waga';

  @override
  String get gradesDate => 'Data';

  @override
  String get gradesOverallAverage => 'Srednia ogolna';

  @override
  String get gradesNoGrades => 'Brak ocen';

  @override
  String gradesWeightFormat(String weight) {
    return 'Waga $weight';
  }

  @override
  String get subjectDetailStream => 'Tablica';

  @override
  String get subjectDetailStreamDescription => 'Ogloszenia i aktualnosci klasy';

  @override
  String get subjectDetailAssignments => 'Zadania';

  @override
  String get subjectDetailAssignmentsDescription =>
      'Twoje zadania i prace domowe';

  @override
  String get subjectDetailMaterials => 'Materialy';

  @override
  String get subjectDetailMaterialsDescription => 'Zasoby i pliki kursu';

  @override
  String get subjectDetailAnnouncement => 'Ogloszenie';

  @override
  String get subjectDetailAssignment => 'Zadanie';

  @override
  String get subjectDetailSubmit => 'Przeslij';

  @override
  String get subjectDetailSubmitted => 'Zadanie przeslane!';

  @override
  String get subjectDetailNoStream => 'Brak ogloszen';

  @override
  String get subjectDetailNoAssignments => 'Brak zadan';

  @override
  String get subjectDetailNoMaterials => 'Brak materialow';

  @override
  String subjectDetailDueDate(String date) {
    return 'Termin $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Dodane przez $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Zobacz material';

  @override
  String get dashboardInProgress => 'W trakcie';

  @override
  String get dashboardUpNextLabel => 'Nastepne';

  @override
  String get dashboardStarted => 'Rozpoczete';

  @override
  String get dashboardStartingNow => 'Zaczyna sie teraz';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'za ${hours}h ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'za ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Odwolana';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Zastepstwo: $teacher';
  }

  @override
  String get dashboardAllDone => 'Wszystko zrobione na dzis!';

  @override
  String get dashboardNoMoreLessons => 'Brak wiecej zaplanowanych lekcji';

  @override
  String get dashboardNoClassesToday => 'Dzis brak zajec';

  @override
  String get dashboardEnjoyFreeDay => 'Ciesz sie wolnym dniem!';

  @override
  String get dashboardSub => 'ZAST';

  @override
  String get dashboardToday => 'Dzis';

  @override
  String get dashboardTomorrow => 'Jutro';

  @override
  String get dashboardLater => 'Pozniej';

  @override
  String get dashboardAllCaughtUp => 'Wszystko zrobione!';

  @override
  String get dashboardNoAssignmentsDue => 'Brak zadan do oddania wkrotce';

  @override
  String get dashboardSomethingWrong => 'Cos poszlo nie tak';

  @override
  String get dashboardStudent => 'Uczen';

  @override
  String get dashboardAnError => 'Wystapil blad';

  @override
  String get dashboardNoData => 'Brak dostepnych danych';

  @override
  String scheduleLessonCount(int count) {
    return '$count lekcja';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count lekcji';
  }

  @override
  String get scheduleWeekend => 'Weekend!';

  @override
  String get scheduleEnjoyTimeOff => 'Ciesz sie wolnym czasem!';

  @override
  String get scheduleFreeDay => 'Masz wolny dzien. Czas na odpoczynek!';

  @override
  String get scheduleUnknown => 'Nieznane';

  @override
  String get gradesNoGradesYet => 'Brak ocen';

  @override
  String get gradesWillAppear =>
      'Twoje oceny pojawia sie tutaj, gdy beda dostepne.';

  @override
  String get gradesFailedToLoad => 'Nie udalo sie zaladowac ocen';

  @override
  String get gradesRetry => 'Ponow probe';

  @override
  String get gradesExcellent => 'Celujacy';

  @override
  String get gradesGood => 'Dobry';

  @override
  String get gradesFair => 'Dostateczny';

  @override
  String get gradesNeedsWork => 'Do poprawy';

  @override
  String gradesWeightLabel(String weight) {
    return 'Waga $weight';
  }

  @override
  String get subjectStream => 'Tablica';

  @override
  String get subjectAssignments => 'Zadania';

  @override
  String get subjectMaterials => 'Materialy';

  @override
  String get subjectNoPostsYet => 'Brak postow';

  @override
  String get subjectPostsWillAppear =>
      'Posty pojawia sie tutaj, gdy nauczyciel udostepni aktualizacje';

  @override
  String subjectTodayAt(String time) {
    return 'Dzis o $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Wczoraj o $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day o $time';
  }

  @override
  String get subjectNoAssignments => 'Brak zadan';

  @override
  String get subjectAssignmentsWillAppear =>
      'Zadania pojawia sie tutaj, gdy nauczyciel je opublikuje';

  @override
  String get subjectDueToday => 'Termin dzis';

  @override
  String get subjectDueTomorrow => 'Termin jutro';

  @override
  String subjectDueDate(String date) {
    return 'Termin $date';
  }

  @override
  String get subjectSubmitted => 'Zadanie przeslane!';

  @override
  String get subjectSubmit => 'Przeslij';

  @override
  String get subjectNoMaterials => 'Brak materialow';

  @override
  String get subjectMaterialsWillAppear =>
      'Materialy kursu pojawia sie tutaj, gdy nauczyciel je udostepni';

  @override
  String subjectOpening(String url) {
    return 'Otwieranie: $url';
  }

  @override
  String get subjectFailedToLoad => 'Nie udalo sie zaladowac przedmiotu';

  @override
  String get accessDenied => 'Odmowa dostepu';

  @override
  String get noSchoolAssigned => 'Nie przypisano szkoly';

  @override
  String get schoolAdmin => 'Administracja szkolna';

  @override
  String get users => 'Uzytkownicy';

  @override
  String get classes => 'Klasy';

  @override
  String get subjects => 'Przedmioty';

  @override
  String get inviteCodes => 'Kody zaproszenia';

  @override
  String get schoolDetails => 'Szczegoly szkoly';

  @override
  String get principalDashboard => 'Panel dyrektora';

  @override
  String get deputyDashboard => 'Panel wicedyrektora';

  @override
  String get deputyPanel => 'Panel wicedyrektora';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Haslo';

  @override
  String get inviteCodeLabel => 'Kod zaproszenia';

  @override
  String get signIn => 'Zaloguj sie';

  @override
  String get signUp => 'Zarejestruj sie';

  @override
  String get register => 'Zarejestruj';

  @override
  String get registerWithInviteCode => 'Zarejestruj sie z kodem zaproszenia';

  @override
  String get dontHaveAccount => 'Nie masz konta?';

  @override
  String get alreadyHaveAccount => 'Masz juz konto?';

  @override
  String get iDontHaveAccount => 'Nie mam konta';

  @override
  String get inviteCodeRequiredError => 'Prosze wprowadzic kod zaproszenia';

  @override
  String get inviteCodeTooShort =>
      'Kod zaproszenia musi miec co najmniej 6 znakow';

  @override
  String get firstNameLabel => 'Imie';

  @override
  String get lastNameLabel => 'Nazwisko';

  @override
  String get confirmPasswordLabel => 'Potwierdz haslo';

  @override
  String get pleaseConfirmPassword => 'Prosze potwierdzic haslo';

  @override
  String get passwordsDoNotMatch => 'Hasla nie pasuja do siebie';

  @override
  String get firstNameRequired => 'Prosze wprowadzic imie';

  @override
  String get firstNameTooShort => 'Imie musi miec co najmniej 2 znaki';

  @override
  String get lastNameRequired => 'Prosze wprowadzic nazwisko';

  @override
  String get lastNameTooShort => 'Nazwisko musi miec co najmniej 2 znaki';

  @override
  String get enterYourEmail => 'Wprowadz swoj e-mail';

  @override
  String get enterYourPassword => 'Wprowadz haslo';

  @override
  String get enterYourInviteCode => 'Wprowadz kod zaproszenia';

  @override
  String get enterYourFirstName => 'Wprowadz swoje imie';

  @override
  String get enterYourLastName => 'Wprowadz swoje nazwisko';

  @override
  String get reEnterPassword => 'Wprowadz ponownie haslo';

  @override
  String get welcomeToClassio => 'Witamy w Classio';

  @override
  String get joinClassio => 'Dolacz do Classio';

  @override
  String get createAccountToGetStarted => 'Utworz konto, aby rozpoczac';

  @override
  String get dismiss => 'Zamknij';

  @override
  String get resetPassword => 'Zresetuj haslo';

  @override
  String get resetPasswordInstructions =>
      'Wprowadz swoj adres e-mail, a wysliemy ci link do zresetowania hasla.';

  @override
  String get sendResetLink => 'Wyslij link';

  @override
  String get passwordResetLinkSent => 'Link wyslany! Sprawdz swoja skrzynke.';

  @override
  String get failedToSendResetLink =>
      'Nie udalo sie wyslac linku. Sprobuj ponownie.';

  @override
  String get noPermissionToAccessPage =>
      'Nie masz uprawnien do dostepu do tej strony.';

  @override
  String get notAssignedToSchool => 'Nie jestes przypisany do zadnej szkoly.';

  @override
  String get generateInvite => 'Wygeneruj zaproszenie';

  @override
  String get createClass => 'Utworz klase';

  @override
  String get overview => 'Przeglad';

  @override
  String get schedule => 'Plan';

  @override
  String get parents => 'Rodzice';

  @override
  String get staff => 'Personel';

  @override
  String get invites => 'Zaproszenia';

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
