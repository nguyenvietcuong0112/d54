import 'package:flutter/material.dart';

class AppColors {
  static const Color colorBgAds = Color(0xFF2c2c3e);
  static const Color textColor = Color(0xFFF1F4F9);
  static const Color textSecondaryColor = Color(0xFF6F7084);
  static const Color backgroundColor = Color(0xFF1B1B33);
  static const Color backgroundItemColor = Color(0xFF2c2c3e);
  static const Color main = Color(0xFFE3FC57);
  static const Color secondColor = Color(0xFF5D5D5D);
  static const Color blackText = Color(0xFF101E0E);
  static const Color grayText = Color(0xFFA4A4A4);
  static const Color greenText = Color(0xFF649C59);
  static const Color gray = Color(0xFFF5F5F5);
  static const Color gray1 = Color(0xFF686868);
  static const Color gray2 = Color(0xFFCACACA);
  static const Color colorPrimary = Color(0xFF9AE234);
  static const Color redPrimary = Color(0xFFE11B22);
  static const Color greenPrimary = Color(0xFF58BD7D);
  static const Color greenSecondary = Color(0xFF00C9BF);
  static const Color yellowPrimary = Color(0xFFF89434);
  static const Color yellowBorder = Color(0xFFFFCA28);
  static const Color  blueSecondary = Color(0xFF083F8C);
  static const Color  blueThird = Color(0xFF13B7DA);
  static const Color borderColor = Color(0xFFBABABA);

  static const Color bgInput = Color(0xFFF5F7F8);
  static const Color bgColor = Color(0xFFF4F7FF);
  static const Color bgTabColor = Color(0xFFE6EAEE);
  static const Color colorGradientButtonStart = Color(0xFF4D8FFF);
  static const Color colorGradientButtonEnd = Color(0xFF0F55C9);
  static const Color colorAppBarBlue = Color(0xFF083F8C);
  static const Color colorBgRelationship = Color(0xFF104590);

  static const Color textMain = Color(0xFF1D1D1D);
  static const Color textSub = Color(0xFF70728D);
  static const Color textSub1 = Color(0xFFD0D7DD);
  static const Color iconGray = Color(0xFF979797);
  static const Color transparent = Colors.transparent;

  static const Color dividerColor = Color(0xFFE4ECF2);

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // static const Color pageBackground = Color(0xFFFAFBFD);
  static const Color statusBarColor = Color(0xFF38686A);
  static const Color appBarColor = Color(0xFF38686A);
  static const Color appBarIconColor = Color(0xFFFFFFFF);
  static const Color appBarTextColor = Color(0xFFFFFFFF);

  static const Color centerTextColor = Colors.grey;
  static const MaterialColor colorPrimarySwatch = Colors.blue;

  // static const Color colorPrimary = Color(0xFF38686A);
  static const Color colorAccent = Color(0xFF38686A);
  static const Color colorLightGreen = Color(0xFF00EFA7);
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color lightGreyColor = Color(0xFFC4C4C4);
  static const Color errorColor = Color(0xFFAB0B0B);
  static const Color colorDark = Color(0xFF323232);

  static const Color buttonBgColor = colorPrimary;
  static const Color disabledButtonBgColor = Color(0xFFBFBFC0);
  static const Color defaultRippleColor = Color(0x0338686A);

  static const Color textColorPrimary = Color(0xFF323232);
  static const Color textColorSecondary = Color(0xFF9FA4B0);
  static const Color textColorTag = colorPrimary;
  static const Color textColorGreyLight = Color(0xFFABABAB);
  static const Color textColorGreyDark = Color(0xFF979797);
  static const Color textColorBlueGreyDark = Color(0xFF939699);
  static const Color textColorCyan = Color(0xFF38686A);
  static const Color textColorWhite = Color(0xFFFFFFFF);
  static Color searchFieldTextColor = const Color(0xFF323232).withOpacity(0.5);

  static const Color iconColorDefault = Colors.grey;

  static Color barrierColor = const Color(0xFF000000).withOpacity(0.5);

  static Color timelineDividerColor = const Color(0x5438686A);

  static const Color gradientStartColor = Colors.black87;
  static const Color gradientEndColor = Colors.transparent;
  static const Color silverAppBarOverlayColor = Color(0x80323232);

  static const Color switchActiveColor = colorPrimary;
  static const Color switchInactiveColor = Color(0xFFABABAB);
  static Color elevatedContainerColorOpacity = Colors.grey.withOpacity(0.5);
  static const Color suffixImageColor = Colors.grey;

  static const Color notiNewsColor = Color(0xFFFFF8E6);
  static const Color notiSaleColor = Color(0xFFFFE5E6);
  static const Color notiUpdateAppColor = Color(0xFFE8FBEF);
  static const Color notiSyncHistorySucccessColor = Color(0xFFE8FCFE);
  static const Color notiAppointmentConfirmedColor = Color(0xFFE8FCFE);
  static const Color notiAppointmentCommingColor = Color(0xFFF2F7FF);
  static const Color notiAppointmentResultColor = Color(0xFFE8FCFE);
  static const Color notiAppointmentAdvisedColor = Color(0xFFFFF8E6);
  static const Color notiAppointmentCanceledColor = Color(0xFFFFE2DB);

  static const Color appointmentCreatedColor = Color(0xFFFF8F1F);
  static const Color appointmentConfirmedColor = Color(0xFF58BD7D );
  static const Color appointmentProcessingColor = Color(0xFF136AFB);
  static const Color appointmentSuccessColor = Color(0xFF04C4D9);
  static const Color appointmentCanceledColor = Color(0xFFE11B22);

  static const Color monthColor = Color(0xFF87AFEF);

  static const Color baseColor = Color(0xFFE5E5E5);
  static const Color highlightColor = Color(0xFFE0E0E0);

  static Color hexToColor(String hex) {
    assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex), 'hex color must be #rrggbb or #rrggbbaa');

    return Color(
      int.parse(hex.substring(1), radix: 16) + (hex.length == 7 ? 0xff000000 : 0x00000000),
    );
  }
}
