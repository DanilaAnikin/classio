import 'package:flutter/material.dart';
import '../../core/localization/generated/app_localizations.dart';

/// Helper class that provides localized labels for navigation items.
///
/// This class centralizes all navigation label translations in one place,
/// making it easier to maintain and update labels across different languages.
class NavigationLabels {
  /// Returns the localized label for the Home tab.
  static String home(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.home;
  }

  /// Returns the localized label for the Schedule tab.
  static String schedule(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Rozvrh';
      case 'de':
        return 'Stundenplan';
      case 'es':
        return 'Horario';
      case 'fr':
        return 'Emploi du temps';
      case 'it':
        return 'Orario';
      case 'pl':
        return 'Plan zajec';
      case 'ru':
        return 'Raspisanie';
      default:
        return 'Schedule';
    }
  }

  /// Returns the localized label for the Grades tab.
  static String grades(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Znamky';
      case 'de':
        return 'Noten';
      case 'es':
        return 'Notas';
      case 'fr':
        return 'Notes';
      case 'it':
        return 'Voti';
      case 'pl':
        return 'Oceny';
      case 'ru':
        return 'Ocenki';
      default:
        return 'Grades';
    }
  }

  /// Returns the localized label for the Profile tab.
  static String profile(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Profil';
      case 'de':
        return 'Profil';
      case 'es':
        return 'Perfil';
      case 'fr':
        return 'Profil';
      case 'it':
        return 'Profilo';
      case 'pl':
        return 'Profil';
      case 'ru':
        return 'Profil';
      default:
        return 'Profile';
    }
  }

  /// Returns the localized label for the Dashboard tab (superadmin and admin).
  static String dashboard(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Prehled';
      case 'de':
        return 'Dashboard';
      case 'es':
        return 'Panel';
      case 'fr':
        return 'Tableau de bord';
      case 'it':
        return 'Dashboard';
      case 'pl':
        return 'Panel';
      case 'ru':
        return 'Panel';
      default:
        return 'Dashboard';
    }
  }

  /// Returns the localized label for the Schools tab (superadmin).
  static String schools(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Skoly';
      case 'de':
        return 'Schulen';
      case 'es':
        return 'Escuelas';
      case 'fr':
        return 'Ecoles';
      case 'it':
        return 'Scuole';
      case 'pl':
        return 'Szkoly';
      case 'ru':
        return 'Shkoly';
      default:
        return 'Schools';
    }
  }

  /// Returns the localized label for the Users/Classes (Manage) tab (admin).
  static String manage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Sprava';
      case 'de':
        return 'Verwaltung';
      case 'es':
        return 'Gestion';
      case 'fr':
        return 'Gestion';
      case 'it':
        return 'Gestione';
      case 'pl':
        return 'Zarzadzanie';
      case 'ru':
        return 'Upravlenie';
      default:
        return 'Manage';
    }
  }

  /// Returns the localized label for the My Subjects tab (teacher).
  static String subjects(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Predmety';
      case 'de':
        return 'Facher';
      case 'es':
        return 'Materias';
      case 'fr':
        return 'Matieres';
      case 'it':
        return 'Materie';
      case 'pl':
        return 'Przedmioty';
      case 'ru':
        return 'Predmety';
      default:
        return 'Subjects';
    }
  }

  /// Returns the localized label for the Children tab (parent).
  static String children(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Deti';
      case 'de':
        return 'Kinder';
      case 'es':
        return 'Hijos';
      case 'fr':
        return 'Enfants';
      case 'it':
        return 'Figli';
      case 'pl':
        return 'Dzieci';
      case 'ru':
        return 'Deti';
      default:
        return 'Children';
    }
  }

  /// Returns the localized label for the Messages tab.
  static String messages(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Zpravy';
      case 'de':
        return 'Nachrichten';
      case 'es':
        return 'Mensajes';
      case 'fr':
        return 'Messages';
      case 'it':
        return 'Messaggi';
      case 'pl':
        return 'Wiadomosci';
      case 'ru':
        return 'Soobshcheniya';
      default:
        return 'Messages';
    }
  }
}
