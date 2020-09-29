import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_deposit_explorer/model/deposit.dart';
import 'package:keep_deposit_explorer/ui/constants/app_colors.dart';

class DepositBottomSheet extends StatelessWidget {
  final Deposit deposit;
  static const TextStyle _style = TextStyle(color: Colors.white);

  DepositBottomSheet({this.deposit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(Icons.close, color: Colors.white,),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("From: ${deposit.keepAddress}", style: _style,),
                  IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(Icons.content_copy, size: 16,),
                    color: Colors.blueAccent,
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: "${deposit.keepAddress}"));
                    },
                  ),
                ],
              ),
              Text("Amount: ${deposit.amount}", style: _style,),
              Text("Status: ${deposit.status}", style: _style,),
            ],
          )
        ],
      ),
    );
  }
}
