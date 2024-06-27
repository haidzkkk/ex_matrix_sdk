
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late Client client;

  @override
  void initState() {

    client = Provider.of<Client>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.greenAccent,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [

            const TextField(),
            StreamBuilder(
                stream: client.onSync.stream,
                builder: (BuildContext context, snapshot){
                  return Expanded(
                      child: ListView(
                          children: client.rooms.map((e) => Text(
                              "${e.getLocalizedDisplayname()} - ${e.lastEvent?.body ?? 'No messages'}"
                          )).toList()
                      )
                  );
                }
            )
          ],
        ),
      ),
    );
  }
}
