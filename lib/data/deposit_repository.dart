import 'package:dio/dio.dart';
import 'package:keep_deposit_explorer/model/deposit.dart';

class DepositRepository {
  static DepositRepository _instance;

  factory DepositRepository() => _instance ??= new DepositRepository._();

  DepositRepository._();

  Future<List<Deposit>> getRecentDeposits() async {
    var response = await Dio().get<Map<String, dynamic>>(_depositsInfoPath,
        options: Options(receiveTimeout: 5000));

    List<Deposit> result = List.empty(growable: true);
    if (response.statusCode == 200) {
      (response.data['deposits'] as List<dynamic>).forEach((element) {
        result.add(Deposit.fromJson(element));
      });
      return result;
    }
    else
      throw Exception();
  }

  final _depositsInfoPath = 'https://keep-deposit.com:9443/API/depositsInfo';
}
