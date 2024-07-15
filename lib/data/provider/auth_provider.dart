
import 'package:flutter/widgets.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier{

  static const String DEFAULT_HOMESERVER = "matrix.org";

  AuthProvider(this._client);

  Client _client;

  bool _loading = false;
  bool _showPass = false;

  Client get client => _client;
  bool get loading  =>_loading;
  bool get showPass  =>_showPass;


  Future<void> login({
    required String homeServer,
    required String username,
    required String password,
}) async {
    if(_loading == true) return;
    _loading = true;
    notifyListeners();

    try {
      await client.checkHomeserver(Uri.https(homeServer, ''));
      await client.login(
        LoginType.mLoginPassword,
        password: password,
        identifier: AuthenticationUserIdentifier(user: username),
      );
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  changeShowPass(){
    _showPass = !_showPass;
    notifyListeners();
  }

  saveAccount() async{
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    //
    // preferences.setString("U", value)
  }

}