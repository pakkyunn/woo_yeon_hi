import 'package:flutter/material.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/widget/home/home_top_app_bar.dart';

import 'home_screen_container.dart';

class HomeScreenSet1 extends StatefulWidget {
  const HomeScreenSet1({super.key});

  @override
  State<HomeScreenSet1> createState() => _HomeScreenState1();
}

class _HomeScreenState1 extends State<HomeScreenSet1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorFamily.cream,
      appBar: const HomeTopAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20,0,20,20),
            child: Column(
              children: [
                dDay(context),
                const SizedBox(height: 20),
                calendar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
