// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get ok => 'Ok';

  @override
  String get welcome => 'Benvenuto su Remorder';

  @override
  String get start => 'Inizia';

  @override
  String get try_again => 'Riprova';

  @override
  String get device => 'Dispositivo';

  @override
  String get connected => 'Connesso';

  @override
  String get disconnected => 'Disconnesso';

  @override
  String get wear_remo => 'Indossa REMO e accendilo';

  @override
  String get turn_on_bt => 'Attiva il Bluetooth sul tuo telefono';

  @override
  String get start_pairing => 'Inizia configurazione';

  @override
  String get permission_bt => 'Permessi Bluetooth';

  @override
  String get permission_bt_request =>
      'Remo ha bisogno dei permessi Bluetooth per connettersi con il dispositivo.';

  @override
  String get choose_another_device => 'Scegli un altro dispositivo';

  @override
  String get looking_for_remo => 'Cercando REMO...';

  @override
  String get choose_device => 'Scegli il tuo dispositivo';

  @override
  String get pairing => 'Configurazione...';

  @override
  String get pairing_successful => 'Configurazione con successo';

  @override
  String get pairing_fail => 'Configurazione fallita';

  @override
  String get data_visualization => 'Visualizazione dati';

  @override
  String get graph_1 => 'Grafo 1';

  @override
  String get graph_2 => 'Grafo 2';

  @override
  String get want_save => 'Vuoi salvare la registrazione?';

  @override
  String get save => 'Salva';

  @override
  String get saving => 'Salvando...';

  @override
  String get saved => 'Salvato!';

  @override
  String get delete => 'Cancella';

  @override
  String get cancel => 'Annulla';

  @override
  String get your_file_will_be_saved =>
      'Il tuo file sarà salvato nella cartella dei download';

  @override
  String get insert_file_name => 'Inserisci il nome del file:';

  @override
  String get record_name => 'NomeSalvataggio';

  @override
  String get you_need_to_name => 'Dai un nome al file';

  @override
  String get want_delete => 'Vuoi eliminarlo?';

  @override
  String get delete_confirm_text =>
      'Sicuro di voler eliminare il file?\nNon potrai recuperarlo.';
}
