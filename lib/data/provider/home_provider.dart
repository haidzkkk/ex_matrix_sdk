
import 'package:flutter/widgets.dart';
import 'package:matrix/matrix.dart';

class HomeProvider extends ChangeNotifier{
  HomeProvider(this._client);

  Client _client;
  Profile? _profile;
  List<Room> rooms = [];
  SearchUserDirectoryResponse? roomSearch;

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

  selectRoom(Room room) async{
    if (room.membership != Membership.join) {
      await room.join();
    }
  }

  searchRoom(String text, int pageIndex) async{
    try{
      roomSearch = await client.searchUserDirectory(text, limit: pageIndex * 10,);
    }catch(e){
      roomSearch = null;
    }
  }

  Future<Room?> joinRoomSearch(String id) async{
    try{
      var roomId = await client.joinRoomById(id);
      return client.getRoomById(roomId);
    }catch(e){
      rethrow;
    }
  }
}