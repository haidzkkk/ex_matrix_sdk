
import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/model/slide.dart';
import '../screen/widget/slide_widget.dart';

void navigateToSlideWidget({required BuildContext context, required List<SlideMedia> medias}){
  Navigator.push(context, MaterialPageRoute(builder:
      (context) => SlideWidget.formMediaNetwork(
    medias: medias,
  )));
}

extension StringExt on String{
  String get firstDisplayName => split('').first.toUpperCase();

  bool containsNormalString(String str) {
    String myStr = removeDiacritics(this).toLowerCase();
    String strCompare = removeDiacritics(str).toLowerCase();
    return myStr.contains(strCompare);
  }
}