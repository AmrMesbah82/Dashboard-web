/// ******************* FILE INFO *******************
/// File Name: custom_grid_view.dart
/// Description: this is custom grid view for handel number of item
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025


import 'package:flutter/cupertino.dart';

abstract class CrossAxisCountHelper {
  static int getCrossAxisCountForDefaultTablet2(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 2200) {
      return 5;
    } else if (screenWidth > 1681) {
      return 4;
    } else if (screenWidth <= 1681 && screenWidth > 1033) {
      return 3;
    } else if (screenWidth > 600 && screenWidth < 1033) {
      return 2;
    }
    return 1;

  }
}
