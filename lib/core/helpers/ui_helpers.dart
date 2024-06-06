import 'package:ayna/router/router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SnackBarMode {
  info(Color(0xFF328AEB)),
  success(Color(0xFF22AA46)),
  error(Color(0xFFEF473A)),
  warning(Color(0xFFFFAB08));

  final Color primaryColor;

  const SnackBarMode(this.primaryColor);
}

class UiHelpers {
  static void removeFocus() =>
      FocusScope.of(kContext).requestFocus(FocusNode());

  static void showSnackBar(String text, {required SnackBarMode mode}) {
    kScaffoldMessengerKey.currentState!.clearSnackBars();
    kScaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        width: MediaQuery.sizeOf(kContext).width * 0.7,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 20.h),
        elevation: 0,
        backgroundColor: mode.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.h),
          side: BorderSide.none,
        ),
        content: Text(
          text,
          style: TextStyle(
            fontSize: 22.h,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static final _loadingOverlay = OverlayEntry(
    builder: (context) => Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.3),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    ),
  );

  static final _transparentOverlay = OverlayEntry(
    builder: (context) => Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
    ),
  );

  static void showLoadingOverlay(BuildContext context,
      {bool showLoader = true}) {
    Overlay.of(context).insert(
      showLoader ? _loadingOverlay : _transparentOverlay,
    );
  }

  static void hideLoadingOverlay() {
    if (_loadingOverlay.mounted) {
      _loadingOverlay.remove();
    }
    if (_transparentOverlay.mounted) {
      _transparentOverlay.remove();
    }
  }
}
