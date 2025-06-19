import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Remorder'**
  String get welcome;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @wear_remo.
  ///
  /// In en, this message translates to:
  /// **'Wear REMO and turn it on'**
  String get wear_remo;

  /// No description provided for @turn_on_bt.
  ///
  /// In en, this message translates to:
  /// **'Turn on the bluetooth on your phone'**
  String get turn_on_bt;

  /// No description provided for @start_pairing.
  ///
  /// In en, this message translates to:
  /// **'Start pairing'**
  String get start_pairing;

  /// No description provided for @permission_bt.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission'**
  String get permission_bt;

  /// No description provided for @permission_bt_request.
  ///
  /// In en, this message translates to:
  /// **'Remo needs Bluetooth permissions in order to connect with the device.'**
  String get permission_bt_request;

  /// No description provided for @choose_another_device.
  ///
  /// In en, this message translates to:
  /// **'Choose another device'**
  String get choose_another_device;

  /// No description provided for @looking_for_remo.
  ///
  /// In en, this message translates to:
  /// **'Looking for REMO...'**
  String get looking_for_remo;

  /// No description provided for @choose_device.
  ///
  /// In en, this message translates to:
  /// **'Choose your device'**
  String get choose_device;

  /// No description provided for @pairing.
  ///
  /// In en, this message translates to:
  /// **'Pairing...'**
  String get pairing;

  /// No description provided for @pairing_successful.
  ///
  /// In en, this message translates to:
  /// **'Pairing successful'**
  String get pairing_successful;

  /// No description provided for @pairing_fail.
  ///
  /// In en, this message translates to:
  /// **'Pairing failed'**
  String get pairing_fail;

  /// No description provided for @data_visualization.
  ///
  /// In en, this message translates to:
  /// **'Data visualization'**
  String get data_visualization;

  /// No description provided for @graph_1.
  ///
  /// In en, this message translates to:
  /// **'Graph 1'**
  String get graph_1;

  /// No description provided for @graph_2.
  ///
  /// In en, this message translates to:
  /// **'Graph 2'**
  String get graph_2;

  /// No description provided for @want_save.
  ///
  /// In en, this message translates to:
  /// **'Want to save the record?'**
  String get want_save;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get saved;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @your_file_will_be_saved.
  ///
  /// In en, this message translates to:
  /// **'Your file will be saved in the download folder'**
  String get your_file_will_be_saved;

  /// No description provided for @insert_file_name.
  ///
  /// In en, this message translates to:
  /// **'Insert file name:'**
  String get insert_file_name;

  /// No description provided for @record_name.
  ///
  /// In en, this message translates to:
  /// **'RecordName'**
  String get record_name;

  /// No description provided for @you_need_to_name.
  ///
  /// In en, this message translates to:
  /// **'You need to name it'**
  String get you_need_to_name;

  /// No description provided for @want_delete.
  ///
  /// In en, this message translates to:
  /// **'Want to delete?'**
  String get want_delete;

  /// No description provided for @delete_confirm_text.
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to delete the file?\nYou will not be able to recover it.'**
  String get delete_confirm_text;

  /// No description provided for @feed_back.
  ///
  /// In en, this message translates to:
  /// **'Feed back'**
  String get feed_back;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
