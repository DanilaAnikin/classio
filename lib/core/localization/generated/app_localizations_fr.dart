// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Classio';

  @override
  String get welcomeMessage => 'Bienvenue sur Classio';

  @override
  String get settings => 'Parametres';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Theme';

  @override
  String get cleanTheme => 'Epure';

  @override
  String get playfulTheme => 'Ludique';

  @override
  String get home => 'Accueil';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get selectLanguage => 'Selectionner la langue';

  @override
  String get selectTheme => 'Selectionner le theme';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get login => 'Connexion';

  @override
  String get logout => 'Deconnexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInToContinue => 'Connectez-vous pour continuer';

  @override
  String get forgotPassword => 'Mot de passe oublie?';

  @override
  String get loginError =>
      'Echec de la connexion. Veuillez verifier vos identifiants.';

  @override
  String get emailRequired => 'L\'e-mail est requis';

  @override
  String get emailInvalid => 'Veuillez entrer un e-mail valide';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caracteres';

  @override
  String get loggingIn => 'Connexion en cours...';

  @override
  String get dashboardGreetingMorning => 'Bonjour';

  @override
  String get dashboardGreetingAfternoon => 'Bon apres-midi';

  @override
  String get dashboardGreetingEvening => 'Bonsoir';

  @override
  String get dashboardUpNext => 'A suivre';

  @override
  String get dashboardTodaySchedule => 'Emploi du temps du jour';

  @override
  String get dashboardDueSoon => 'A rendre bientot';

  @override
  String get lessonCancelled => 'Annule';

  @override
  String get lessonSubstitution => 'Remplacement';

  @override
  String get lessonInProgress => 'En cours';

  @override
  String lessonUpcoming(int minutes) {
    return 'Commence dans $minutes min';
  }

  @override
  String lessonRoom(String room) {
    return 'Salle $room';
  }

  @override
  String get assignmentDueToday => 'A rendre aujourd\'hui';

  @override
  String get assignmentDueTomorrow => 'A rendre demain';

  @override
  String assignmentDueIn(int days) {
    return 'A rendre dans $days jours';
  }

  @override
  String get assignmentCompleted => 'Termine';

  @override
  String get assignmentOverdue => 'En retard';

  @override
  String get noLessonsToday => 'Pas de cours aujourd\'hui';

  @override
  String get noUpcomingAssignments => 'Pas de devoirs a venir';

  @override
  String get allDoneForToday => 'Tout est fait pour aujourd\'hui!';

  @override
  String get freeTime => 'Temps libre';

  @override
  String get dashboardLoading => 'Chargement du tableau de bord...';

  @override
  String get dashboardError => 'Une erreur s\'est produite';

  @override
  String get dashboardRetry => 'Reessayer';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSchedule => 'Emploi du temps';

  @override
  String get navGrades => 'Notes';

  @override
  String get navProfile => 'Profil';

  @override
  String get scheduleTitle => 'Emploi du temps hebdomadaire';

  @override
  String get scheduleMonday => 'Lun';

  @override
  String get scheduleTuesday => 'Mar';

  @override
  String get scheduleWednesday => 'Mer';

  @override
  String get scheduleThursday => 'Jeu';

  @override
  String get scheduleFriday => 'Ven';

  @override
  String get scheduleSaturday => 'Sam';

  @override
  String get scheduleSunday => 'Dim';

  @override
  String get scheduleMondayFull => 'Lundi';

  @override
  String get scheduleTuesdayFull => 'Mardi';

  @override
  String get scheduleWednesdayFull => 'Mercredi';

  @override
  String get scheduleThursdayFull => 'Jeudi';

  @override
  String get scheduleFridayFull => 'Vendredi';

  @override
  String get scheduleNoLessons => 'Pas de cours';

  @override
  String get scheduleBreak => 'Pause';

  @override
  String get gradesTitle => 'Notes';

  @override
  String get gradesComingSoon => 'Notes a venir';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileThemeSection => 'Apparence';

  @override
  String get profileLanguageSection => 'Langue';

  @override
  String get profileLogout => 'Se deconnecter';

  @override
  String get profileLogoutConfirm =>
      'Etes-vous sur de vouloir vous deconnecter?';

  @override
  String get gradesAverage => 'Moyenne';

  @override
  String get gradesWeight => 'Coefficient';

  @override
  String get gradesDate => 'Date';

  @override
  String get gradesOverallAverage => 'Moyenne generale';

  @override
  String get gradesNoGrades => 'Pas encore de notes';

  @override
  String gradesWeightFormat(String weight) {
    return 'Coefficient $weight';
  }

  @override
  String get subjectDetailStream => 'Actualites';

  @override
  String get subjectDetailStreamDescription =>
      'Annonces et mises a jour de la classe';

  @override
  String get subjectDetailAssignments => 'Devoirs';

  @override
  String get subjectDetailAssignmentsDescription => 'Vos travaux et devoirs';

  @override
  String get subjectDetailMaterials => 'Ressources';

  @override
  String get subjectDetailMaterialsDescription =>
      'Ressources et fichiers du cours';

  @override
  String get subjectDetailAnnouncement => 'Annonce';

  @override
  String get subjectDetailAssignment => 'Devoir';

  @override
  String get subjectDetailSubmit => 'Soumettre';

  @override
  String get subjectDetailSubmitted => 'Devoir soumis!';

  @override
  String get subjectDetailNoStream => 'Pas encore d\'annonces';

  @override
  String get subjectDetailNoAssignments => 'Pas encore de devoirs';

  @override
  String get subjectDetailNoMaterials => 'Pas encore de ressources';

  @override
  String subjectDetailDueDate(String date) {
    return 'A rendre le $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Publie par $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Voir la ressource';

  @override
  String get dashboardInProgress => 'En cours';

  @override
  String get dashboardUpNextLabel => 'A suivre';

  @override
  String get dashboardStarted => 'Commence';

  @override
  String get dashboardStartingNow => 'Commence maintenant';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'dans ${hours}h ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'dans ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Annule';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Remplacement: $teacher';
  }

  @override
  String get dashboardAllDone => 'Tout est fait pour aujourd\'hui!';

  @override
  String get dashboardNoMoreLessons => 'Plus de cours prevus';

  @override
  String get dashboardNoClassesToday => 'Pas de cours aujourd\'hui';

  @override
  String get dashboardEnjoyFreeDay => 'Profitez de votre jour libre!';

  @override
  String get dashboardSub => 'REMPL';

  @override
  String get dashboardToday => 'Aujourd\'hui';

  @override
  String get dashboardTomorrow => 'Demain';

  @override
  String get dashboardLater => 'Plus tard';

  @override
  String get dashboardAllCaughtUp => 'Tout est a jour!';

  @override
  String get dashboardNoAssignmentsDue => 'Pas de devoirs a rendre bientot';

  @override
  String get dashboardSomethingWrong => 'Une erreur s\'est produite';

  @override
  String get dashboardStudent => 'Eleve';

  @override
  String get dashboardAnError => 'Une erreur s\'est produite';

  @override
  String get dashboardNoData => 'Aucune donnee disponible';

  @override
  String scheduleLessonCount(int count) {
    return '$count cours';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count cours';
  }

  @override
  String get scheduleWeekend => 'Week-end!';

  @override
  String get scheduleEnjoyTimeOff => 'Profitez de votre temps libre!';

  @override
  String get scheduleFreeDay =>
      'Vous avez un jour libre. C\'est l\'heure de se detendre!';

  @override
  String get scheduleUnknown => 'Inconnu';

  @override
  String get gradesNoGradesYet => 'Pas encore de notes';

  @override
  String get gradesWillAppear =>
      'Vos notes apparaitront ici des qu\'elles seront disponibles.';

  @override
  String get gradesFailedToLoad => 'Echec du chargement des notes';

  @override
  String get gradesRetry => 'Reessayer';

  @override
  String get gradesExcellent => 'Excellent';

  @override
  String get gradesGood => 'Bien';

  @override
  String get gradesFair => 'Passable';

  @override
  String get gradesNeedsWork => 'A ameliorer';

  @override
  String gradesWeightLabel(String weight) {
    return 'Coefficient $weight';
  }

  @override
  String get subjectStream => 'Actualites';

  @override
  String get subjectAssignments => 'Devoirs';

  @override
  String get subjectMaterials => 'Ressources';

  @override
  String get subjectNoPostsYet => 'Pas encore de publications';

  @override
  String get subjectPostsWillAppear =>
      'Les publications apparaitront ici quand votre professeur partagera des mises a jour';

  @override
  String subjectTodayAt(String time) {
    return 'Aujourd\'hui a $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Hier a $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day a $time';
  }

  @override
  String get subjectNoAssignments => 'Pas de devoirs';

  @override
  String get subjectAssignmentsWillAppear =>
      'Les devoirs apparaitront ici quand votre professeur les publiera';

  @override
  String get subjectDueToday => 'A rendre aujourd\'hui';

  @override
  String get subjectDueTomorrow => 'A rendre demain';

  @override
  String subjectDueDate(String date) {
    return 'A rendre le $date';
  }

  @override
  String get subjectSubmitted => 'Devoir soumis!';

  @override
  String get subjectSubmit => 'Soumettre';

  @override
  String get subjectNoMaterials => 'Pas de ressources';

  @override
  String get subjectMaterialsWillAppear =>
      'Les ressources du cours apparaitront ici quand votre professeur les partagera';

  @override
  String subjectOpening(String url) {
    return 'Ouverture: $url';
  }

  @override
  String get subjectFailedToLoad => 'Echec du chargement de la matiere';

  @override
  String get accessDenied => 'Acces refuse';

  @override
  String get noSchoolAssigned => 'Aucune ecole assignee';

  @override
  String get schoolAdmin => 'Administration scolaire';

  @override
  String get users => 'Utilisateurs';

  @override
  String get classes => 'Classes';

  @override
  String get subjects => 'Matieres';

  @override
  String get inviteCodes => 'Codes d\'invitation';

  @override
  String get schoolDetails => 'Details de l\'ecole';

  @override
  String get principalDashboard => 'Tableau de bord du directeur';

  @override
  String get deputyDashboard => 'Tableau de bord du directeur adjoint';

  @override
  String get deputyPanel => 'Panneau du directeur adjoint';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get inviteCodeLabel => 'Code d\'invitation';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get register => 'S\'inscrire';

  @override
  String get registerWithInviteCode => 'S\'inscrire avec un code d\'invitation';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte?';

  @override
  String get alreadyHaveAccount => 'Vous avez deja un compte?';

  @override
  String get iDontHaveAccount => 'Je n\'ai pas de compte';

  @override
  String get inviteCodeRequiredError =>
      'Veuillez entrer votre code d\'invitation';

  @override
  String get inviteCodeTooShort =>
      'Le code d\'invitation doit contenir au moins 6 caracteres';

  @override
  String get firstNameLabel => 'Prenom';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get firstNameRequired => 'Veuillez entrer votre prenom';

  @override
  String get firstNameTooShort =>
      'Le prenom doit contenir au moins 2 caracteres';

  @override
  String get lastNameRequired => 'Veuillez entrer votre nom';

  @override
  String get lastNameTooShort => 'Le nom doit contenir au moins 2 caracteres';

  @override
  String get enterYourEmail => 'Entrez votre adresse e-mail';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get enterYourInviteCode => 'Entrez votre code d\'invitation';

  @override
  String get enterYourFirstName => 'Entrez votre prenom';

  @override
  String get enterYourLastName => 'Entrez votre nom';

  @override
  String get reEnterPassword => 'Ressaisissez votre mot de passe';

  @override
  String get welcomeToClassio => 'Bienvenue sur Classio';

  @override
  String get joinClassio => 'Rejoindre Classio';

  @override
  String get createAccountToGetStarted => 'Creez votre compte pour commencer';

  @override
  String get dismiss => 'Fermer';

  @override
  String get resetPassword => 'Reinitialiser le mot de passe';

  @override
  String get resetPasswordInstructions =>
      'Entrez votre adresse e-mail et nous vous enverrons un lien pour reinitialiser votre mot de passe.';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String get passwordResetLinkSent =>
      'Lien envoye! Verifiez votre boite de reception.';

  @override
  String get failedToSendResetLink =>
      'Echec de l\'envoi du lien. Veuillez reessayer.';

  @override
  String get noPermissionToAccessPage =>
      'Vous n\'avez pas la permission d\'acceder a cette page.';

  @override
  String get notAssignedToSchool => 'Vous n\'etes assigne a aucune ecole.';

  @override
  String get generateInvite => 'Generer une invitation';

  @override
  String get createClass => 'Creer une classe';

  @override
  String get overview => 'Apercu';

  @override
  String get schedule => 'Emploi du temps';

  @override
  String get parents => 'Parents';

  @override
  String get staff => 'Personnel';

  @override
  String get invites => 'Invitations';

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
