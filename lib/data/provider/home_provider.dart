
import 'package:flutter/widgets.dart';
import 'package:matrix/matrix.dart';

class HomeProvider extends ChangeNotifier{
  HomeProvider(this._client);

  Client _client;
  Profile? _profile;
  List<Room> rooms = [];

  Client get client => _client;
  Profile? get profile => _profile;

  onSyncRoomChat(){
    rooms = client.rooms;
    _client.onSync.stream.listen((onData){
      rooms = client.rooms;
      notifyListeners();
    });
  }

  getCurrentUser() async{
    _profile = await client.getProfileFromUserId(client.userID ?? "");
    notifyListeners();
  }

  joinRoom(Room room) async{
    if (room.membership != Membership.join) {
      await room.join();
    }
  }
}