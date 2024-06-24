
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'my_voip_app.dart';

class RoomCallScreen extends StatefulWidget {
  const RoomCallScreen({super.key, required this.room, required this.remoteUserId, required this.isCallVideo});

  final String? remoteUserId;
  final Room room;
  final bool isCallVideo;

  @override
  State<RoomCallScreen> createState() => _RoomCallScreenState();
}

class _RoomCallScreenState extends State<RoomCallScreen> {

  late final Client client;
  late VoIP voip;
  late CallSession newCall;

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  void init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    await startCall();
  }

  startCall() async{
    voip = VoIP(client, MyVoipApp());

    newCall = await voip.inviteToCall(
        widget.room,
        CallType.kVideo,
        userId: widget.remoteUserId
    );

    newCall.onCallStateChanged.stream.listen((state) {

      _remoteRenderer.srcObject = newCall.remoteUserMediaStream?.stream;
      setState(() { });
    });

    _localRenderer.srcObject = newCall.localUserMediaStream?.stream;
    setState(() { });
  }

  @override
  void initState() {
    client = Provider.of<Client>(context, listen: false);
    super.initState();
    init();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    newCall.deleteAllStreams();
    newCall.cleanUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.room.avatar?.getThumbnail(widget.room.client, width: 56, height: 56,).toString() ?? "";

    return Scaffold(
      backgroundColor: Colors.white10,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: generateColorAvatar(),
              builder: (context, snapshot) {
                return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                      begin: const Alignment(0, 1),
                      colors: [
                        (snapshot.data ?? Colors.white).withOpacity(0.3),
                        Colors.black26,
                      ]
                    )
                  ),
                );
              }
            ),
            Positioned.fill(
              child: RTCVideoView(_remoteRenderer),
            ),
            Positioned(
              top: 90,
              right: 10,
              child: SizedBox(
                  height: 100,
                  width: 100,
                  child: RTCVideoView(_localRenderer)
              ),
            ),
            Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.all(Radius.circular(100))
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 100,
                width: 100,
                errorBuilder: (_, __, ___){
                  return Text(widget.room.getLocalizedDisplayname().split('').first.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
                  );
                },
              ),
            ),
            AppBar(
                leading: const BackButton(color: Colors.white,),
                backgroundColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Video call with ${widget.room.getLocalizedDisplayname()}",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white
                      ),
                    ),
                    const Text("Call ringing...",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
                actions: [
                  GestureDetector(
                    onTap: (){

                    },
                    child: const Padding(
                        padding: EdgeInsetsDirectional.all(10),
                        child: Icon(Icons.chat_sharp, size: 27, color: Colors.white,)
                    ),
                  ),
                ]
            ),
            
            Positioned(
              bottom: 10,
              child: Row(
                children: [
                  actionButton(
                      icon: Icons.videocam,
                      onTap: (){

                      }
                  ),
                  actionButton(
                      icon: Icons.volume_down,
                      onTap: (){

                      }
                  ),
                  actionButton(
                      icon: Icons.mic,
                      onTap: (){

                      }
                  ),
                  actionButton(
                      icon: Icons.call_end,
                      color: Colors.redAccent,
                      onTap: (){

                      }
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  
  Widget actionButton({required IconData icon, Color? color, required Function() onTap}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsetsDirectional.all(8),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(100))
        ),
        child: Icon(icon, color: color != null ? Colors.white : null, size: 30,),
      ),
    );
  }

  Future<Color?> generateColorAvatar() async{
    String imageUrl = widget.room.avatar?.getThumbnail(widget.room.client, width: 56, height: 56,).toString() ?? "";
    PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(imageUrl));

    if(paletteGenerator.vibrantColor != null){
      return paletteGenerator.vibrantColor!.color;
    }else if(paletteGenerator.dominantColor != null){
      return paletteGenerator.dominantColor!.color;
    }else if(paletteGenerator.mutedColor != null){
      return paletteGenerator.mutedColor!.color;
    }
    return null;
  }
}
