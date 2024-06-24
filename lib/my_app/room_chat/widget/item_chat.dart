import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matrix/matrix.dart';
import 'package:video_player/video_player.dart';

import '../../../ulti/date_converter.dart';

class ItemChat extends StatefulWidget {
  const ItemChat({
    super.key,
    required this.data,
    required this.typeMe,
    required this.showInfo,
    required this.showTimer,
  });

  final bool typeMe;
  final bool showInfo;
  final bool showTimer;
  final Event data;

  @override
  State<ItemChat> createState() => _ItemChatState();
}

class _ItemChatState extends State<ItemChat> {

  EdgeInsetsGeometry paddingItem = const EdgeInsets.symmetric(horizontal: 7, vertical: 7);
  EdgeInsetsGeometry padding = const EdgeInsets.only(left: 35, right: 7, bottom: 7);

  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController?.pause();
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.typeMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [

        if(widget.showTimer) timerWidget(),
        if((widget.showTimer || widget.showInfo) && !widget.typeMe) infoWidget(),
        Container(
            margin: padding,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.all(Radius.circular(10))
            ),
            child: contentWidget()
        ),
        // if(widget.data.statusLocal == MessageStatusLocal.sending || widget.data.statusLocal == MessageStatusLocal.sentFail)
        //   Padding(
        //     padding: padding,
        //     child: Text(widget.data.statusLocal == MessageStatusLocal.sending ? "Đang giử" : "Giử thất bại",
        //       style: const TextStyle(fontSize: 8),),
        //   ),
      ],
    );
  }

  Widget timerWidget(){
    return Padding(
      padding: paddingItem,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: Container(
            height: 1,
            color: Colors.grey,
            margin: const EdgeInsets.only(right: 15),
          )),
          Text(DateConverter.dateTimeSinceEpochMonthString(widget.data.originServerTs), style: const TextStyle(color: Colors.grey),),
          Expanded(child: Container(
            height: 1,
            color: Colors.grey,
            margin: const EdgeInsets.only(left: 15),
          )),
        ],
      ),
    );
  }

  Widget infoWidget(){
    return Padding(
      padding: paddingItem,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.all(Radius.circular(100))
            ),
          ),
          const SizedBox(width: 7,),
          Text(widget.data.senderFromMemoryOrFallback.displayName ?? "", style: const TextStyle(color: Colors.pinkAccent),),
          const SizedBox(width: 10),
          Text(DateConverter.dateTimeSinceEpochHourString(widget.data.originServerTs), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w400), ),
        ],
      ),
    );
  }

  Widget contentWidget(){
    switch(widget.data.type){
      case EventTypes.RoomMember: {
        return typeContentMember();
      }
      case EventTypes.Message: {
        return typeContentMessage();
      }
      // case MessageType.selectAnswer: {
      //   return Text("MessageType.selectAnswer");
      // }
      // case MessageType.callAnswer: {
      //   return Text("MessageType.callAnswer");
      // }
      // case MessageType.callHangup: {
      //   return Text("MessageType.callHangup");
      // }
      // case MessageType.callCandidates: {
      //   return Text("MessageType.callCandidates");
      // }
      // case MessageType.callNegotiate: {
      //   return Text("MessageType.callNegotiate");
      // }
      // case MessageType.callInvite: {
      //   return Text("MessageType.callInvite");
      // }
      // case MessageType.modularWidgets: {
      //   return Text("MessageType.modularWidgets");
      // }
      // case MessageType.encrypted: {
      //   return Text("MessageType.encrypted");
      // }
      // case MessageType.encryption: {
      //   return Text("MessageType.encryption");
      // }
      // case MessageType.name: {
      //   return Text("MessageType.name");
      // }
      // case MessageType.guestAccess: {
      //   return Text("MessageType.guestAccess");
      // }
      // case MessageType.historyVisibility: {
      //   return Text("MessageType.historyVisibility");
      // }
      // case MessageType.joinRules: {
      //   return Text("MessageType.joinRules");
      // }
      // case MessageType.powerLevels: {
      //   return Text("MessageType.powerLevels");
      // }
      // case MessageType.create: {
      //   return Text("MessageType.create");
      // }
    }
    return SizedBox(
        height: 40,
        child: Text(widget.data.type)
    );
  }

  Widget typeContentMessage() {
    switch(widget.data.content['msgtype']){
      case MessageTypes.Text: {
        return Material(
          color: Colors.black.withOpacity(0.1),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(widget.data.body)),
        );
      }
      case MessageTypes.Video: {
        String url = widget.data.getAttachmentUrl().toString();
        if(videoPlayerController == null){
          videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
          videoPlayerController!.initialize().then((_){
            setState(() {});
          });
        }
        videoPlayerController!.play();
        videoPlayerController!.setLooping(true);

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
            child: AspectRatio(
                    aspectRatio: videoPlayerController!.value.aspectRatio,
                    child: videoPlayerController!.value.isInitialized
                        ? VideoPlayer(videoPlayerController!)
                        : Container(
                            color: Colors.pink.withOpacity(0.1),
                            child: const Align(
                              alignment: Alignment.bottomCenter,
                              child: LinearProgressIndicator(
                              ),
                            ),
                          ),
                  ),
        );
      }
      case MessageTypes.Image: {
          String? url = widget.data.getAttachmentUrl()?.toString();
          return Container(
            color: Colors.pink.withOpacity(0.1),
            width: MediaQuery.of(context).size.width * 0.7,
            child: url == null 
                ? const SizedBox(height: 150, child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.redAccent,),
                  Text("Lỗi tải ảnh", style: TextStyle(color: Colors.redAccent, fontSize: 10,)),
                ],
              ),
            ),)
                : Image.network(
                    url, fit: BoxFit.fill,
                    loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress?.cumulativeBytesLoaded
                    != loadingProgress?.expectedTotalBytes
                    ? const SizedBox(
                        height: 150,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: LinearProgressIndicator(
                          ),
                        ),
                      )
                    : child,
                  ),
          );
      }
    }
    return const Text("message default");
   }


  Widget typeContentMember() {
    // switch(widget.data.content?.membership) {
    //   case MessageContentMemberType.invite:{
    //     return Text("${widget.data.sender} đã mời ${widget.data.content?.displayname} vào nhóm");
    //   }
    //   case MessageContentMemberType.join:{
    //     return Text("${widget.data.content?.displayname} đã tham gia phòng");
    //   }
    // }
    return const SizedBox(
        height: 40,
        child: Text("member default")
    );
  }
}
