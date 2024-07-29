
import 'package:dots_indicator/dots_indicator.dart';
import 'package:ex_sdk_matrix/screen/widget/image_widget.dart';
import 'package:ex_sdk_matrix/screen/widget/video_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/slide.dart';
import '../../ultis/color_resources.dart';

class SlideWidget extends StatefulWidget {
  const SlideWidget({
    super.key,
    this.initPosition,
    required this.children,
  });

  factory SlideWidget.formMediaNetwork({int? initPosition, required List<SlideMedia> medias}){
    var items  = medias.map((media) {
      if(media.type == SlideType.image){
        return ImageWidget(url: media.url, hero: media.url,);
      }else if(media.type == SlideType.video){
        return VideoWidget(url: media.url, thumb: media.thumb ?? "",);
      }
      return const Center(child: Text("Lỗi không tìm thấy tài nguyên"));
    }
    ).toList();

    return SlideWidget(
      initPosition: initPosition,
      children: items
    );
  }

  final int? initPosition;
  final List<Widget> children;

  @override
  State<SlideWidget> createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<SlideWidget> {

  late int currentPosition = widget.initPosition ?? 0;
  late PageController pageController = PageController(initialPage: currentPosition);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopupWidget(
        currentPosition: currentPosition,
        totalPosition: widget.children.length,
        onTap: (){

        },
        onTapOption: (){

        },
        onDoubleTap: (){

        },
        child: PageView.builder(
          controller: pageController,
          itemCount: widget.children.length,
          onPageChanged: (value){
            currentPosition = value;
            setState(() {});
          },
          itemBuilder: (context, index){
            return widget.children[index];
          }
        ),
      ),
    );
  }
}

class PopupWidget extends StatefulWidget {
  const PopupWidget({super.key,
    required this.child,
    required this.currentPosition,
    required this.totalPosition,
    this.onTapOption,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final Widget child;
  final int currentPosition;
  final int totalPosition;
  final Function()? onTapOption;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function()? onLongPress;

  @override
  State<PopupWidget> createState() => _PopupWidgetState();
}

class _PopupWidgetState extends State<PopupWidget> {

  bool isZoom = false;

  bool isShow = true;

  double initialPositionY = 0;
  double currentPositionY = 0;
  double positionYDelta = 0;
  double disposeLimit = 100;
  Duration animationDuration = Duration.zero;

  void _startVerticalDrag(details) {
    setState(() {
      initialPositionY = details.globalPosition.dy;
    });
  }

  _endVerticalDrag(DragEndDetails details) {

    /// start position - end position > position dispose
    if (positionYDelta > disposeLimit || positionYDelta < -disposeLimit) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        animationDuration = const Duration(milliseconds: 300);
        positionYDelta = 0;
      });

      Future.delayed(animationDuration).then((_){
        setState(() {
          animationDuration = Duration.zero;
        });
      });
    }
  }

  void _whileVerticalDrag(details) {
    setState(() {
      currentPositionY = details.globalPosition.dy;
      positionYDelta = currentPositionY - initialPositionY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(widget.onTap != null) widget.onTap!();
        setState(() {
          isShow = !isShow;
        });
      },
      onDoubleTap: () {
        if(widget.onDoubleTap != null) widget.onDoubleTap!();
        setState(() {
          isZoom = !isZoom;
        });
      },
      onLongPress: widget.onLongPress,
      onVerticalDragStart: (details) => _startVerticalDrag(details),
      onVerticalDragUpdate: (details) => _whileVerticalDrag(details),
      onVerticalDragEnd: (details) => _endVerticalDrag(details),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black
        ),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            AnimatedPositioned(
              duration: animationDuration,
              curve: Curves.fastOutSlowIn,
              top: 0 + positionYDelta,
              bottom: 0 - positionYDelta,
              left: 0,
              right: 0,
              child: Transform.scale(
                scale: isZoom ? 2 : 1,
                child: widget.child
              ),
            ),
            AppBar(
              backgroundColor: Colors.transparent,
              leading: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isShow ? 1 : 0,
                  child: GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back_sharp, color: ColorResources.iconColorReverser,)
                  )
              ),
              actions: [
                if(widget.onTapOption != null)
                  AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isShow ? 1 : 0,
                      child: GestureDetector(
                          onTap: (){
                            widget.onTapOption!();
                          },
                          child: const Icon(Icons.more_vert_rounded, color: ColorResources.iconColorReverser,)
                      )
                  ),
                const SizedBox(width: 10,),
              ],
            ),
            if(widget.totalPosition > 1)
              Positioned(
                bottom: 10,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isShow ? 1 : 0,
                  child: DotsIndicator(
                    dotsCount: widget.totalPosition,
                    position: widget.currentPosition,
                    decorator: const DotsDecorator(
                      color: Colors.grey,
                      activeColor: ColorResources.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
