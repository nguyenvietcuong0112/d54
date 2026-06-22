import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/flavors/build_config.dart';
import '/flavors/env_config.dart';
import '/flavors/environment.dart';
import 'api_rest/my_http_overrides.dart';
import 'di.dart';
import 'helper/video_download_helper.dart';
import 'my_app.dart';

String separateDataString = "o_____o";


const bool isProduction = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VideoDownloadHelper.instance.initialize();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  await Firebase.initializeApp();

  EnvConfig config = isProduction
      ? EnvConfig(
          appName: "App",
          baseUrlAuthen: "",
          baseUrlUtility: "",
          baseUrlGraphQLCore: "",
          shouldCollectCrashLog: true,
        )
      : EnvConfig(
          appName: "App Dev",
          baseUrlAuthen: "",
          baseUrlUtility: "",
          baseUrlGraphQLCore: "",
          shouldCollectCrashLog: true,
        );

  BuildConfig.instantiate(
    envType: isProduction ? Environment.PRODUCTION : Environment.DEVELOPMENT,
    envConfig: config,
  );

  await DenpendencyInjection.init();
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}
