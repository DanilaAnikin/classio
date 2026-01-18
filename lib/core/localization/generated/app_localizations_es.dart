// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Classio';

  @override
  String get welcomeMessage => 'Bienvenido a Classio';

  @override
  String get settings => 'Configuracion';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get cleanTheme => 'Limpio';

  @override
  String get playfulTheme => 'Divertido';

  @override
  String get home => 'Inicio';

  @override
  String get dashboard => 'Panel de control';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get selectTheme => 'Seleccionar tema';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get login => 'Iniciar sesion';

  @override
  String get logout => 'Cerrar sesion';

  @override
  String get email => 'Correo electronico';

  @override
  String get password => 'Contrasena';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get signInToContinue => 'Inicia sesion para continuar';

  @override
  String get forgotPassword => 'Olvidaste tu contrasena?';

  @override
  String get loginError =>
      'Error al iniciar sesion. Por favor verifica tus credenciales.';

  @override
  String get emailRequired => 'El correo electronico es obligatorio';

  @override
  String get emailInvalid => 'Por favor ingresa un correo electronico valido';

  @override
  String get passwordRequired => 'La contrasena es obligatoria';

  @override
  String get passwordTooShort =>
      'La contrasena debe tener al menos 6 caracteres';

  @override
  String get loggingIn => 'Iniciando sesion...';

  @override
  String get dashboardGreetingMorning => 'Buenos dias';

  @override
  String get dashboardGreetingAfternoon => 'Buenas tardes';

  @override
  String get dashboardGreetingEvening => 'Buenas noches';

  @override
  String get dashboardUpNext => 'A continuacion';

  @override
  String get dashboardTodaySchedule => 'Horario de hoy';

  @override
  String get dashboardDueSoon => 'Proximas entregas';

  @override
  String get lessonCancelled => 'Cancelada';

  @override
  String get lessonSubstitution => 'Sustitucion';

  @override
  String get lessonInProgress => 'En curso';

  @override
  String lessonUpcoming(int minutes) {
    return 'Comienza en $minutes min';
  }

  @override
  String lessonRoom(String room) {
    return 'Aula $room';
  }

  @override
  String get assignmentDueToday => 'Entrega hoy';

  @override
  String get assignmentDueTomorrow => 'Entrega manana';

  @override
  String assignmentDueIn(int days) {
    return 'Entrega en $days dias';
  }

  @override
  String get assignmentCompleted => 'Completada';

  @override
  String get assignmentOverdue => 'Atrasada';

  @override
  String get noLessonsToday => 'No hay clases hoy';

  @override
  String get noUpcomingAssignments => 'No hay tareas pendientes';

  @override
  String get allDoneForToday => 'Todo listo por hoy!';

  @override
  String get freeTime => 'Tiempo libre';

  @override
  String get dashboardLoading => 'Cargando tu panel...';

  @override
  String get dashboardError => 'Algo salio mal';

  @override
  String get dashboardRetry => 'Reintentar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSchedule => 'Horario';

  @override
  String get navGrades => 'Calificaciones';

  @override
  String get navProfile => 'Perfil';

  @override
  String get scheduleTitle => 'Horario semanal';

  @override
  String get scheduleMonday => 'Lun';

  @override
  String get scheduleTuesday => 'Mar';

  @override
  String get scheduleWednesday => 'Mie';

  @override
  String get scheduleThursday => 'Jue';

  @override
  String get scheduleFriday => 'Vie';

  @override
  String get scheduleSaturday => 'Sab';

  @override
  String get scheduleSunday => 'Dom';

  @override
  String get scheduleMondayFull => 'Lunes';

  @override
  String get scheduleTuesdayFull => 'Martes';

  @override
  String get scheduleWednesdayFull => 'Miercoles';

  @override
  String get scheduleThursdayFull => 'Jueves';

  @override
  String get scheduleFridayFull => 'Viernes';

  @override
  String get scheduleNoLessons => 'Sin clases programadas';

  @override
  String get scheduleBreak => 'Descanso';

  @override
  String get gradesTitle => 'Calificaciones';

  @override
  String get gradesComingSoon => 'Calificaciones proximamente';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileThemeSection => 'Apariencia';

  @override
  String get profileLanguageSection => 'Idioma';

  @override
  String get profileLogout => 'Cerrar sesion';

  @override
  String get profileLogoutConfirm =>
      'Estas seguro de que quieres cerrar sesion?';

  @override
  String get gradesAverage => 'Promedio';

  @override
  String get gradesWeight => 'Peso';

  @override
  String get gradesDate => 'Fecha';

  @override
  String get gradesOverallAverage => 'Promedio general';

  @override
  String get gradesNoGrades => 'Sin calificaciones';

  @override
  String gradesWeightFormat(String weight) {
    return 'Peso $weight';
  }

  @override
  String get subjectDetailStream => 'Novedades';

  @override
  String get subjectDetailStreamDescription =>
      'Anuncios y actualizaciones de la clase';

  @override
  String get subjectDetailAssignments => 'Tareas';

  @override
  String get subjectDetailAssignmentsDescription => 'Tus tareas y deberes';

  @override
  String get subjectDetailMaterials => 'Materiales';

  @override
  String get subjectDetailMaterialsDescription =>
      'Recursos y archivos del curso';

  @override
  String get subjectDetailAnnouncement => 'Anuncio';

  @override
  String get subjectDetailAssignment => 'Tarea';

  @override
  String get subjectDetailSubmit => 'Entregar';

  @override
  String get subjectDetailSubmitted => 'Tarea entregada!';

  @override
  String get subjectDetailNoStream => 'Sin anuncios todavia';

  @override
  String get subjectDetailNoAssignments => 'Sin tareas todavia';

  @override
  String get subjectDetailNoMaterials => 'Sin materiales todavia';

  @override
  String subjectDetailDueDate(String date) {
    return 'Fecha limite $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Publicado por $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Ver material';

  @override
  String get dashboardInProgress => 'En curso';

  @override
  String get dashboardUpNextLabel => 'A continuacion';

  @override
  String get dashboardStarted => 'Iniciada';

  @override
  String get dashboardStartingNow => 'Comenzando ahora';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'en ${hours}h ${minutes}m';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'en ${minutes}m';
  }

  @override
  String get dashboardCancelled => 'Cancelada';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Sustitucion: $teacher';
  }

  @override
  String get dashboardAllDone => 'Todo listo por hoy!';

  @override
  String get dashboardNoMoreLessons => 'No hay mas clases programadas';

  @override
  String get dashboardNoClassesToday => 'No hay clases hoy';

  @override
  String get dashboardEnjoyFreeDay => 'Disfruta tu dia libre!';

  @override
  String get dashboardSub => 'SUST';

  @override
  String get dashboardToday => 'Hoy';

  @override
  String get dashboardTomorrow => 'Manana';

  @override
  String get dashboardLater => 'Mas tarde';

  @override
  String get dashboardAllCaughtUp => 'Todo al dia!';

  @override
  String get dashboardNoAssignmentsDue => 'Sin tareas proximas';

  @override
  String get dashboardSomethingWrong => 'Algo salio mal';

  @override
  String get dashboardStudent => 'Estudiante';

  @override
  String get dashboardAnError => 'Ocurrio un error';

  @override
  String get dashboardNoData => 'Sin datos disponibles';

  @override
  String scheduleLessonCount(int count) {
    return '$count clase';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count clases';
  }

  @override
  String get scheduleWeekend => 'Fin de semana!';

  @override
  String get scheduleEnjoyTimeOff => 'Disfruta tu tiempo libre!';

  @override
  String get scheduleFreeDay => 'Tienes un dia libre. Hora de relajarse!';

  @override
  String get scheduleUnknown => 'Desconocido';

  @override
  String get gradesNoGradesYet => 'Sin calificaciones todavia';

  @override
  String get gradesWillAppear =>
      'Tus calificaciones apareceran aqui cuando esten disponibles.';

  @override
  String get gradesFailedToLoad => 'Error al cargar calificaciones';

  @override
  String get gradesRetry => 'Reintentar';

  @override
  String get gradesExcellent => 'Excelente';

  @override
  String get gradesGood => 'Bueno';

  @override
  String get gradesFair => 'Regular';

  @override
  String get gradesNeedsWork => 'Necesita mejorar';

  @override
  String gradesWeightLabel(String weight) {
    return 'Peso $weight';
  }

  @override
  String get subjectStream => 'Novedades';

  @override
  String get subjectAssignments => 'Tareas';

  @override
  String get subjectMaterials => 'Materiales';

  @override
  String get subjectNoPostsYet => 'Sin publicaciones todavia';

  @override
  String get subjectPostsWillAppear =>
      'Las publicaciones apareceran aqui cuando tu profesor comparta actualizaciones';

  @override
  String subjectTodayAt(String time) {
    return 'Hoy a las $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Ayer a las $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day a las $time';
  }

  @override
  String get subjectNoAssignments => 'Sin tareas';

  @override
  String get subjectAssignmentsWillAppear =>
      'Las tareas apareceran aqui cuando tu profesor las publique';

  @override
  String get subjectDueToday => 'Entrega hoy';

  @override
  String get subjectDueTomorrow => 'Entrega manana';

  @override
  String subjectDueDate(String date) {
    return 'Fecha limite $date';
  }

  @override
  String get subjectSubmitted => 'Tarea entregada!';

  @override
  String get subjectSubmit => 'Entregar';

  @override
  String get subjectNoMaterials => 'Sin materiales';

  @override
  String get subjectMaterialsWillAppear =>
      'Los materiales del curso apareceran aqui cuando tu profesor los comparta';

  @override
  String subjectOpening(String url) {
    return 'Abriendo: $url';
  }

  @override
  String get subjectFailedToLoad => 'Error al cargar la materia';

  @override
  String get accessDenied => 'Acceso denegado';

  @override
  String get noSchoolAssigned => 'Sin escuela asignada';

  @override
  String get schoolAdmin => 'Administrador escolar';

  @override
  String get users => 'Usuarios';

  @override
  String get classes => 'Clases';

  @override
  String get subjects => 'Materias';

  @override
  String get inviteCodes => 'Codigos de invitacion';

  @override
  String get schoolDetails => 'Detalles de la escuela';

  @override
  String get principalDashboard => 'Panel del director';

  @override
  String get deputyDashboard => 'Panel del subdirector';

  @override
  String get deputyPanel => 'Panel del subdirector';

  @override
  String get emailLabel => 'Correo electronico';

  @override
  String get passwordLabel => 'Contrasena';

  @override
  String get inviteCodeLabel => 'Codigo de invitacion';

  @override
  String get signIn => 'Iniciar sesion';

  @override
  String get signUp => 'Registrarse';

  @override
  String get register => 'Registrar';

  @override
  String get registerWithInviteCode => 'Registrarse con codigo de invitacion';

  @override
  String get dontHaveAccount => 'No tienes cuenta?';

  @override
  String get alreadyHaveAccount => 'Ya tienes cuenta?';

  @override
  String get iDontHaveAccount => 'No tengo cuenta';

  @override
  String get inviteCodeRequiredError =>
      'Por favor ingresa tu codigo de invitacion';

  @override
  String get inviteCodeTooShort =>
      'El codigo de invitacion debe tener al menos 6 caracteres';

  @override
  String get firstNameLabel => 'Nombre';

  @override
  String get lastNameLabel => 'Apellido';

  @override
  String get confirmPasswordLabel => 'Confirmar contrasena';

  @override
  String get pleaseConfirmPassword => 'Por favor confirma tu contrasena';

  @override
  String get passwordsDoNotMatch => 'Las contrasenas no coinciden';

  @override
  String get firstNameRequired => 'Por favor ingresa tu nombre';

  @override
  String get firstNameTooShort => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get lastNameRequired => 'Por favor ingresa tu apellido';

  @override
  String get lastNameTooShort => 'El apellido debe tener al menos 2 caracteres';

  @override
  String get enterYourEmail => 'Ingresa tu correo electronico';

  @override
  String get enterYourPassword => 'Ingresa tu contrasena';

  @override
  String get enterYourInviteCode => 'Ingresa tu codigo de invitacion';

  @override
  String get enterYourFirstName => 'Ingresa tu nombre';

  @override
  String get enterYourLastName => 'Ingresa tu apellido';

  @override
  String get reEnterPassword => 'Vuelve a ingresar tu contrasena';

  @override
  String get welcomeToClassio => 'Bienvenido a Classio';

  @override
  String get joinClassio => 'Unete a Classio';

  @override
  String get createAccountToGetStarted => 'Crea tu cuenta para comenzar';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get resetPassword => 'Restablecer contrasena';

  @override
  String get resetPasswordInstructions =>
      'Ingresa tu correo electronico y te enviaremos un enlace para restablecer tu contrasena.';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get passwordResetLinkSent =>
      'Enlace enviado! Revisa tu bandeja de entrada.';

  @override
  String get failedToSendResetLink =>
      'Error al enviar el enlace. Por favor intenta de nuevo.';

  @override
  String get noPermissionToAccessPage =>
      'No tienes permiso para acceder a esta pagina.';

  @override
  String get notAssignedToSchool => 'No estas asignado a ninguna escuela.';

  @override
  String get generateInvite => 'Generar invitacion';

  @override
  String get createClass => 'Crear clase';

  @override
  String get overview => 'Resumen';

  @override
  String get schedule => 'Horario';

  @override
  String get parents => 'Padres';

  @override
  String get staff => 'Personal';

  @override
  String get invites => 'Invitaciones';

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
