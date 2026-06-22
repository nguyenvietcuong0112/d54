import 'dart:convert';
import 'dart:io';
import 'package:cscmobi_app/models/download_model.dart';
import 'package:cscmobi_app/models/response_model.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../core/model/base_model/base_rest_model.dart';
import '../core/network/base_rest/base_provider.dart';
import '../core/utils/app_util.dart';
import '../core/values/constants.dart';
import '../flavors/build_config.dart';
import '../flavors/environment.dart';

class ApiRepository extends BaseProvider {
  static String baseAPIAuth = BuildConfig.instance.config.baseUrlAuthen;
  static String baseAPIUtility = BuildConfig.instance.config.baseUrlUtility;
  String urlGSMDev = 'https://gsmdev.cscmobicorp.com';
  String urlGSMProd = 'https://gsm.cscmobicorp.com';
  String GSMAppID = '6a0c0d53dbf0252967ec4837';
  //Auth
  String urlLoginAPP = '$baseAPIAuth/user/getOtp';
  String urlVerifyOTP = '$baseAPIAuth/user/verifyOtp';
  String urlLogoutAPP = '$baseAPIAuth/user/logout';
  String urlRefreshToken = '$baseAPIAuth/user/refresh-token';

  //Ultility
  String urlUploadAvatar = '$baseAPIUtility/fileUpload/uploadAvatar';

  //downloadURL
  String downloadUrlAPI = "http://20.198.254.31:7002/download";
  String downloadTiktokAPI = "http://20.198.254.31:7002/tiktok";


  String urlLogin = '/api/auth/login';
  String urlverifyIAP = '/api/iap/check';

  ApiRepository() {
    timeout = const Duration(seconds: 60);
  }

  getBaseUrlGSM() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      return urlGSMProd;
    } else {
      return urlGSMDev;
    }
  }

  Future<ResponseModel> sendPostRequestDownloadTiktok(String url) async {
    // Dữ liệu JSON bạn muốn gửi (có thể là Map<String, dynamic>)
    Map<String, dynamic> jsonBody = {
      "url": url,
    };
    try {
      final response = await http.post(
        Uri.parse(downloadTiktokAPI),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonBody),
      );
      // Kiểm tra kết quả
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonResponse = jsonDecode(response.body);
        DownloadModel video = DownloadModel.fromJson(jsonResponse);
        return ResponseModel(code: 200, message: "Success", data: jsonResponse);
      } else {
        dynamic jsonResponse = jsonDecode(response.body);
        return ResponseModel(code: 400, message: jsonResponse['detail'] ?? "Error", data: null);
      }
    } catch (e) {
      return ResponseModel(code: 400, message: e.toString(), data: null);
    }
  }

  Future<ResponseModel> sendPostRequestDownloadUrl(String url) async {
    // Dữ liệu JSON bạn muốn gửi (có thể là Map<String, dynamic>)
    Map<String, dynamic> jsonBody = {
      "url": url,
    };
    try {
      final response = await http.post(
        Uri.parse(downloadUrlAPI),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonBody),
      );
      // Kiểm tra kết quả
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonResponse = jsonDecode(response.body);
        DownloadModel video = DownloadModel.fromJson(jsonResponse);
        return ResponseModel(code: 200, message: "Success", data: jsonResponse);
      } else {
        dynamic jsonResponse = jsonDecode(response.body);
        return ResponseModel(code: 400, message: jsonResponse['detail'] ?? "Error", data: null);
      }
    } catch (e) {
      return ResponseModel(code: 400, message: e.toString(), data: null);
    }
  }

  requestGSMLogin() async {
    String appVersionName = await AppUtil().getAppVersion();
    Map requestBody = {
      'appId': GSMAppID,
      'deviceId': await AppUtil().getDeviceId(),
      'pkName': 'com.video.downloader.fastsave',
      'os': Platform.isIOS ? 2 : 1,
      'version': appVersionName,
    };
    return await sendRequestPostGSM(getBaseUrlGSM() + urlLogin, requestBody);
  }

  sendRequestPostGSM(String url, dynamic requestBody) async {
    if (await checkNetwork()) {
      var finalURI = Uri.parse(url);
      String encodedBody = json.encode(requestBody);
      AppUtil.showLogFull("ApiRepository sendRequestPostGSM encodedBody: $encodedBody");
      final res = await http.post(finalURI, body: encodedBody, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Connection': 'keep-alive',
        'Authorization': Constants.GSMAccessToken != null ? 'Bearer ${Constants.GSMAccessToken!}' : '',
      });
      try {
        if (res != null) {
          AppUtil.showLogFull("ApiRepository _sendPost response: " + jsonEncode(res.body));
          if (res.statusCode == 200) {
            AppUtil.showLog("ApiRepository _sendPost statusCode 200");
            return res.body;
          } else {
            AppUtil.showLog("ApiRepository _sendPost Không có dữ liệu: res.statusCode: ${res.statusCode}");
            return null;
          }
        } else {
          AppUtil.showLog("ApiRepository sendPost response: NULL");
        }
      } catch (e) {
        AppUtil.showLog("ApiRepository sendPost ERROR" + e.toString());
      }
    } else {
      // AppUtil.showToast('msg_no_connection'.tr);
    }
  }

  Future<bool> checkNetwork() async {
    bool isConnected = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }
}
