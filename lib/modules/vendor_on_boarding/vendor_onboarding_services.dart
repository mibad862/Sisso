import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/error_codes/error_codes.dart';
import '../../services/service_config.dart';

class VendorOnBoardingServices {
  VendorOnBoardingServices();

  Future<ErrorType> updateVendorInformation(String token, Map data) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(token);
      final serverConfig = ServerConfig();
      final platform = serverConfig.platform;
      final endpoint = '${serverConfig.url}/wp-json/vendor-admin/profile';
      final response = await http.put(
        endpoint.toUri()!,
        body: {
          'token': base64Str,
          'data': jsonEncode(data),
          'platform': platform,
        },
      );
      if (jsonDecode(response.body)['response'] == 1) {
        return ErrorType.updateSuccess;
      }
      printLog('vendor_onboarding_services.dart: ${response.body}');
      return ErrorType.updateFailed;
    } catch (e) {
      printLog('vendor_onboarding_services.dart: $e');
      return ErrorType.updateFailed;
    }
  }

  Future<String> getAddressFromLocation(double? lat, double? long) async {
    final response = await http.get(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=${isIos ? kGoogleApiKey.ios : kGoogleApiKey.android}'
          .toUri()!,
    );
    final result = jsonDecode(response.body)['results'];
    return result.isNotEmpty ? result.first['formatted_address'] : '';
  }
}
