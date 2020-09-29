enum DepositStatus {
  START,
  AWAITING_SIGNER_SETUP,
  AWAITING_BTC_FUNDING_PROOF,
  FAILED_SETUP,
  ACTIVE,
  AWAITING_WITHDRAWAL_SIGNATURE,
  AWAITING_WITHDRAWAL_PROOF,
  REDEEMED,
  COURTESY_CALL,
  FRAUD_LIQUIDATION_IN_PROGRESS,
  LIQUIDATION_IN_PROGRESS,
  LIQUIDATED
}

class DepositStatusParser {
  static DepositStatus fromString(String str) {
    return DepositStatus.values
        .firstWhere((e) => e.toString() == 'DepositStatus.' + str);
  }
}
