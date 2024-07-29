
import 'package:ex_sdk_matrix/data/provider/room_provider.dart';
import 'package:ex_sdk_matrix/screen/room_wall/room_wall_screen.dart';
import 'package:ex_sdk_matrix/screen/room_chat/widget/bottom_chat_widget.dart';
import 'package:ex_sdk_matrix/screen/room_chat/widget/item_chat.dart';
import 'package:ex_sdk_matrix/ultis/client_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import '../../screen/room_call/room_call_screen.dart';
import '../widget/avatar_widget.dart';

class RoomChatScreen extends StatefulWidget {
  const RoomChatScreen({super.key, required this.room, this.onBack});

  final Room room;
  final Function()? onBack;

  @override
  State<RoomChatScreen> createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends State<RoomChatScreen> {

  ScrollController chatScrollController = ScrollController();

  late RoomProvider roomProvider = context.read<RoomProvider>();

  @override
  void initState() {
    super.initState();
    roomProvider.initRoom(widget.room);
    roomProvider.readMessage();
    chatScrollController.addListener(() async{
      if(chatScrollController.offset == chatScrollController.position.maxScrollExtent){
        roomProvider.getMoreMessage();
      }
    });
  }

  @override
  void dispose() {
    chatScrollController.dispose();
    roomProvider.cleanRoom();
    super.dispose();
  }

  void callVideo() async{
    String? remoteUserId = roomProvider.getRemoteUserId();
    Navigator.push(context, MaterialPageRoute(builder:
        (context) => RoomCallScreen(room: widget.room, isCallVideo: true, remoteUserId: remoteUserId,)));
  }

  @override
  Widget build(BuildContext context) {

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
        title: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomWallScreen()));
          },
          child: Row(
            children: [
              if(roomProvider.room != null)
                AvatarWidget(
                    size: 30,
                    avatarUrl: roomProvider.room!.getAvatarUrl(),
                    displayName: roomProvider.room!.getLocalizedDisplayname()
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
            onTap: callVideo,
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
                  PopupMenuItem(
                    child: const Text("Setting"),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomWallScreen()));
                    },
                  ),
                  const PopupMenuItem(child: Text("Invite")),
                  const PopupMenuItem(child: Text("Add Matrix apps")),
                ];
              }
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<RoomProvider>(
               builder: (context, roomProvider, child) {
                if(roomProvider.timeline == null || roomProvider.timeline!.events.isEmpty){
                  return const Center(child: CircularProgressIndicator(),);
                }
                Timeline timeline = roomProvider.timeline!;
                var isLast = timeline.room.prev_batch == null;

                return ListView.builder(
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
                      latter: index == 0,
                      typeMe: roomProvider.client.userID == item.senderId,
                      showTimer: index + 1 >= timeline.events.length ? true : compareDate(firstDate: item.originServerTs, secondDate: timeline.events[index + 1].originServerTs, betweenHour:  2),
                      showInfo: index + 1 >= timeline.events.length  || item.senderId != timeline.events[index + 1].senderId
                          ? true
                          : compareDate(firstDate: item.originServerTs, secondDate: timeline.events[index + 1].originServerTs, betweenHour:  1),
                    );
                  },
                );

              }
            ),
          ),
          Selector<RoomProvider, bool>(
           selector: (context, roomProvider) => roomProvider.isTyping,
            builder: (context, isTyping, child) {
              if(!isTyping) return const SizedBox();
              return Padding(
                padding: const EdgeInsetsDirectional.all(5),
                child: Row(
                  children: roomProvider.timeline!.room.typingUsers.map((userTyping){
                    return Text("${userTyping.displayName} đang gõ", style: const TextStyle(fontSize: 8),);
                  }).toList(),
                ),
              );
            }
          ),
          const BottomChatWidget(),
        ],
      ),
    );
  }

  bool compareDate({required DateTime? firstDate, required DateTime? secondDate, required double betweenHour}){
    if( firstDate == null || secondDate == null ) return false;
    return firstDate.hour - secondDate.hour >= betweenHour;
  }

}
