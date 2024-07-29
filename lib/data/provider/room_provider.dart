
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/matrix.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../screen/room_call/my_voip_app.dart';

class RoomProvider extends ChangeNotifier {
  RoomProvider(this._client);

  Client _client;
  Room? _room;
  Timeline? _timeline;
  bool isTyping = false;
  List<User> members = [];
  StreamSubscription? _streamMessage;

  Client get client => _client;
  Room? get room => _room;
  Timeline? get timeline => _timeline;
  bool get encrypted => room?.encrypted ?? false;
  set setTyping(bool isTyping) => room?.setTyping(isTyping);

  initRoom(Room room) async {
    _room = room;
    _timeline = await _room!.getTimeline(
      onChange: (index) async {
        notifyListeners();
      },
      onInsert: (i) async{
        notifyListeners();
        readMessage();
      },
    );
    notifyListeners();

    getMember();

    _streamMessage = _room?.client.onSync.stream.listen((event) async{
      isTyping = _timeline!.room.typingUsers.isNotEmpty;
    });
  }

  getMember() async{
    members = await room?.requestParticipants() ?? [];
    print("${members.length}");
    notifyListeners();
  }

  getMoreMessage() async{
    await _timeline?.requestHistory();
    notifyListeners();
  }

  setEncrypted(bool active) async{
    room?.enableEncryption();
    notifyListeners();
  }

  Future<MatrixFile?> _selectGallery(ImageSource source) async {
    if(source == ImageSource.camera && await Permission.camera.request().isDenied){
      return null;
    }

    final XFile? image = await ImagePicker().pickImage(source: source);
    if(image == null) return null;

    var bytes = await image.readAsBytes();
    return MatrixFile(bytes: bytes, name: DateTime.now().millisecondsSinceEpoch.toString());
  }

  Future<void> sendImage(ImageSource source) async{
    MatrixFile? file = await _selectGallery(source);
    if(file == null) return;
    notifyListeners();
    room?.sendFileEvent(file);
  }

  void sendTextMessage(String strMessage) async{
    await room?.sendTextEvent(strMessage);
  }

  /// set read all message viewed
  void readMessage(){
    room?.setReadMarker(
        room?.lastEvent?.eventId,
        mRead: room?.lastEvent?.eventId
    );
  }

  /// get room url
  Uri getRoomUri(){
    Uri? baseUri = client.baseUri;
    Uri pathUri = Uri.parse("$baseUri/#/${room?.id}?via=${baseUri?.host}");
    return pathUri;
  }

  /// call video

  void callChat() async{
    // Timeline timeline = await _timeline;
    // String? remoteUserId = timeline.events.firstWhereOrNull((element) => element.senderId != client.userID)?.senderId;
    // Navigator.push(context, MaterialPageRoute(builder:
    //     (context) => RoomCallScreen(room: widget.room, isCallVideo: false, remoteUserId: remoteUserId,)));


    // VoIP voip = VoIP(client, MyVoipApp());
    //
    // final call = voip.createNewCall(CallOptions(
    //   callId: '1234',
    //   type: CallType.kVoice,
    //   dir: CallDirection.kOutgoing,
    //   localPartyId: '4567',
    //   voip: voip,
    //   room: widget.room,
    //   iceServers: [],
    // ));
    // await call.sendInviteToCall(widget.room, '1234', 1234, '4567', 'sdp',
    //     txid: '1234');

  }

  void cleanRoom(){
    _room = null;
    _timeline = null;
    isTyping = false;
    _streamMessage?.cancel();
    members = [];
  }

  /// id to call video
  String? getRemoteUserId() => timeline?.events.firstWhereOrNull((element) => element.senderId != _client.userID)?.senderId;

  VoIP? voip;
  CallSession? newCall;
  MediaStream? localStream;
  MediaStream? remoteStream;
  startCall(Room room, String remoteUserId) async{
    voip = VoIP(client, MyVoipApp());

    newCall = await voip!.inviteToCall(
        room,
        CallType.kVideo,
        userId: remoteUserId
    );

    newCall!.onCallStateChanged.stream.listen((state) {
      remoteStream = newCall!.remoteUserMediaStream?.stream;
    });

    localStream = newCall!.localUserMediaStream?.stream;
    notifyListeners();
  }

  void endCall(){
    newCall?.deleteAllStreams();
    newCall?.cleanUp();
  }
}