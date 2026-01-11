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
  String get welcomeMessage => 'Добро пожаловать в Classio';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get cleanTheme => 'Чистая';

  @override
  String get playfulTheme => 'Игривая';

  @override
  String get home => 'Главная';

  @override
  String get dashboard => 'Панель управления';

  @override
  String get selectLanguage => 'Выбрать язык';

  @override
  String get selectTheme => 'Выбрать тему';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get login => 'Вход';

  @override
  String get logout => 'Выход';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInToContinue => 'Войдите, чтобы продолжить';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get loginError => 'Ошибка входа. Проверьте свои данные.';

  @override
  String get emailRequired => 'Электронная почта обязательна';

  @override
  String get emailInvalid => 'Введите правильный адрес электронной почты';

  @override
  String get passwordRequired => 'Пароль обязателен';

  @override
  String get passwordTooShort => 'Пароль должен содержать не менее 6 символов';

  @override
  String get loggingIn => 'Вход в систему...';

  @override
  String get dashboardGreetingMorning => 'Доброе утро';

  @override
  String get dashboardGreetingAfternoon => 'Добрый день';

  @override
  String get dashboardGreetingEvening => 'Добрый вечер';

  @override
  String get dashboardUpNext => 'Далее';

  @override
  String get dashboardTodaySchedule => 'Расписание на сегодня';

  @override
  String get dashboardDueSoon => 'Скоро срок сдачи';

  @override
  String get lessonCancelled => 'Отменено';

  @override
  String get lessonSubstitution => 'Замена';

  @override
  String get lessonInProgress => 'Идет сейчас';

  @override
  String lessonUpcoming(int minutes) {
    return 'Начало через $minutes мин';
  }

  @override
  String lessonRoom(String room) {
    return 'Кабинет $room';
  }

  @override
  String get assignmentDueToday => 'Сдать сегодня';

  @override
  String get assignmentDueTomorrow => 'Сдать завтра';

  @override
  String assignmentDueIn(int days) {
    return 'Сдать через $days дней';
  }

  @override
  String get assignmentCompleted => 'Выполнено';

  @override
  String get assignmentOverdue => 'Просрочено';

  @override
  String get noLessonsToday => 'Сегодня нет уроков';

  @override
  String get noUpcomingAssignments => 'Нет предстоящих заданий';

  @override
  String get allDoneForToday => 'На сегодня все!';

  @override
  String get freeTime => 'Свободное время';

  @override
  String get dashboardLoading => 'Загрузка панели...';

  @override
  String get dashboardError => 'Что-то пошло не так';

  @override
  String get dashboardRetry => 'Повторить';

  @override
  String get navHome => 'Главная';

  @override
  String get navSchedule => 'Расписание';

  @override
  String get navGrades => 'Оценки';

  @override
  String get navProfile => 'Профиль';

  @override
  String get scheduleTitle => 'Недельное расписание';

  @override
  String get scheduleMonday => 'Пн';

  @override
  String get scheduleTuesday => 'Вт';

  @override
  String get scheduleWednesday => 'Ср';

  @override
  String get scheduleThursday => 'Чт';

  @override
  String get scheduleFriday => 'Пт';

  @override
  String get scheduleSaturday => 'Сб';

  @override
  String get scheduleSunday => 'Вс';

  @override
  String get scheduleMondayFull => 'Понедельник';

  @override
  String get scheduleTuesdayFull => 'Вторник';

  @override
  String get scheduleWednesdayFull => 'Среда';

  @override
  String get scheduleThursdayFull => 'Четверг';

  @override
  String get scheduleFridayFull => 'Пятница';

  @override
  String get scheduleNoLessons => 'Нет уроков';

  @override
  String get scheduleBreak => 'Перемена';

  @override
  String get gradesTitle => 'Оценки';

  @override
  String get gradesComingSoon => 'Оценки скоро появятся';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileThemeSection => 'Внешний вид';

  @override
  String get profileLanguageSection => 'Язык';

  @override
  String get profileLogout => 'Выйти';

  @override
  String get profileLogoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get gradesAverage => 'Средний балл';

  @override
  String get gradesWeight => 'Вес';

  @override
  String get gradesDate => 'Дата';

  @override
  String get gradesOverallAverage => 'Общий средний балл';

  @override
  String get gradesNoGrades => 'Пока нет оценок';

  @override
  String gradesWeightFormat(String weight) {
    return 'Вес $weight';
  }

  @override
  String get subjectDetailStream => 'Лента';

  @override
  String get subjectDetailStreamDescription => 'Объявления и новости класса';

  @override
  String get subjectDetailAssignments => 'Задания';

  @override
  String get subjectDetailAssignmentsDescription =>
      'Ваши задания и домашняя работа';

  @override
  String get subjectDetailMaterials => 'Материалы';

  @override
  String get subjectDetailMaterialsDescription => 'Ресурсы и файлы курса';

  @override
  String get subjectDetailAnnouncement => 'Объявление';

  @override
  String get subjectDetailAssignment => 'Задание';

  @override
  String get subjectDetailSubmit => 'Отправить';

  @override
  String get subjectDetailSubmitted => 'Задание сдано!';

  @override
  String get subjectDetailNoStream => 'Пока нет объявлений';

  @override
  String get subjectDetailNoAssignments => 'Пока нет заданий';

  @override
  String get subjectDetailNoMaterials => 'Пока нет материалов';

  @override
  String subjectDetailDueDate(String date) {
    return 'Срок $date';
  }

  @override
  String subjectDetailPostedBy(String author) {
    return 'Опубликовал(а) $author';
  }

  @override
  String get subjectDetailViewMaterial => 'Просмотреть материал';

  @override
  String get dashboardInProgress => 'В процессе';

  @override
  String get dashboardUpNextLabel => 'Далее';

  @override
  String get dashboardStarted => 'Началось';

  @override
  String get dashboardStartingNow => 'Начинается сейчас';

  @override
  String dashboardInHoursMinutes(int hours, int minutes) {
    return 'через $hoursч $minutesм';
  }

  @override
  String dashboardInMinutes(int minutes) {
    return 'через $minutesм';
  }

  @override
  String get dashboardCancelled => 'Отменено';

  @override
  String dashboardSubstitution(String teacher) {
    return 'Замена: $teacher';
  }

  @override
  String get dashboardAllDone => 'Все сделано на сегодня!';

  @override
  String get dashboardNoMoreLessons => 'Больше нет запланированных уроков';

  @override
  String get dashboardNoClassesToday => 'Сегодня нет занятий';

  @override
  String get dashboardEnjoyFreeDay => 'Наслаждайтесь свободным днем!';

  @override
  String get dashboardSub => 'ЗАМ';

  @override
  String get dashboardToday => 'Сегодня';

  @override
  String get dashboardTomorrow => 'Завтра';

  @override
  String get dashboardLater => 'Позже';

  @override
  String get dashboardAllCaughtUp => 'Все выполнено!';

  @override
  String get dashboardNoAssignmentsDue => 'Нет заданий с близким сроком';

  @override
  String get dashboardSomethingWrong => 'Что-то пошло не так';

  @override
  String get dashboardStudent => 'Студент';

  @override
  String get dashboardAnError => 'Произошла ошибка';

  @override
  String get dashboardNoData => 'Данные недоступны';

  @override
  String scheduleLessonCount(int count) {
    return '$count урок';
  }

  @override
  String scheduleLessonsCount(int count) {
    return '$count уроков';
  }

  @override
  String get scheduleWeekend => 'Выходные!';

  @override
  String get scheduleEnjoyTimeOff => 'Наслаждайтесь отдыхом!';

  @override
  String get scheduleFreeDay => 'У вас свободный день. Время отдохнуть!';

  @override
  String get scheduleUnknown => 'Неизвестно';

  @override
  String get gradesNoGradesYet => 'Оценок пока нет';

  @override
  String get gradesWillAppear =>
      'Ваши оценки появятся здесь, когда они будут доступны.';

  @override
  String get gradesFailedToLoad => 'Не удалось загрузить оценки';

  @override
  String get gradesRetry => 'Повторить';

  @override
  String get gradesExcellent => 'Отлично';

  @override
  String get gradesGood => 'Хорошо';

  @override
  String get gradesFair => 'Удовлетворительно';

  @override
  String get gradesNeedsWork => 'Требует улучшения';

  @override
  String gradesWeightLabel(String weight) {
    return 'Вес $weight';
  }

  @override
  String get subjectStream => 'Лента';

  @override
  String get subjectAssignments => 'Задания';

  @override
  String get subjectMaterials => 'Материалы';

  @override
  String get subjectNoPostsYet => 'Пока нет записей';

  @override
  String get subjectPostsWillAppear =>
      'Записи появятся здесь, когда учитель опубликует обновления';

  @override
  String subjectTodayAt(String time) {
    return 'Сегодня в $time';
  }

  @override
  String subjectYesterdayAt(String time) {
    return 'Вчера в $time';
  }

  @override
  String subjectDayAt(String day, String time) {
    return '$day в $time';
  }

  @override
  String get subjectNoAssignments => 'Нет заданий';

  @override
  String get subjectAssignmentsWillAppear =>
      'Задания появятся здесь, когда учитель их опубликует';

  @override
  String get subjectDueToday => 'Срок сегодня';

  @override
  String get subjectDueTomorrow => 'Срок завтра';

  @override
  String subjectDueDate(String date) {
    return 'Срок $date';
  }

  @override
  String get subjectSubmitted => 'Задание сдано!';

  @override
  String get subjectSubmit => 'Отправить';

  @override
  String get subjectNoMaterials => 'Нет материалов';

  @override
  String get subjectMaterialsWillAppear =>
      'Материалы курса появятся здесь, когда учитель их опубликует';

  @override
  String subjectOpening(String url) {
    return 'Открываю: $url';
  }

  @override
  String get subjectFailedToLoad => 'Не удалось загрузить предмет';
}
