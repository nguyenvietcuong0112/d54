import 'package:cscmobi_app/screens/language/language_binding.dart';
import 'package:cscmobi_app/screens/language/language_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../screens/splash/splash_binding.dart';
import '../screens/splash/splash_page.dart';

part 'app_routes.dart';

class RouteEntry<T extends GetxController> {
  final T Function() controllerBuilder;
  final Widget Function() pageBuilder;

  const RouteEntry({
    required this.controllerBuilder,
    required this.pageBuilder,
  });
}

extension GetXNavigationWithControllerExtension on GetInterface {
  Future<T?> toWithController<T, C extends GetxController>({
    required C Function() controllerBuilder,
    required Widget Function() page,
    dynamic arguments,
  }) async {
    Get.lazyPut<C>(controllerBuilder);
    return await Get.to<T>(page, arguments: arguments);
  }

  Future<T?> toWithController2<T, C extends GetxController>({
    required C controllerBuilder,
    required Widget Function() page,
    dynamic arguments,
  }) async {
    Get.put<C>(controllerBuilder);
    return await Get.to<T>(page, arguments: arguments);
  }

  Future<T?> offWithController<T, C extends GetxController>({
    required C Function() controllerBuilder,
    required Widget Function() page,
    dynamic arguments,
  }) async {
    Get.lazyPut<C>(controllerBuilder);
    return await Get.off<T>(page, arguments: arguments);
  }

  Future<T?> offAllWithController<T, C extends GetxController>({
    required C Function() controllerBuilder,
    required Widget Function() page,
    dynamic arguments,
  }) async {
    Get.lazyPut<C>(controllerBuilder);
    return await Get.offAll<T>(page, arguments: arguments);
  }
}

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static int aniDuration = 400;
  static int aniDurationHome = 600;
  static Transition aniTransision = Transition.cupertino;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
    GetPage(
      name: AppRoutes.LANGUAGE,
      page: () => LanguagePage(),
      binding: LanguageBinding(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDurationHome),
    ),
  ];
}
