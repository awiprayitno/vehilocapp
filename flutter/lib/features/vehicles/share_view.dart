import 'dart:convert';

import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:VehiLoc/core/model/response_daily.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/logger.dart';


class SharePageView extends StatefulWidget {


  SharePageView({
    Key? key,
  }) : super(key: key) {
  }

  @override
  _SharePageViewState createState() => _SharePageViewState();
}

class _SharePageViewState extends State<SharePageView>{
  bool _isLoading = false;
  ApiService apiService = ApiService();
  final int _pageSize = 20;
  final RefreshController _refreshController = RefreshController();
  final PagingController<int, dynamic> _pagingController =
  PagingController(firstPageKey: 1);

  void _onRefresh() async {
    // monitor network fetch
    setState(() {
      _pagingController.refresh();
      //children = [];
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  Future<void> _fetchPage (int pageKey) async {
    try {
      var newItems =
      await apiService.sharedLinks(
          page: pageKey,
          perPage: _pageSize,
        customerId: 2);
      var items = jsonDecode(newItems);
      logger.d(items);


      final isLastPage = items["shared_links"].length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(items["shared_links"]);
      } else {
        pageKey = pageKey + 1;
        _pagingController.appendPage(items["shared_links"], pageKey);
      }
    } catch (error) {
      logger.e("error");
      logger.e(error);
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Share Link",
         style: GoogleFonts.poppins(
         color: GlobalColor.textColor,
       ),),
       backgroundColor: GlobalColor.mainColor,
       iconTheme: const IconThemeData(
           color: Colors.white
       ),
     ),
     body: Container(
       margin: const EdgeInsets.all(10),
       child: SmartRefresher(
         enablePullDown: true,
         enablePullUp: false,
         controller: _refreshController,
         onRefresh: _onRefresh,
         onLoading: _onLoading,
         child: PagedListView<int, dynamic>(
           addRepaintBoundaries: true,
           cacheExtent: 10,
           addSemanticIndexes: true,
           pagingController: _pagingController,
           builderDelegate: PagedChildBuilderDelegate<dynamic>(
             animateTransitions: true,
             noMoreItemsIndicatorBuilder: (_) => const Column(children: [
               Divider(
                 height: 20,
               ),
             ]),
             // [transitionDuration] has a default value of 250 milliseconds.
             transitionDuration: const Duration(milliseconds: 250),
             itemBuilder: (context, item, index) {
               logger.i("index $index");
               logger.wtf(item);
               return Card(
                 color: Colors.amberAccent,
                 child: Text(item.toString()),);
             },
           ),
         ),
       )
     ),
   );
  }
}
