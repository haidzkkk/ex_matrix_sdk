import 'package:matrix/matrix.dart';

extension ClientExtension on Client{
}

extension RoomExtension on Room{
  String getAvatarUrl({double? size}) => avatar?.getThumbnail(client, width: size ?? 56, height: size?? 56,).toString() ?? "";
  String get getFirstCharacterDisplayName => getLocalizedDisplayname().split('').first.toUpperCase();
}

extension UserExtension on User{
  String getAvatarUrl({required Client client, double? size}) => avatarUrl?.getThumbnail(client, width: size ?? 56, height: size ?? 56,).toString() ?? "";
  bool get isAdmin => !canKick;
}

extension ProfileExtension on Profile{
  getAvatarUrl(Client client, {double? size}){
    return avatarUrl?.getThumbnail(client, width: size ?? 56, height: size ?? 56,).toString() ?? "";
  }
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
  }
}

