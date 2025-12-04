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

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Artist`
  String get artist {
    return Intl.message('Artist', name: 'artist', desc: '', args: []);
  }

  /// `Album`
  String get album {
    return Intl.message('Album', name: 'album', desc: '', args: []);
  }

  /// `Create time`
  String get createTime {
    return Intl.message('Create time', name: 'createTime', desc: '', args: []);
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `Descending`
  String get descending {
    return Intl.message('Descending', name: 'descending', desc: '', args: []);
  }

  /// `what do you want?`
  String get searchHint {
    return Intl.message(
      'what do you want?',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Scanning`
  String get scanning {
    return Intl.message('Scanning', name: 'scanning', desc: '', args: []);
  }

  /// `NO AUDIO!!`
  String get noAudio {
    return Intl.message('NO AUDIO!!', name: 'noAudio', desc: '', args: []);
  }

  /// `Unsubscribe`
  String get unsubscribe {
    return Intl.message('Unsubscribe', name: 'unsubscribe', desc: '', args: []);
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message('Subscribe', name: 'subscribe', desc: '', args: []);
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Downloaded Episodes`
  String get downloadedEpisodes {
    return Intl.message(
      'Downloaded Episodes',
      name: 'downloadedEpisodes',
      desc: '',
      args: [],
    );
  }

  /// `NO PODCAST`
  String get noPodcast {
    return Intl.message('NO PODCAST', name: 'noPodcast', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Play Speed`
  String get playSpeed {
    return Intl.message('Play Speed', name: 'playSpeed', desc: '', args: []);
  }

  /// `Latest First`
  String get latestFirst {
    return Intl.message(
      'Latest First',
      name: 'latestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Oldest First`
  String get oldestFirst {
    return Intl.message(
      'Oldest First',
      name: 'oldestFirst',
      desc: '',
      args: [],
    );
  }

  /// `A-Z`
  String get az {
    return Intl.message('A-Z', name: 'az', desc: '', args: []);
  }

  /// `Z-A`
  String get za {
    return Intl.message('Z-A', name: 'za', desc: '', args: []);
  }

  /// `Select Your Provider`
  String get selectProvider {
    return Intl.message(
      'Select Your Provider',
      name: 'selectProvider',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Podcast Api`
  String get podcastApi {
    return Intl.message('Podcast Api', name: 'podcastApi', desc: '', args: []);
  }

  /// `More Info`
  String get moreInfo {
    return Intl.message('More Info', name: 'moreInfo', desc: '', args: []);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Are you sure about that?`
  String get areYouSureAboutThat {
    return Intl.message(
      'Are you sure about that?',
      name: 'areYouSureAboutThat',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Sound Center`
  String get soundCenter {
    return Intl.message(
      'Sound Center',
      name: 'soundCenter',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Failed To Load Podcast`
  String get loadFail {
    return Intl.message(
      'Failed To Load Podcast',
      name: 'loadFail',
      desc: '',
      args: [],
    );
  }

  /// `Load Podcast`
  String get loadPodcast {
    return Intl.message(
      'Load Podcast',
      name: 'loadPodcast',
      desc: '',
      args: [],
    );
  }

  /// `Rss Feed`
  String get rssFeed {
    return Intl.message('Rss Feed', name: 'rssFeed', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Local`
  String get local {
    return Intl.message('Local', name: 'local', desc: '', args: []);
  }

  /// `Podcast`
  String get podcast {
    return Intl.message('Podcast', name: 'podcast', desc: '', args: []);
  }

  /// `----------------- THEM NAMES ----------------`
  String get THEME_NAMES {
    return Intl.message(
      '----------------- THEM NAMES ----------------',
      name: 'THEME_NAMES',
      desc: '',
      args: [],
    );
  }

  /// `Create New Theme`
  String get createNewTheme {
    return Intl.message(
      'Create New Theme',
      name: 'createNewTheme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `Green`
  String get green {
    return Intl.message('Green', name: 'green', desc: '', args: []);
  }

  /// `Purple`
  String get purple {
    return Intl.message('Purple', name: 'purple', desc: '', args: []);
  }

  /// `Appbar Background`
  String get appBarBackground {
    return Intl.message(
      'Appbar Background',
      name: 'appBarBackground',
      desc: '',
      args: [],
    );
  }

  /// `scaffold Background`
  String get scaffoldBackground {
    return Intl.message(
      'scaffold Background',
      name: 'scaffoldBackground',
      desc: '',
      args: [],
    );
  }

  /// `shadow`
  String get shadowColor {
    return Intl.message('shadow', name: 'shadowColor', desc: '', args: []);
  }

  /// `Slider`
  String get thumbColor {
    return Intl.message('Slider', name: 'thumbColor', desc: '', args: []);
  }

  /// `Icon`
  String get iconColor {
    return Intl.message('Icon', name: 'iconColor', desc: '', args: []);
  }

  /// `Current Media Background`
  String get currentMediaColor {
    return Intl.message(
      'Current Media Background',
      name: 'currentMediaColor',
      desc: '',
      args: [],
    );
  }

  /// `This name is already used`
  String get nameIsUsed {
    return Intl.message(
      'This name is already used',
      name: 'nameIsUsed',
      desc: '',
      args: [],
    );
  }

  /// `Theme Name`
  String get themeName {
    return Intl.message('Theme Name', name: 'themeName', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fa'),
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
