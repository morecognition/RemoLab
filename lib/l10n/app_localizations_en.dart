// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ok => 'Ok';

  @override
  String get welcome => 'Welcome to Remorder';

  @override
  String get start => 'Start';

  @override
  String get try_again => 'Try again';

  @override
  String get device => 'Device';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get wear_remo => 'Wear REMO and turn it on';

  @override
  String get turn_on_bt => 'Turn on the bluetooth on your phone';

  @override
  String get start_pairing => 'Start pairing';

  @override
  String get permission_bt => 'Bluetooth permission';

  @override
  String get permission_bt_request =>
      'Remo needs Bluetooth permissions in order to connect with the device.';

  @override
  String get choose_another_device => 'Choose another device';

  @override
  String get looking_for_remo => 'Looking for REMO...';

  @override
  String get choose_device => 'Choose your device';

  @override
  String get pairing => 'Pairing...';

  @override
  String get pairing_successful => 'Pairing successful';

  @override
  String get pairing_fail => 'Pairing failed';

  @override
  String get data_visualization => 'Data visualization';

  @override
  String get graph_1 => 'Graph';

  @override
  String get graph_2 => 'Feedback';

  @override
  String get want_save => 'Want to save the record?';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get saved => 'Saved!';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get your_file_will_be_saved =>
      'Your file will be saved in the download folder';

  @override
  String get insert_file_name => 'Insert file name:';

  @override
  String get record_name => 'RecordName';

  @override
  String get you_need_to_name => 'You need to name it';

  @override
  String get want_delete => 'Want to delete?';

  @override
  String get delete_confirm_text =>
      'Are you sure want to delete the file?\nYou will not be able to recover it.';

  @override
  String get feed_back => 'Feedback';

  @override
  String get start_calibrating => 'Start';

  @override
  String get pre_calibration_message =>
      'Relax the muscle.\nWe are recording the resting activity for 5 seconds.\nStay in the blue inner circle.';

  @override
  String get rest_calibration_message =>
      'Relax the muscle.\nWe are recording the resting activity for 5 seconds.\nStay in the blue inner circle.';

  @override
  String get pre_max_calibration_message =>
      'Do the exercise at max of\nyour strength for 3 seconds.';

  @override
  String get max_calibration_message =>
      'Do the exercise at max of\nyour strength for 3 seconds.';

  @override
  String get pre_biofeedback_message =>
      'Activate the muscle as the therapist told you.\nThe movement on the screen displays the muscular activation';

  @override
  String get biofeedback_message =>
      'Activate the muscle as the therapist told you.\nThe movement on the screen displays the muscular activation';

  @override
  String get step_1 => 'Step 1';

  @override
  String get step_2 => 'Step 2';

  @override
  String get step_3 => 'Step 3';

  @override
  String get next_exercise => 'Next exercise';

  @override
  String get repeat => 'Repeat';

  @override
  String get exercise_completed => 'Completed!';

  @override
  String get stop_exercise => 'Click to stop the exercise';

  @override
  String repetitions(int repetition_count) {
    return 'Repetitions: $repetition_count';
  }
}
