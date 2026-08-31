import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/localization/en.dart';
import 'package:step_detector/core/localization/kh.dart';

class AppTranslations extends ChangeNotifier {
  Locale _locale = const Locale('km');
  Locale get locale => _locale;

  void changeLocale(Locale newLocale) {
    if (newLocale != _locale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': enTranslations,
    'km': khTranslations,
  };

  String tr(String key) {
    return _translations[_locale.languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }
}

extension TranslationExtension on String {
  String tr(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.watch<AppTranslations>().tr(this);
    } else {
      return context.read<AppTranslations>().tr(this);
    }
  }
}

