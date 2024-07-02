import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jukkru/model/MediaSource.dart';

class CameraButtonWidget extends StatelessWidget {
  const CameraButtonWidget({Key? key}) : super(key: key);

  @override
 Widget build(BuildContext context){
    return const Scaffold();
  }

  Future pickCameraMedia(BuildContext context) async {
    final  source = ModalRoute.of(context)!.settings.arguments as MediaSource;

    final getMedia = source == MediaSource.image
        ? ImagePicker().pickImage
        : ImagePicker().pickVideo;

    final media = await getMedia(source: ImageSource.camera);
    final file = File(media!.path);

    Navigator.of(context).pop(file);
  }
}
