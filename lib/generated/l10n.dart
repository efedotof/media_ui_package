// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Choose files`
  String get chooseFiles {
    return Intl.message(
      'Choose files',
      name: 'chooseFiles',
      desc: '',
      args: [],
    );
  }

  /// `Drop files or use button below`
  String get dropFilesOrUseButtonBelow {
    return Intl.message(
      'Drop files or use button below',
      name: 'dropFilesOrUseButtonBelow',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Select Media`
  String get selectMedia {
    return Intl.message(
      'Select Media',
      name: 'selectMedia',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Drop files to add media`
  String get dropFilesToAddMedia {
    return Intl.message(
      'Drop files to add media',
      name: 'dropFilesToAddMedia',
      desc: '',
      args: [],
    );
  }

  /// `Maximum ${widget.maxSelection} files allowed`
  String get maximumWidgetmaxselectionFilesAllowed {
    return Intl.message(
      'Maximum \${widget.maxSelection} files allowed',
      name: 'maximumWidgetmaxselectionFilesAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pick files: $e`
  String get failedToPickFilesE {
    return Intl.message(
      'Failed to pick files: \$e',
      name: 'failedToPickFilesE',
      desc: '',
      args: [],
    );
  }

  /// `No media files`
  String get noMediaFiles {
    return Intl.message(
      'No media files',
      name: 'noMediaFiles',
      desc: '',
      args: [],
    );
  }

  /// `No media available`
  String get noMediaAvailable {
    return Intl.message(
      'No media available',
      name: 'noMediaAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied`
  String get permissionDenied {
    return Intl.message(
      'Permission denied',
      name: 'permissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `No media`
  String get noMedia {
    return Intl.message('No media', name: 'noMedia', desc: '', args: []);
  }

  /// `Loading error`
  String get loadingError {
    return Intl.message(
      'Loading error',
      name: 'loadingError',
      desc: '',
      args: [],
    );
  }

  /// `There are no available images`
  String get thereAreNoAvailableImages {
    return Intl.message(
      'There are no available images',
      name: 'thereAreNoAvailableImages',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
