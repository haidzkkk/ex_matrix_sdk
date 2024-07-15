
import 'package:matrix/matrix.dart';

extension ClientExtension on Client{
}

extension RoomExtension on Room{
  String get getAvatarUrl => avatar?.getThumbnail(client, width: 56, height: 56,).toString() ?? "";
}

extension ProfileExtension on Profile{
  getAvatarUrl(Client client){
    return avatarUrl?.getThumbnail(client, width: 56, height: 56,).toString() ?? "";
  }

  String get getFirstCharacterDisplayName => displayName?.split('').first.toUpperCase() ?? "" "";

}

extension EventStatusExtension on EventStatus{
  String getString(){
    switch(this){
      case EventStatus.sent:
        return "Đã giử";
      case EventStatus.error:
        return "Thất bại";
      case EventStatus.sending:
        return "Đang giử";
      case EventStatus.synced:
        return "Lúc";
      case EventStatus.roomState:
        return "Trạng thái phòng";
    }
    return "";
  }
}

