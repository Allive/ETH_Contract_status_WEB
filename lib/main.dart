import 'dart:async';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keep_deposit_explorer/data/deposit_repository.dart';
import 'package:keep_deposit_explorer/data/tbtc_general_info_repository.dart';
import 'package:keep_deposit_explorer/model/tbtc_general_info.dart';
import 'package:keep_deposit_explorer/ui/constants/app_colors.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:uuid/uuid.dart';

import 'ui/deposit_card.dart';
import 'model/deposit.dart';

void main() {
  runApp(DepositExplorerApp());
}

class DepositExplorerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KEEP deposit explorer',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        primaryColor: AppColors.primaryColor,
        primarySwatch: Colors.blue,
        textSelectionColor: AppColors.backgroundColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'KEEP deposit explorer'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DepositRepository depositRepository = DepositRepository();
  List<Deposit> deposits = List.empty(growable: true);

  bool isSearchExpanded = false;
  FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchEditTextController =
      TextEditingController();
  String _searchQuery = '';

  TBTCGeneralInfoRepository _tbtcGeneralInfoRepository =
      TBTCGeneralInfoRepository();
  TBTCGeneralInfo _tbtcGeneralInfo;

  final _depositListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _loadDeposits();
    _loadTBTCGeneralInfo();
    _startUpdateTimer();
  }

  _startUpdateTimer() {
    Timer.periodic(Duration(seconds: 60), (timer) {
      _loadDeposits();
      _loadTBTCGeneralInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper.builder(
        GestureDetector(
          onTap: () {
            _shrinkSearch();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.darkBackgroundColor,
              title: Text(
                widget.title,
                style: TextStyle(color: AppColors.primaryColor),
              ),
              actions: [
                _tbtcGeneralInfo == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'TBTC total supply: ${_tbtcGeneralInfo.tbtcTotalSupply}',
                              style: TextStyle(
                                  color: AppColors.primaryColor, fontSize: 22),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: _createSearchBar(),
                ),
                Divider(
                  color: AppColors.darkBackgroundColor,
                ),
                Expanded(
                  child: _createDepositListView(deposits),
                ),
              ],
            ),
          ),
        ),
        breakpoints: [
          ResponsiveBreakpoint.autoScale(1080, name: MOBILE),
          ResponsiveBreakpoint.resize(1600, name: DESKTOP),
        ],
        defaultScale: true,
        minWidth: 1200);
  }

  Widget _createSearchBar() {
    return Stack(children: [
      Padding(
        padding: EdgeInsets.only(top: 8, right: 8),
        child: AnimatedContainer(
          decoration: BoxDecoration(
            color: AppColors.textColor,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                topRight: Radius.circular(30)),
          ),
          height: 60,
          duration: Duration(milliseconds: 300),
          width: isSearchExpanded ? 600 : 100,
        ),
      ),
      Padding(
          padding: EdgeInsets.only(bottom: 8, left: 8),
          child: AnimatedContainer(
              height: 60,
              duration: Duration(milliseconds: 300),
              width: isSearchExpanded ? 600 : 100,
              decoration: BoxDecoration(
                  color: AppColors.darkBackgroundColor,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  border: Border.all(color: AppColors.primaryColor, width: 2)),
              child: isSearchExpanded
                  ? Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          fillColor: AppColors.textColor,
                          hintText: 'Deposit, KEEP, tx hash...',
                          hintStyle: TextStyle(
                              color: AppColors.textColor,
                              fontStyle: FontStyle.italic),
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (String str) {
                          _updateSearchQuery(str);
                        },
                        cursorColor: AppColors.textColor,
                        style:
                            TextStyle(color: AppColors.textColor, fontSize: 28),
                        focusNode: _searchFocusNode,
                        controller: _searchEditTextController,
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        _expandSearch();
                      },
                      child: Stack(children: [
                        Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              height: 40,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                            )),
                      ])))),
    ]);
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void _expandSearch() {
    setState(() {
      isSearchExpanded = true;
      _searchFocusNode.requestFocus();
    });
  }

  void _shrinkSearch() {
    setState(() {
      _updateSearchQuery('');
      _searchEditTextController.text = '';
      isSearchExpanded = false;
      _searchFocusNode.unfocus();
    });
  }

  Widget _createDepositListView(List<Deposit> deposits) {
    var filteredDeposits = deposits
        .where((deposit) =>
            deposit.keepAddress.contains(_searchQuery) ||
            deposit.transactionHash.contains(_searchQuery) ||
            deposit.depositAddress.contains(_searchQuery))
        .toList();

    filteredDeposits
        .sort((a, b) => b.transactionDateTime.compareTo(a.transactionDateTime));

    var depositListView = ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (BuildContext context, int index) => Container(
              height: 40,
            ),
        controller: _depositListScrollController,
        itemCount: filteredDeposits.length,
        itemBuilder: (BuildContext context, int position) {
          return DepositCard(filteredDeposits[position], Key(Uuid().v4()));
        });

    if (kIsWeb)
      return DraggableScrollbar.rrect(
        alwaysVisibleScrollThumb: true,
        controller: _depositListScrollController,
        backgroundColor: AppColors.textColor,
        child: depositListView,
      );
    else
      return depositListView;
  }

  Future<void> _loadDeposits() async {
    var depositsInResponse = await depositRepository.getRecentDeposits();
    if (depositsInResponse == null || depositsInResponse.isEmpty) return;

    setState(() {
      deposits = depositsInResponse;
    });
  }

  Future<void> _loadTBTCGeneralInfo() async {
    TBTCGeneralInfo info = await _tbtcGeneralInfoRepository.getGeneralInfo();
    if (info == null || info.tbtcTotalSupply == null) return;

    setState(() {
      _tbtcGeneralInfo = info;
    });
  }
}
