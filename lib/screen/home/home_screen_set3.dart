import 'package:flutter/material.dart';
import 'package:woo_yeon_hi/widget/home/home_top_app_bar.dart';

import 'home_screen_container.dart';

class HomeScreenSet3 extends StatefulWidget {
  const HomeScreenSet3({super.key});

  @override
  State<HomeScreenSet3> createState() => _HomeScreenState3();
}

class _HomeScreenState3 extends State<HomeScreenSet3> {
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
                dDay(context),
                const SizedBox(height: 20),
                accountBook(context),
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
