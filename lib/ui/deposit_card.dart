import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keep_deposit_explorer/model/deposit_status.dart';
import 'package:keep_deposit_explorer/model/deposit.dart';
import 'package:keep_deposit_explorer/ui/constants/app_colors.dart';

import 'app_icons.dart';

class DepositCard extends StatefulWidget {
  final Deposit _deposit;

  DepositCard(this._deposit, Key key): super(key: key);

  @override
  State<StatefulWidget> createState() => DepositCardState(_deposit);
}

class DepositCardState extends State<DepositCard> {
  final Deposit _deposit;
  bool _isHighlighted = false;

  DepositCardState(this._deposit);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: InkWell(
            onTap: () {
              if (_isHighlighted)
                _unHighlightBottomCard();
              else
                _highlightBottomCard();
            },
            onHover: (isHovering) {
              if (isHovering)
                _highlightBottomCard();
              else
                _unHighlightBottomCard();
            },
            child: Stack(children: [
              Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                    top: 12,
                  ),
                  child: _createHighlightingBottomCard()),
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  bottom: 12,
                ),
                child: _createMainCard(),
              )
            ])));
  }

  Widget _createMainCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(width: 2, color: AppColors.primaryColor)),
      color: AppColors.darkBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          height: 110,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 10,
                child: _chooseStatusIcon(_deposit.status),
              ),
              Positioned(
                  left: 30,
                  top: 10,
                  child: Row(
                    children: [
                      _getDepositText(),
                      _getCopyIcon(_deposit.depositAddress),
                    ],
                  )),
              Positioned(
                  left: 30,
                  bottom: 31,
                  child: Row(children: [
                    _getKEEPAddressText(),
                    _getCopyIcon(_deposit.keepAddress),
                  ])),
              Positioned(
                left: 30,
                bottom: 7,
                child: Row(
                  children: [
                    _getTransactionHashText(),
                    _getCopyIcon(_deposit.transactionHash)
                  ],
                ),
              ),
              Positioned(right: 8, top: 0, child: _getAgeText()),
              Positioned(right: 8, bottom: 0, child: _getAmountText()),
            ],
          ),
        ),
      ),
    );
  }

  Text _getAgeText() {
    Duration transactionAge =
        DateTime.now().difference(_deposit.transactionDateTime);
    String durationString = _durationToString(transactionAge);
    String data = kIsWeb ? '$durationString ago' : durationString;

    return Text(
      data,
      style: _getAgeTextStyle(),
    );
  }

  String _durationToString(Duration duration) {
    if (duration.inDays > 365 * 2)
      return "${duration.inDays / 365} years";
    else if (duration.inDays > 365)
      return "1 year";
    else if (duration.inDays > 60)
      return "${duration.inDays / 30} months";
    else if (duration.inDays > 30)
      return "1 month";
    else if (duration.inDays == 1)
      return "1 day";
    else if (duration.inDays > 0)
      return "${duration.inDays} days";
    else if (duration.inHours == 1)
      return "1 hour";
    else if (duration.inHours > 0)
      return "${duration.inHours} hours";
    else if (duration.inMinutes == 1) return "${duration.inHours} min";

    return "${duration.inMinutes} mins";
  }

  Text _getDepositText() {
    String data = 'Deposit: ' +
        (kIsWeb
            ? _deposit.depositAddress
            : '${_deposit.depositAddress.substring(0, _deposit.depositAddress.length ~/ 2)}\n'
                '${_deposit.depositAddress.substring(_deposit.depositAddress.length ~/ 2, _deposit.depositAddress.length)}');

    return Text(
      data,
      style: _getDepositTextStyle(),
    );
  }

  Text _getKEEPAddressText() {
    int keepAddressLength = _deposit.keepAddress.length;
    String data = 'KEEP: ' +
        (kIsWeb
            ? _deposit.keepAddress
            : _deposit.keepAddress
                .replaceRange(12, keepAddressLength - 12, '...'));
    return Text(
      data,
      style: _getKEEPAddressTextStyle(),
    );
  }

  Text _getTransactionHashText() {
    int transactionHashLength = _deposit.transactionHash.length;
    String data = 'Tx hash: ' +
        (kIsWeb
            ? _deposit.transactionHash
            : _deposit.transactionHash
                .replaceRange(12, transactionHashLength - 12, '...'));

    return Text(
      data,
      style: _getTransactionHashTextStyle(),
    );
  }

  Text _getAmountText() {
    String data = (kIsWeb ? '${_deposit.amount} tBTC' : '${_deposit.amount}');

    return Text(
      data,
      style: _getAmountTextStyle(),
    );
  }

  String _getStatusText() {
    return _deposit.status
        .toString()
        .split('.')[1]
        .toLowerCase()
        .replaceAll("_", " ");
  }

  TextStyle _getKEEPAddressTextStyle() {
    if (kIsWeb)
      return TextStyle(
        color: AppColors.primaryColor,
        fontSize: 18,
      );
    else
      return TextStyle(
        color: AppColors.primaryColor,
        fontSize: 12,
      );
  }

  TextStyle _getTransactionHashTextStyle() {
    if (kIsWeb)
      return TextStyle(
        color: AppColors.primaryColor,
        fontSize: 18,
      );
    else
      return TextStyle(
        color: AppColors.primaryColor,
        fontSize: 12,
      );
  }

  TextStyle _getDepositTextStyle() {
    if (kIsWeb)
      return TextStyle(
        color: AppColors.primaryColor,
        fontSize: 18,
      );
    else
      return TextStyle(
        color: AppColors.primaryColor,
        fontSize: 12,
      );
  }

  TextStyle _getAgeTextStyle() {
    if (kIsWeb)
      return TextStyle(color: AppColors.primaryColor, fontSize: 30);
    else
      return TextStyle(color: AppColors.primaryColor, fontSize: 20);
  }

  TextStyle _getAmountTextStyle() {
    if (kIsWeb)
      return TextStyle(color: AppColors.primaryColor, fontSize: 48);
    else
      return TextStyle(color: AppColors.primaryColor, fontSize: 32);
  }

  double _getCardSize() {
    if (kIsWeb) return 155;

    return 120;
  }

  Icon _chooseStatusIcon(DepositStatus depositStatus) {
    switch (depositStatus) {
      case DepositStatus.START:
        return Icon(
          Icons.adjust,
          color: Colors.grey,
          size: _getIconSize(),
        );
      case DepositStatus.AWAITING_BTC_FUNDING_PROOF:
      case DepositStatus.AWAITING_SIGNER_SETUP:
      case DepositStatus.AWAITING_WITHDRAWAL_SIGNATURE:
        return Icon(
          AppIcons.ic_waiting,
          color: AppColors.warningColor,
          size: _getIconSize(),
        );
      case DepositStatus.AWAITING_WITHDRAWAL_PROOF:
      case DepositStatus.ACTIVE:
        return Icon(
          Icons.done,
          color: AppColors.successColor,
          size: _getIconSize(),
        );
      case DepositStatus.REDEEMED:
        return Icon(
          Icons.done_all,
          color: AppColors.successColor,
          size: _getIconSize(),
        );
      case DepositStatus.FAILED_SETUP:
      case DepositStatus.COURTESY_CALL:
      case DepositStatus.FRAUD_LIQUIDATION_IN_PROGRESS:
      case DepositStatus.LIQUIDATION_IN_PROGRESS:
      case DepositStatus.LIQUIDATED:
        return Icon(Icons.close,
            color: AppColors.errorColor, size: _getIconSize());
      default:
        throw ArgumentError.value(depositStatus);
    }
  }

  Color _getStatusColor(DepositStatus depositStatus) {
    switch (depositStatus) {
      case DepositStatus.START:
        return Colors.grey;
      case DepositStatus.AWAITING_BTC_FUNDING_PROOF:
      case DepositStatus.AWAITING_SIGNER_SETUP:
      case DepositStatus.AWAITING_WITHDRAWAL_PROOF:
      case DepositStatus.AWAITING_WITHDRAWAL_SIGNATURE:
        return AppColors.warningColor;
      case DepositStatus.ACTIVE:
        return AppColors.successColor;
      case DepositStatus.REDEEMED:
        return AppColors.successColor;
      case DepositStatus.FAILED_SETUP:
      case DepositStatus.COURTESY_CALL:
      case DepositStatus.FRAUD_LIQUIDATION_IN_PROGRESS:
      case DepositStatus.LIQUIDATION_IN_PROGRESS:
      case DepositStatus.LIQUIDATED:
        return AppColors.errorColor;
      default:
        throw ArgumentError.value(depositStatus);
    }
  }

  double _getIconSize() {
    if (kIsWeb) return 24;

    return 12;
  }

  void _highlightBottomCard() {
    setState(() {
      _isHighlighted = true;
    });
  }

  void _unHighlightBottomCard() {
    setState(() {
      _isHighlighted = false;
    });
  }

  Widget _getCopyIcon(String dataToCopy) {
    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: SizedBox(
            width: 16,
            height: 16,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.copy,
                color: AppColors.primaryColor,
                size: 18,
              ),
              onPressed: () {
                _insertToSystemClipboard(dataToCopy);
              },
            )));
  }

  void _insertToSystemClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
  }

  Widget _createHighlightingBottomCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      color: _getStatusColor(_deposit.status),
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: _isHighlighted ? _getCardSize() + 50 : _getCardSize(),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _isHighlighted ? 1.0 : 0.3,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    child: Row(
                      children: [
                        _getBTCAddressText(),
                        _deposit.btcTransactionHash == null
                            ? Container()
                            : _getBottomCopyIcon(_deposit.btcTransactionHash)
                      ],
                    ),
                    left: 16,
                    bottom: 30,
                  ),
                  Positioned(
                    child: Text(
                      DateFormat('dd/MM/yyyy kk:mm')
                          .format(_deposit.transactionDateTime),
                      style: _getBottomInfoTextStyle(),
                    ),
                    right: 16,
                    bottom: 30,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Status: ${_getStatusText()}',
                        style: TextStyle(
                            fontSize: 20, color: AppColors.backgroundColor),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton.icon(
                        onPressed: () {
                          if (kIsWeb)
                            html.window.open(
                                'https://etherscan.io/tx/${_deposit.transactionHash}',
                                'etherscan.io');
                        },
                        icon: Icon(
                          AppIcons.ic_redirect,
                          color: AppColors.backgroundColor,
                        ),
                        label: Text(
                          'check on etherscan.io',
                          style: TextStyle(
                              fontSize: 20, color: AppColors.backgroundColor),
                        ),
                      )),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 8),
                      child: _getConfirmationText(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBottomCopyIcon(String dataToCopy) {
    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: SizedBox(
            width: 16,
            height: 16,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.copy,
                color: AppColors.backgroundColor,
                size: 18,
              ),
              onPressed: () {
                _insertToSystemClipboard(dataToCopy);
              },
            )));
  }

  TextStyle _getBottomInfoTextStyle() {
    return TextStyle(fontSize: 20, color: AppColors.backgroundColor);
  }

  Text _getConfirmationText() {
    String confirmations;
    if (_deposit.requiredConfirmations == null ||
        _deposit.confirmations == null)
      confirmations = 'n.a.';
    else
      confirmations =
          '${_deposit.confirmations >= _deposit.requiredConfirmations ? _deposit.requiredConfirmations : _deposit.confirmations}'
          '/${_deposit.requiredConfirmations}';
    String data = 'BTC confirmations: $confirmations';
    return Text(
      data,
      style: _getBottomInfoTextStyle(),
    );
  }

  Text _getBTCAddressText() {
    String data =
        'BTC tx: ${_deposit.btcTransactionHash?.replaceRange(16, _deposit.btcTransactionHash.length - 16, '...') ?? 'n.a.'}';
    return Text(
      data,
      style: _getBottomInfoTextStyle(),
    );
  }
}
