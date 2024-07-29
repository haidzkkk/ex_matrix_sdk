
enum SlideType{
  image,
  video;
}

class SlideMedia{
  final String url;
  final SlideType type;
  String? thumb;

  SlideMedia({
    required this.url,
    required this.type,
    this.thumb
  });
}