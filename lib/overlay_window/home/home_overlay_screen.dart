
import 'package:ex_sdk_matrix/my_app/home/widget/item_room.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../my_app/room_chat/room_chat_screen.dart';
import '../../ulti/flutter_overlay.dart';

class HomeOverlayScreen extends StatefulWidget {
  const HomeOverlayScreen({super.key});

  @override
  State<HomeOverlayScreen> createState() => _HomeOverlayScreenState();
}

class _HomeOverlayScreenState extends State<HomeOverlayScreen> {

  late final Client client;
  Room? currentRoom;

  @override
  void initState() {
    client = Provider.of<Client>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20),)
      ),
      margin: const EdgeInsetsDirectional.all(10),
      child: currentRoom != null
        ? RoomChatScreen(
          room: currentRoom!,
          onBack: (){
            currentRoom = null;
            setState(() {});
          },
        )
        : Scaffold(
        appBar: AppBar(
          title: const Text("All chats",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500
            ),
          ),
          leading: FutureBuilder(
              future: client.getProfileFromUserId(client.userID ?? ""),
              builder: (context, snapshot) {
                return Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.all(Radius.circular(100))
                  ),
                  margin: const EdgeInsetsDirectional.all(10),
                  child: Image.network(
                    snapshot.data?.avatarUrl?.getThumbnail(client, width: 56, height: 56,).toString() ?? "",
                    errorBuilder: (_, __, ___){
                      return Text(snapshot.data?.displayName?.split('').first.toUpperCase() ?? "",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                );
              }
          ),
        ),
        body: StreamBuilder(
          stream: client.onSync.stream,
          builder: (context, asyncSnapShot){
            return ListView.separated(
                itemCount: client.rooms.length,
                itemBuilder: (context, index){
                  var itemRoom = client.rooms[index];
                  return ItemRoom(
                    room: itemRoom,
                    onTap: () async{
                      if (itemRoom.membership != Membership.join) {
                        await itemRoom.join();
                      }
                      currentRoom = itemRoom;
                      setState(() {});
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10,)
            );
          },
        ),
      ),
    );
  }
}
