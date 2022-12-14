import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppFonts {
  // 리스트 뷰 아이템 폰트
  static const listViewMain = TextStyle(color: AppColors.textBlack, fontSize: 15);
  static const listViewSub = TextStyle(color: AppColors.textGray, fontSize: 13);
  // 하단 플로팅 버튼
  static const floatingName = TextStyle(color: AppColors.white, fontSize: 14);
  // 옵션 내정보
  static const myInfoId = TextStyle(color: AppColors.textBlack, fontSize: 16, fontWeight: FontWeight.bold);
  static const myInfoName = TextStyle(color: AppColors.textBlack, fontSize: 16, fontWeight: FontWeight.bold);
  static const myInfoOut = TextStyle(color: Colors.blueAccent, fontSize: 16);
  // 옵션 구독
  static const myInfoChannel = TextStyle(color: AppColors.textBlack, fontSize: 20, fontWeight: FontWeight.bold);
  static const myInfoChannelChecked = TextStyle(color: AppColors.textGray, fontSize: 20, decoration: TextDecoration.lineThrough);
}