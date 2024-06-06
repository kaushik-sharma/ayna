import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

AppBar kCustomAppBar(String title, {List<Widget> actions = const []}) => AppBar(
      centerTitle: false,
      backgroundColor: Colors.white,
      title: Text(
        'Home',
        style: TextStyle(
          fontSize: 30.h,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actions: [
        ...actions,
        30.horizontalSpace,
      ],
    );
