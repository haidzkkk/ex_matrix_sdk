import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';

class HomeDartSdkScreen extends StatefulWidget {
  const HomeDartSdkScreen({Key? key}) : super(key: key);

  @override
  _HomeDartSdkScreenState createState() => _HomeDartSdkScreenState();
}

class _HomeDartSdkScreenState extends State<HomeDartSdkScreen> {
  void _logout() async {
    final client = Provider.of<Client>(context, listen: false);
    await client.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  void _join(Room room) async {
    if (room.membership != Membership.join) {
      await room.join();
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        leadingWidth: 0,
        title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.w600),),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: client.onSync.stream,
        builder: (context, _) => ListView.builder(
          itemCount: client.rooms.length,
          itemBuilder: (context, i) => ListTile(
            leading: CircleAvatar(
              foregroundImage: client.rooms[i].avatar == null
                  ? null
                  : NetworkImage(client.rooms[i].avatar!
                  .getThumbnail(
                client,
                width: 56,
                height: 56,
              ).toString()),
            ),
            title: Row(
              children: [
                Expanded(child: Text(client.rooms[i].getLocalizedDisplayname())),
                if (client.rooms[i].notificationCount > 0)
                  Material(
                      borderRadius: BorderRadius.circular(99),
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child:
                        Text(client.rooms[i].notificationCount.toString()),
                      ))
              ],
            ),
            subtitle: Text(
              client.rooms[i].lastEvent?.body ?? 'No messages',
              maxLines: 1,
            ),
            onTap: () => _join(client.rooms[i]),
          ),
        ),
      ),
    );
  }
}

class RoomPage extends StatefulWidget {
  final Room room;
  const RoomPage({required this.room, Key? key}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late final Future<Timeline> _timelineFuture;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _count = 0;

  @override
  void initState() {
    _timelineFuture = widget.room.getTimeline(onChange: (i) {
      print('on change! $i');
      _listKey.currentState?.setState(() {});
    }, onInsert: (i) {
      print('on insert! $i');
      _listKey.currentState?.insertItem(i);
      _count++;
    }, onRemove: (i) {
      print('On remove $i');
      _count--;
      _listKey.currentState?.removeItem(i, (_, __) => const ListTile());
    }, onUpdate: () {
      print('On update');
    });
    super.initState();
  }

  final TextEditingController _sendController = TextEditingController();

  void _send() {
    widget.room.sendTextEvent(_sendController.text.trim());
    _sendController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.displayname),
        actions: [
          IconButton(
              onPressed: (){

              },
              icon: const Icon(Icons.videocam, size: 30,))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Timeline>(
                future: _timelineFuture,
                builder: (context, snapshot) {
                  final timeline = snapshot.data;
                  if (timeline == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  _count = timeline.events.length;
                  return Column(
                    children: [
                      Center(
                        child: TextButton(
                            onPressed: timeline.requestHistory,
                            child: const Text('Load more...')),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          reverse: true,
                          initialItemCount: timeline.events.length,
                          itemBuilder: (context, i, animation) => timeline
                              .events[i].relationshipEventId !=
                              null
                              ? Container()
                              : ScaleTransition(
                            scale: animation,
                            child: Opacity(
                              opacity: timeline.events[i].status.isSent
                                  ? 1
                                  : 0.5,
                              child: ListTile(
                                trailing: GestureDetector(
                                    onTap: (){
                                      timeline.events[i].downloadAndDecryptAttachment();
                                    },
                                    child: const Icon(Icons.download)
                                ),
                                leading: Container(
                                  width: 56,
                                  height: 56,
                                  clipBehavior: Clip.hardEdge,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      borderRadius: BorderRadius.all(Radius.circular(1000))
                                  ),
                                  child: timeline.events[i]
                                      .sender.avatarUrl ==
                                      null
                                      ? Text(timeline.events[i]
                                      .sender.calcDisplayname().split('').first.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24),)
                                      : Image.network(timeline
                                      .events[i].sender.avatarUrl!
                                      .getThumbnail(
                                    widget.room.client,
                                    width: 56,
                                    height: 56,
                                  )
                                      .toString()),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(timeline
                                          .events[i].sender
                                          .calcDisplayname()),
                                    ),
                                    Text(
                                      timeline.events[i].originServerTs
                                          .toIso8601String(),
                                      style:
                                      const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                                subtitle: Builder(
                                    builder: (context) {
                                      if(timeline.events[i].type == EventTypes.Encrypted){
                                        return FutureBuilder(
                                          future: timeline.events[i].room.client.encryption
                                              ?.decryptRoomEvent(timeline.events[i].room.id, timeline.events[i]),
                                          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                            return Text("decrypt msg: ${snapshot.hasData ? (snapshot.data as Event).body : ""}");
                                          },
                                        );
                                      }
                                      return Text(timeline.events[i].getDisplayEvent(timeline).body);
                                    }
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: _sendController,
                        decoration: const InputDecoration(
                          hintText: 'Send message',
                        ),
                      )),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
