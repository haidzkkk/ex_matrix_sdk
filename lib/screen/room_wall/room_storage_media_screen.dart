import 'package:ex_sdk_matrix/screen/room_wall/room_wall_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/provider/room_provider.dart';

class RoomStorageMediaScreen extends StatefulWidget {
  const RoomStorageMediaScreen({super.key});

  @override
  State<RoomStorageMediaScreen> createState() => _RoomStorageMediaScreenState();
}

class _RoomStorageMediaScreenState extends State<RoomStorageMediaScreen> {

  late RoomWallStateProvider roomDetailState;
  late RoomProvider roomProvider = context.read<RoomProvider>();

  @override
  Widget build(BuildContext context) {
    // double ratioHeightItem = calculateHeightItemAssetGirdView(5, columnCount);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          // childAspectRatio: ratioHeightItem,
          mainAxisSpacing: 3
      ),
      shrinkWrap: true,
      key: const PageStorageKey("ccdc_transfer"),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsetsDirectional.all(3),
          color: Colors.red,
        );
      },
    );
  }
}
