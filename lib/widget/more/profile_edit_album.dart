import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/login_register_provider.dart';
import '../../style/color.dart';
import '../../style/text_style.dart';

class ProfileEditAlbum extends StatefulWidget {
  const ProfileEditAlbum({super.key});

  @override
  State<ProfileEditAlbum> createState() => _ProfileEditAlbumState();
}

class _ProfileEditAlbumState extends State<ProfileEditAlbum> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.0,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        splashColor: ColorFamily.cream,
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          showPhotoBottomSheet(context);
        },
        child: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: ColorFamily.white,
              border: Border.all(width: 0.1, color: ColorFamily.gray)),
          child: SvgPicture.asset(
            'lib/assets/icons/camera.svg',
            width: 20,
            height: 20,
            fit: BoxFit.none,
          ),
        ),
      ),
    );
  }
}

Future<void> getImage(
    UserProvider userProvider, ImageSource imageSource) async {
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화
  final XFile? pickedFile = await picker.pickImage(source: imageSource);
  if (pickedFile != null) {
    userProvider.setImage(XFile(pickedFile.path));
    userProvider.setTempImagePath(userProvider.image!.path);
    userProvider
        .setTempImage(Image.file(File(pickedFile.path), fit: BoxFit.cover));
    print('파일경로: ${pickedFile.path}');
    print('이미지경로: ${userProvider.tempImagePath}');
  }
}

void showPhotoBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: ColorFamily.white,
      builder: (context) {
        return Consumer<UserProvider>(builder: (context, provider, child) {
          return Wrap(
            children: [
              Column(
                children: [
                  InkWell(
                    splashColor: ColorFamily.gray.withOpacity(0.5),
                    onTap: () {
                      getImage(provider, ImageSource.gallery);
                      Navigator.pop(context);
                      // FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'lib/assets/icons/gallery.svg',
                            height: 20,
                          ),
                          const Text(
                            "앨범에서 사진 선택",
                            style: TextStyleFamily.smallTitleTextStyle,
                          ),
                          const SizedBox(
                            width: 24,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 0.5,
                    child: Divider(
                      color: ColorFamily.gray,
                      thickness: 0.5,
                    ),
                  ),
                  InkWell(
                    splashColor: ColorFamily.gray.withOpacity(0.5),
                    onTap: () {
                      provider.setTempImagePath(
                          "lib/assets/images/default_profile.png");
                      provider.setTempImage(
                          Image.asset("lib/assets/images/default_profile.png"));
                      provider.setImage(null);
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset('lib/assets/icons/profile_icon.svg',
                              height: 20),
                          const Text(
                            "기본 프로필 사진으로 설정",
                            style: TextStyleFamily.smallTitleTextStyle,
                          ),
                          const SizedBox(
                            width: 24,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      });
}
