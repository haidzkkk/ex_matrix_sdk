
import 'package:ex_sdk_matrix/screen/widget/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
    required this.url,
    required this.thumb,
  });

  final String url;
  final String thumb;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {

  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    videoPlayerController.initialize().then((_){
      setState(() {});
    });
    videoPlayerController.play();
    videoPlayerController.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.pause();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: videoPlayerController.value.aspectRatio,
      child: videoPlayerController.value.isInitialized
          ? VideoPlayer(videoPlayerController)
          : ImageWidget(url: widget.thumb,),
    );
  }
}
