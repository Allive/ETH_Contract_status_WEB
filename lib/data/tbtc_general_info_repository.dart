import 'package:dio/dio.dart';
import 'package:keep_deposit_explorer/model/tbtc_general_info.dart';

class TBTCGeneralInfoRepository {
  Future<TBTCGeneralInfo> getGeneralInfo() async {
    var response = await Dio().get<Map<String, dynamic>>(_tbtcGeneralInfoPath,
        options: Options(receiveTimeout: 5000));

    if (response.statusCode == 200)
      return TBTCGeneralInfo.fromJson(response.data);
    else
      throw Exception();
  }

  String _tbtcGeneralInfoPath =
      'https://keep-deposit.com:9443/API/tbtcGeneralInfo';
}
