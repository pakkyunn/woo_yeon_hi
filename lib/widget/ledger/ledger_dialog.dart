import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woo_yeon_hi/provider/ledger_provider.dart';
import 'package:woo_yeon_hi/screen/ledger/ledger_unregistered_detail_screen.dart';
import 'package:woo_yeon_hi/screen/ledger/ledger_write_screen.dart';
import 'package:woo_yeon_hi/style/color.dart';
import 'package:woo_yeon_hi/style/font.dart';

class LedgerDialog extends StatefulWidget {
  //const LedgerDialog({super.key});

  final String fileName;
  final String title;
  final String detail;


  LedgerDialog(this.fileName, this.title, this.detail, {super.key});


  @override
  State<LedgerDialog> createState() => _LedgerDialogState();
}

class _LedgerDialogState extends State<LedgerDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        backgroundColor: ColorFamily.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: 280,
          height: 170,
          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Top과 텍스트 높이
              SizedBox(height: 30),
              Text(
                widget.title,
                style: TextStyle(color: ColorFamily.black, fontSize: 16, fontFamily: FontFamily.mapleStoryLight),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                widget.detail,
                style: TextStyle(color: ColorFamily.gray, fontSize: 12, fontFamily: FontFamily.mapleStoryLight),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        performActionCancel();
                      },
                      child: Text(widget.fileName == 'DoneLedgerUnregisteredDetailScreen' ? '홈으로' : '취소', style: TextStyle(color: ColorFamily.black, fontSize: 20, fontFamily: FontFamily.mapleStoryLight))
                  ),
                  SizedBox(width: 75),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        performActionCheck();
                      },
                      child: Text('확인', style: TextStyle(color: ColorFamily.pink, fontSize: 20, fontFamily: FontFamily.mapleStoryLight))
                  ),

                  // 버튼과 bottom의 높이
                  SizedBox(height: 20)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 확인
  void performActionCheck() {
    var selectedDay = Provider.of<LedgerProvider>(context, listen: false).selectedDay?? DateTime.now();

    switch (widget.fileName) {
      case 'LedgerScreen':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LedgerUnregisteredDetailScreen(),
        ),
      );
        break;
      case 'LedgerModalBottomSheet':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 되었습니다.', style: TextStyle(color: ColorFamily.white, fontSize: 14, fontFamily: FontFamily.mapleStoryLight))),
        );
        break;
      case 'LedgerUnregisteredDetailScreen':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LedgerWriteScreen(selectedDay),
          ),
        );
        break;
      case 'DoneLedgerUnregisteredDetailScreen':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LedgerWriteScreen(selectedDay),
          ),
        );
        break;
      case 'LedgerWriteScreen':
        Navigator.pop(context);
        break;
    }
  }

  // 취소
  void performActionCancel() {
    var selectedDay = Provider.of<LedgerProvider>(context, listen: false).selectedDay?? DateTime.now();

    switch (widget.fileName) {
      case 'LedgerScreen':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LedgerWriteScreen(selectedDay),
          ),
        );
        break;
      case 'DoneLedgerUnregisteredDetailScreen':
        Navigator.pop(context);
        break;
    }
  }
}
