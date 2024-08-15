import 'package:flutter/material.dart';
import 'package:woo_yeon_hi/widget/home/home_top_app_bar.dart';

import 'home_screen_container.dart';

class HomeScreenSet2 extends StatefulWidget {
  const HomeScreenSet2({super.key});

  @override
  State<HomeScreenSet2> createState() => _HomeScreenState2();
}

class _HomeScreenState2 extends State<HomeScreenSet2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeTopAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xffFCF8F5),
            child: Column(
              children: [
                const SizedBox(height: 20),
                dDay(context),
                const SizedBox(height: 20),
                datePlan(),
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
