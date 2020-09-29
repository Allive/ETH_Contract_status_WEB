class TBTCGeneralInfo {
  double tbtcTotalSupply;

  TBTCGeneralInfo({this.tbtcTotalSupply});

  factory TBTCGeneralInfo.fromJson(Map<String, dynamic> json) {
    return TBTCGeneralInfo(
      tbtcTotalSupply: json['TBTCtokenTotalSupply'],
    );
  }
}
