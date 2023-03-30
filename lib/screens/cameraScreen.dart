import 'dart:io';
import 'package:better_open_file/better_open_file.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class cameraScreen extends StatefulWidget {
  const cameraScreen({Key? key}) : super(key: key);

  @override
  State<cameraScreen> createState() => _cameraScreenState();
}

class _cameraScreenState extends State<cameraScreen> {
  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.awesome(
      saveConfig: SaveConfig.photo(
        pathBuilder: () async {
          final Directory extDir = await getTemporaryDirectory();
          final testDir =
          await Directory('${extDir.path}/test').create(recursive: true);
          return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        },
      ),
      filter: AwesomeFilter.None,
      flashMode: FlashMode.auto,
      aspectRatio: CameraAspectRatios.ratio_16_9,
      previewFit: CameraPreviewFit.fitWidth,
      onMediaTap: (mediaCapture) {
        OpenFile.open(mediaCapture.filePath);
      },
    );
  }
}
