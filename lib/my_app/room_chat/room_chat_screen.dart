
import 'package:ex_sdk_matrix/my_app/room_chat/widget/bottom_chat_widget.dart';
import 'package:ex_sdk_matrix/my_app/room_chat/widget/item_chat.dart';
import 'package:ex_sdk_matrix/room_call/room_call_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import 'package:matrix/src/voip/models/call_options.dart';
import '../../room_call/my_voip_app.dart';

class RoomChatScreen extends StatefulWidget {
  const RoomChatScreen({super.key, required this.room, this.onBack});

  final Room room;
  final Function()? onBack;

  @override
  State<RoomChatScreen> createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends State<RoomChatScreen> {

  late final Client client;
  ScrollController chatScrollController = ScrollController();

  RxBool isTyping = false.obs;

  late final Future<Timeline> _timeline;

  @override
  void initState() {
    super.initState();
    client = Provider.of<Client>(context, listen: false);
    _timeline = widget.room.getTimeline(
      onChange: (index) async {
        setState(() {});
      },
      onInsert: (i) async{
        setState(() {});
      },
    );

    widget.room.client.onSync.stream.listen((event) async{
      isTyping.value = (await _timeline).room.typingUsers.isNotEmpty;
    });

    chatScrollController.addListener(() async{
      await Future.delayed(1000.milliseconds);
      var timeline = await _timeline;
      if(chatScrollController.offset == chatScrollController.position.maxScrollExtent){
        timeline.requestHistory().whenComplete(() {
          setState(() {

          });
        });
      }
    });
  }


  @override
  void dispose() {
    widget.room.setTyping(false);
    chatScrollController.dispose();
    super.dispose();
  }

  void callChat() async{
    // Timeline timeline = await _timeline;
    // String? remoteUserId = timeline.events.firstWhereOrNull((element) => element.senderId != client.userID)?.senderId;
    // Navigator.push(context, MaterialPageRoute(builder:
    //     (context) => RoomCallScreen(room: widget.room, isCallVideo: false, remoteUserId: remoteUserId,)));


    VoIP voip = VoIP(client, MyVoipApp());

    final call = voip.createNewCall(CallOptions(
      callId: '1234',
      type: CallType.kVoice,
      dir: CallDirection.kOutgoing,
      localPartyId: '4567',
      voip: voip,
      room: widget.room,
      iceServers: [],
    ));
    await call.sendInviteToCall(widget.room, '1234', 1234, '4567', 'sdp',
        txid: '1234');

  }

  void callVideo() async{
    Timeline timeline = await _timeline;
    String? remoteUserId = timeline.events.firstWhereOrNull((element) => element.senderId != client.userID)?.senderId;
    Navigator.push(context, MaterialPageRoute(builder:
        (context) => RoomCallScreen(room: widget.room, isCallVideo: true, remoteUserId: remoteUserId,)));
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.room.avatar?.getThumbnail(widget.room.client, width: 56, height: 56,).toString() ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: (){
              if(widget.onBack != null){
                widget.onBack!();
              }else{
                Navigator.pop(context);
              }
            },
            child: const BackButtonIcon()),
        leadingWidth: 30,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.all(Radius.circular(100))
              ),
              child: Image.network(
                imageUrl,
                errorBuilder: (_, __, ___){
                  return Text(widget.room.getLocalizedDisplayname().split('').first.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
                  );
                },
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
                child: Text(widget.room.getLocalizedDisplayname(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16
                  ),
                )
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: callVideo,
            child: const Padding(
                padding: EdgeInsetsDirectional.all(5),
                child: Icon(Icons.videocam, size: 27, color: Colors.teal,)
            ),
          ),
          GestureDetector(
            onTap: callChat,
            child: const Padding(
                padding: EdgeInsetsDirectional.all(5),
                child: Icon(Icons.call, size: 23, color: Colors.teal,)
            ),
          ),
          GestureDetector(
            onTap: (){},
            child: const Padding(
                padding: EdgeInsetsDirectional.all(5),
                child: Icon(Icons.chat_bubble_outlined, size: 20, color: Colors.teal,)
            ),
          ),
          PopupMenuButton(
              itemBuilder: (context){
                return [
                  const PopupMenuItem(child: Text("Setting")),
                  const PopupMenuItem(child: Text("Invite")),
                  const PopupMenuItem(child: Text("Add Matrix apps")),
                ];
              }
          ),
        ],
      ),
      body: FutureBuilder(
          future: _timeline,
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return const Center(child: CircularProgressIndicator(),);
            }

            Timeline timeline = snapshot.data!;
            var isLast = timeline.room.prev_batch == null;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    // shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    controller: chatScrollController,
                    itemCount: timeline.events.length + (isLast ? 0 : 1),
                    itemBuilder: (context, index){

                      if(index >= timeline.events.length){
                        return const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator(),),
                        );
                      }

                      Event item = timeline.events[index];
                      return ItemChat(
                        data: item,
                        typeMe: client.userID == item.senderId,
                        showTimer: index + 1 >= timeline.events.length ? true : compareDate(firstDate: item.originServerTs, secondDate: timeline.events[index + 1].originServerTs, betweenHour:  2),
                        showInfo: index + 1 >= timeline.events.length  || item.senderId != timeline.events[index + 1].senderId
                            ? true
                            : compareDate(firstDate: item.originServerTs, secondDate: timeline.events[index + 1].originServerTs, betweenHour:  1),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.all(10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Obx(() => isTyping.value
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: timeline.room.typingUsers.length,
                            itemBuilder: (BuildContext context, int index) {
                              var userTyping = timeline.room.typingUsers[index];
                              return Text("${userTyping.displayName} đang gõ", style: const TextStyle(fontSize: 8),);
                            },)
                        : const SizedBox()
                    ),
                  ),
                ),
                BottomChatWidget(room: widget.room),
              ],
            );
          }
      ),
    );
  }

  bool compareDate({required DateTime? firstDate, required DateTime? secondDate, required double betweenHour}){
    if( firstDate == null || secondDate == null ) return false;
    return firstDate.hour - secondDate.hour >= betweenHour;
  }

}
