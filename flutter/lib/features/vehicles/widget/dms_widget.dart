import 'package:flutter/material.dart';
import 'package:VehiLoc/core/utils/logger.dart';
import 'package:VehiLoc/features/webview/history_view.dart';
import 'package:VehiLoc/features/webview/live_view.dart';
import 'package:VehiLoc/core/model/dashcamtype1.dart';
import 'package:VehiLoc/core/model/dashcamtype2.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VehiLoc/core/Api/api_service.dart';

class DmsWidget extends StatefulWidget {
  final String? vehicleImei;
  const DmsWidget({Key? key, this.vehicleImei}) : super(key: key);

  @override
  State<DmsWidget> createState() => _DmsWidgetState();
}

class _DmsWidgetState extends State<DmsWidget> with AutomaticKeepAliveClientMixin<DmsWidget> {
  late Dashcamtype1 _dashcamtype1;
  late Dashcamtype2 _dashcamtype2;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchDashcamDataType1();
    _fetchDashcamDataType2();
  }

  var imeis = "864993060045847";

  void _fetchDashcamDataType1() async {
    try {
      final ApiService apiService = ApiService();
      final dashcam = await apiService.fetchDashcam(imeis);
      setState(() {
        _dashcamtype1 = dashcam;
      });
    } catch (e) {
      logger.e('Error fetching dashcam data: $e');
    }
  }

  void _fetchDashcamDataType2() async {
    try {
      final ApiService apiService = ApiService();
      final dashcam = await apiService.fetchDashcamType2(imeis);
      setState(() {
        _dashcamtype2 = dashcam;
      });
    } catch (e) {
      logger.e('Error fetching dashcam data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextButton(
                onPressed: () {
                  if (_dashcamtype1.result != null && _dashcamtype1.result!.urlCamera != null) {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: LiveView(urlCamera: _dashcamtype1.result!.urlCamera!),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.fade,
                    );
                  } else {
                    _showErrorModal('Live Stream');
                  }
                },
                child: Text(
                  'Live',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextButton(
                onPressed: () {
                  if (_dashcamtype2.result != null && _dashcamtype2.result!.urlCamera != null) {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: HistoryView(urlCamera: _dashcamtype2.result!.urlCamera!),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.fade,
                    );
                  } else {
                    _showErrorModal('History');
                  }
                },
                child: Text(
                  'History',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorModal(String type) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.close,
                color: Colors.red,
                size: 88,
              ),
              const SizedBox(height: 16),
              Text(
                'You cannot access $type because the URL camera is empty',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
