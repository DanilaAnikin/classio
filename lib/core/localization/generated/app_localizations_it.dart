// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Classio';

  @override
  String get welcomeMessage => 'Benvenuto su Classio';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get theme => 'Tema';

  @override
  String get cleanTheme => 'Pulito';

  @override
  String get playfulTheme => 'Giocoso';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Pannello di controllo';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get selectTheme => 'Seleziona tema';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get login => 'Accedi';

  @override
  String get logout => 'Esci';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get welcomeBack => 'Bentornato';

  @override
  String get signInToContinue => 'Accedi per continuare';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get loginError => 'Accesso fallito. Controlla le tue credenziali.';

  @override
  String get emailRequired => 'L\'email e richiesta';

  @override
  String get emailInvalid => 'Inserisci un\'email valida';

  @override
  String get passwordRequired => 'La password e richiesta';

  @override
  String get passwordTooShort =>
      'La password deve contenere almeno 6 caratteri';

  @override
  String get loggingIn => 'Accesso in corso...';

  @override
  String get dashboardGreetingMorning => 'Buongiorno';

  @override
  String get dashboardGreetingAfternoon => 'Buon pomeriggio';

  @override
  String get dashboardGreetingEvening => 'Buonasera';

  @override
  String get dashboardUpNext => 'A seguire';

  @override
  String get dashboardTodaySchedule => 'Orario di oggi';

  @override
  String get dashboardDueSoon => 'In scadenza';

  @override
  String get lessonCancelled => 'Annullata';

  @override
  String get lessonSubstitution => 'Supplenza';

  @override
  String get lessonInProgress => 'In corso';

  @override
  String lessonUpcoming(int minutes) {
    return 'Inizia tra $minutes min';
  }

  @override
  String lessonRoom(String room) {
    return 'Aula $room';
  }

  @override
  String get assignmentDueToday => 'Scadenza oggi';

  @override
  String get assignmentDueTomorrow => 'Scadenza domani';

  @override
  String assignmentDueIn(int days) {
    return 'Scadenza tra $days giorni';
  }

  @override
  String get assignmentCompleted => 'Completato';

  @override
  String get assignmentOverdue => 'In ritardo';

  @override
  String get noLessonsToday => 'Nessuna lezione oggi';

  @override
  String get noUpcomingAssignments => 'Nessun compito in arrivo';

  @override
  String get allDoneForToday => 'Tutto fatto per oggi!';

  @override
  String get freeTime => 'Tempo libero';

  @override
  String get dashboardLoading => 'Caricamento del pannello...';

  @override
  String get dashboardError => 'Qualcosa e andato storto';

  @override
  String get dashboardRetry => 'Riprova';

  @override
  String get navHome => 'Home';

  @override
  String get navSchedule => 'Orario';

  @override
  String get navGrades => 'Voti';

  @override
  String get navProfile => 'Profilo';

  @override
  String get scheduleTitle => 'Orario settimanale';

  @override
  String get scheduleMonday => 'Lun';

  @override
  String get scheduleTuesday => 'Mar';

  @override
  String get scheduleWednesday => 'Mer';

  @override
  String get scheduleThursday => 'Gio';

  @override
  String get scheduleFriday => 'Ven';

  @override
  String get scheduleSaturday => 'Sab';

  @override
  String get scheduleSunday => 'Dom';

  @override
  String get scheduleMondayFull => 'Lunedi';

  @override
  String get scheduleTuesdayFull => 'Martedi';

  @override
  String get scheduleWednesdayFull => 'Mercoledi';

  @override
  String get scheduleThursdayFull => 'Giovedi';

  @override
  String get scheduleFridayFull => 'Venerdi';

  @override
  String get scheduleNoLessons => 'Nessuna lezione';

  @override
  String get scheduleBreak => 'Pausa';

  @override
  String get gradesTitle => 'Voti';

  @override
  String get gradesComingSoon => 'Voti in arrivo';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get profileThemeSection => 'Aspetto';

  @override
  String get profileLanguageSection => 'Lingua';

  @override
  String get profileLogout => 'Esci';

  @override
  String get profileLogoutConfirm => 'Sei sicuro di voler uscire?';

  @override
  String get gradesAverage => 'Media';

  @override
  String get gradesWeight => 'Peso';

  @override
  String get gradesDate => 'Data';

  @override
  String get gradesOverallAverage => 'Media complessiva';

  @override
  String get gradesNoGrades => 'Nessun voto';

  @override
  String gradesWeightFormat(String weight) {
    return 'Peso $weight';
  }

  @override
  String get subjectDetailStream => 'Bacheca';

  @override
  String get subjectDetailStreamDescription =>
      'Annunci e aggiornamenti della classe';

  @override
  String get subjectDetailAssignments => 'Compiti';

  @override
  String get subjectDetailAssignmentsDescription => 'I tuoi compiti e lavori';

  @override
  String get subjectDetailMaterials => 'Materiali';

  @override
  String get subjectDetailMaterialsDescription => 'Risorse e file del corso';

  @override
  String get subjectDetailAnnouncement => 'Annuncio';

  @override
  String get subjectDetailAssignment => 'Compito';

  @override
  String get subjectDetailSubmit => 'Consegna';

  @override
  String get subjectDetailSubmitted => 'Compito consegnato!';

  @override
  String get subjectDetailNoStream => 'Nessun annuncio ancora';

  @override
  String get subjectDetailNoAssignments => 'Nessun compito ancora';

  @override
  String get subjectDetailNoMaterials => 'Nessun materiale ancora';

  @override
  String subjectDetailDueDate(String date) {
    return 'Scadenza $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Pubblicato da $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Visualizza materiale';

  @override
  String get dashboardInProgress => 'In corso';

  @override
  String get dashboardUpNextLabel => 'A seguire';

  @override
  String get dashboardStarted => 'Iniziata';

  @override
  String get dashboardStartingNow => 'Inizia ora';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'tra ${hours}h ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'tra ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Annullata';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Supplenza: $teacher';
  }

  @override
  String get dashboardAllDone => 'Tutto fatto per oggi!';

  @override
  String get dashboardNoMoreLessons => 'Nessuna altra lezione prevista';

  @override
  String get dashboardNoClassesToday => 'Nessuna lezione oggi';

  @override
  String get dashboardEnjoyFreeDay => 'Goditi il tuo giorno libero!';

  @override
  String get dashboardSub => 'SUPPL';

  @override
  String get dashboardToday => 'Oggi';

  @override
  String get dashboardTomorrow => 'Domani';

  @override
  String get dashboardLater => 'Piu tardi';

  @override
  String get dashboardAllCaughtUp => 'Tutto in ordine!';

  @override
  String get dashboardNoAssignmentsDue => 'Nessun compito in scadenza';

  @override
  String get dashboardSomethingWrong => 'Qualcosa e andato storto';

  @override
  String get dashboardStudent => 'Studente';

  @override
  String get dashboardAnError => 'Si e verificato un errore';

  @override
  String get dashboardNoData => 'Nessun dato disponibile';

  @override
  String scheduleLessonCount(int count) {
    return '$count lezione';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count lezioni';
  }

  @override
  String get scheduleWeekend => 'Fine settimana!';

  @override
  String get scheduleEnjoyTimeOff => 'Goditi il tempo libero!';

  @override
  String get scheduleFreeDay => 'Hai un giorno libero. E ora di rilassarsi!';

  @override
  String get scheduleUnknown => 'Sconosciuto';

  @override
  String get gradesNoGradesYet => 'Nessun voto ancora';

  @override
  String get gradesWillAppear =>
      'I tuoi voti appariranno qui quando saranno disponibili.';

  @override
  String get gradesFailedToLoad => 'Impossibile caricare i voti';

  @override
  String get gradesRetry => 'Riprova';

  @override
  String get gradesExcellent => 'Eccellente';

  @override
  String get gradesGood => 'Buono';

  @override
  String get gradesFair => 'Sufficiente';

  @override
  String get gradesNeedsWork => 'Da migliorare';

  @override
  String gradesWeightLabel(String weight) {
    return 'Peso $weight';
  }

  @override
  String get subjectStream => 'Bacheca';

  @override
  String get subjectAssignments => 'Compiti';

  @override
  String get subjectMaterials => 'Materiali';

  @override
  String get subjectNoPostsYet => 'Nessun post ancora';

  @override
  String get subjectPostsWillAppear =>
      'I post appariranno qui quando il tuo insegnante condividera aggiornamenti';

  @override
  String subjectTodayAt(String time) {
    return 'Oggi alle $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Ieri alle $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day alle $time';
  }

  @override
  String get subjectNoAssignments => 'Nessun compito';

  @override
  String get subjectAssignmentsWillAppear =>
      'I compiti appariranno qui quando il tuo insegnante li pubblichera';

  @override
  String get subjectDueToday => 'Scadenza oggi';

  @override
  String get subjectDueTomorrow => 'Scadenza domani';

  @override
  String subjectDueDate(String date) {
    return 'Scadenza $date';
  }

  @override
  String get subjectSubmitted => 'Compito consegnato!';

  @override
  String get subjectSubmit => 'Consegna';

  @override
  String get subjectNoMaterials => 'Nessun materiale';

  @override
  String get subjectMaterialsWillAppear =>
      'I materiali del corso appariranno qui quando il tuo insegnante li condividera';

  @override
  String subjectOpening(String url) {
    return 'Apertura: $url';
  }

  @override
  String get subjectFailedToLoad => 'Impossibile caricare la materia';

  @override
  String get accessDenied => 'Accesso negato';

  @override
  String get noSchoolAssigned => 'Nessuna scuola assegnata';

  @override
  String get schoolAdmin => 'Amministrazione scolastica';

  @override
  String get users => 'Utenti';

  @override
  String get classes => 'Classi';

  @override
  String get subjects => 'Materie';

  @override
  String get inviteCodes => 'Codici di invito';

  @override
  String get schoolDetails => 'Dettagli della scuola';

  @override
  String get principalDashboard => 'Pannello del preside';

  @override
  String get deputyDashboard => 'Pannello del vice preside';

  @override
  String get deputyPanel => 'Pannello del vice preside';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get inviteCodeLabel => 'Codice di invito';

  @override
  String get signIn => 'Accedi';

  @override
  String get signUp => 'Registrati';

  @override
  String get register => 'Registrati';

  @override
  String get registerWithInviteCode => 'Registrati con codice di invito';

  @override
  String get dontHaveAccount => 'Non hai un account?';

  @override
  String get alreadyHaveAccount => 'Hai gia un account?';

  @override
  String get iDontHaveAccount => 'Non ho un account';

  @override
  String get inviteCodeRequiredError => 'Inserisci il tuo codice di invito';

  @override
  String get inviteCodeTooShort =>
      'Il codice di invito deve avere almeno 6 caratteri';

  @override
  String get firstNameLabel => 'Nome';

  @override
  String get lastNameLabel => 'Cognome';

  @override
  String get confirmPasswordLabel => 'Conferma password';

  @override
  String get pleaseConfirmPassword => 'Conferma la tua password';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get firstNameRequired => 'Inserisci il tuo nome';

  @override
  String get firstNameTooShort => 'Il nome deve avere almeno 2 caratteri';

  @override
  String get lastNameRequired => 'Inserisci il tuo cognome';

  @override
  String get lastNameTooShort => 'Il cognome deve avere almeno 2 caratteri';

  @override
  String get enterYourEmail => 'Inserisci la tua email';

  @override
  String get enterYourPassword => 'Inserisci la tua password';

  @override
  String get enterYourInviteCode => 'Inserisci il tuo codice di invito';

  @override
  String get enterYourFirstName => 'Inserisci il tuo nome';

  @override
  String get enterYourLastName => 'Inserisci il tuo cognome';

  @override
  String get reEnterPassword => 'Reinserisci la password';

  @override
  String get welcomeToClassio => 'Benvenuto su Classio';

  @override
  String get joinClassio => 'Unisciti a Classio';

  @override
  String get createAccountToGetStarted => 'Crea il tuo account per iniziare';

  @override
  String get dismiss => 'Chiudi';

  @override
  String get resetPassword => 'Reimposta password';

  @override
  String get resetPasswordInstructions =>
      'Inserisci il tuo indirizzo email e ti invieremo un link per reimpostare la password.';

  @override
  String get sendResetLink => 'Invia link';

  @override
  String get passwordResetLinkSent =>
      'Link inviato! Controlla la tua casella di posta.';

  @override
  String get failedToSendResetLink => 'Impossibile inviare il link. Riprova.';

  @override
  String get noPermissionToAccessPage =>
      'Non hai il permesso di accedere a questa pagina.';

  @override
  String get notAssignedToSchool => 'Non sei assegnato a nessuna scuola.';

  @override
  String get generateInvite => 'Genera invito';

  @override
  String get createClass => 'Crea classe';

  @override
  String get overview => 'Panoramica';

  @override
  String get schedule => 'Orario';

  @override
  String get parents => 'Genitori';

  @override
  String get staff => 'Personale';

  @override
  String get invites => 'Inviti';

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
