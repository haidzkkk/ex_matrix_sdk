
import 'package:ex_sdk_matrix/ultis/app_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier{


  AuthProvider(this._client, this.pres);

  Client _client;
  SharedPreferences pres;

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

      await Future.wait([
        pres.setString(AppConstants.PRE_HOMESERVER_KEY, homeServer),
        pres.setString(AppConstants.PRE_USERNAME_KEY, username),
        pres.setString(AppConstants.PRE_PASSWORD_KEY, password),
      ]);

    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loginLocalData() async {
    if(_loading == true) return;
    _loading = true;
    notifyListeners();

    try {
      String homeserver = pres.getString(AppConstants.PRE_HOMESERVER_KEY) ?? "";
      String username = pres.getString(AppConstants.PRE_USERNAME_KEY) ?? "";
      String password = pres.getString(AppConstants.PRE_PASSWORD_KEY) ?? "";

      print("login: $homeserver $username $password");
      if(homeserver.isEmpty || username.isEmpty || password.isEmpty) throw Future.error("Lỗi");

      await client.checkHomeserver(Uri.https(homeserver, ''));
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
    print("Đã login");
  }

  logout() async{
    await client.logout();
    await pres.remove(AppConstants.PRE_HOMESERVER_KEY);
    pres.remove(AppConstants.PRE_USERNAME_KEY);
    pres.remove(AppConstants.PRE_PASSWORD_KEY);
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