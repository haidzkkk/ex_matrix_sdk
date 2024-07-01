
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    Client client = Provider.of<Client>(context, listen: false);

    return FutureBuilder(
        future: client.getProfileFromUserId(client.userID ?? ""),
        builder: (context, snapshot) {

          int totalBadgets = 0;
          for (var room in client.rooms) {
            totalBadgets += room.notificationCount;
          }

          return Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.all(Radius.circular(100))
                ),
                margin: const EdgeInsetsDirectional.all(5),
                child: Image.network(
                  snapshot.data?.avatarUrl?.getThumbnail(client, width: 56, height: 56,).toString() ?? "",
                  errorBuilder: (_, __, ___){
                    return Text(snapshot.data?.displayName?.split('').first.toUpperCase() ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                    );
                  },
                ),
              ),
              if(totalBadgets > 0)
                Positioned(
                    right: 5,
                    top: 5,
                    child: Badge(
                      label: Text(totalBadgets.toString()),
                    )
                ),
            ],
          );
        }
    );
  }
}
