
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class SearchRoomItem extends StatefulWidget {
  const SearchRoomItem({super.key, required this.room, this.onTap});
  final Profile room;
  final Function? onTap;

  @override
  State<SearchRoomItem> createState() => _SearchRoomItemState();
}

class _SearchRoomItemState extends State<SearchRoomItem> {

  late final Client client;

  @override
  void initState() {
    client = Provider.of<Client>(context, listen: false);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    String? url = widget.room.avatarUrl?.getThumbnail(client, width: 56, height: 56,).toString();

    return GestureDetector(
      onTap: (){
        if(widget.onTap != null){
          widget.onTap!();
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
                    ? Image.network(url, errorBuilder: (context, object, stackTrace){
                      return Text(widget.room.displayName?.split('').first.toUpperCase() ?? "",
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500));
                    })
                    : Text(widget.room.displayName?.split('').first.toUpperCase() ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
                )
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.room.displayName ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16),),
                  Text(widget.room.userId ?? 'No messages', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(width: 10,),
            const Text("Join", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600,),),
            const SizedBox(width: 20,),
          ],
        ),
      ),
    );
  }
}
