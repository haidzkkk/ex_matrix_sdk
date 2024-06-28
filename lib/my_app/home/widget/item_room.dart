
import 'package:ex_sdk_matrix/example/main_example.dart';
import 'package:ex_sdk_matrix/my_app/room_chat/room_chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../../ulti/date_converter.dart';

class ItemRoom extends StatefulWidget {
  const ItemRoom({super.key, required this.room, this.onTap});
  final Room room;
  final Function? onTap;

  @override
  State<ItemRoom> createState() => _ItemRoomState();
}

class _ItemRoomState extends State<ItemRoom> {

  late String myUserId;

  void _join() async{
    if (widget.room.membership != Membership.join) {
      await widget.room.join();
    }
    Navigator.push(context,
      MaterialPageRoute(
        builder: (_) => RoomChatScreen(room: widget.room),
        // builder: (_) => RoomPage(room: widget.room),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? url = widget.room.avatar?.getThumbnail(widget.room.client, width: 56, height: 56,).toString();

    return GestureDetector(
      onTap: (){
        if(widget.onTap != null){
          widget.onTap!();
        }else{
           _join();
        }
      },
      child: Container(
        color: Colors.white,
        height: 60,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.all(Radius.circular(100))
              ),
              margin: const EdgeInsetsDirectional.all(10),
              child: url != null && url.length > 5 == true
                  ? Image.network(url)
                  : Text(widget.room.getLocalizedDisplayname().split('').first.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
              )
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.room.getLocalizedDisplayname(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16),),
                  Text(widget.room.lastEvent?.body ?? 'No messages', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            if(widget.room.notificationCount > 0)
              ...[
                const SizedBox(width: 5,),
                Badge(label: Text(widget.room.notificationCount.toString()),),
                const SizedBox(width: 5,),
              ],
            Text(DateConverter.dateTimeToSinceEpochHourString(widget.room.lastEvent?.originServerTs), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
            const SizedBox(width: 10,),
          ],
         ),
      ),
    );
  }
}
