import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static final Storage _instance = Storage._internal();
  late SharedPreferences _prefs;

  Storage._internal();

  static Storage get instance => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs;
}
