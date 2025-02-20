import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:jukkru/Camera/previewRear_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import 'package:jukkru/Screens/Widgets/CattleNavigationLine.dart';
import 'package:jukkru/convetHex.dart';
import 'package:jukkru/model/catTime.dart';

import '../main.dart';

ConvertHex hex = ConvertHex();
class CameraRearScreen extends StatefulWidget {
  final int idPro;
  final int idTime;
  final String localFront;
  final String localBack;
  final CatTimeModel catTime;
  // final VoidCallback navigator;

  const CameraRearScreen({
    Key? key,
    required this.idPro,
    required this.idTime,
    required this.localFront,
    required this.localBack,
    required this.catTime,
  }) : super(key: key);
  @override
  _CameraRearScreenState createState() => _CameraRearScreenState();
}

class _CameraRearScreenState extends State<CameraRearScreen>
    with SingleTickerProviderStateMixin {
  CameraController? controller;
  VideoPlayerController? videoController;

  File? _imageFile;
  File? _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  final bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  // กรอบภาพ
  bool showFront = true;
  bool showState = false;
  late AnimationController controllerAnimated;

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras[0]);
      refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    for (var file in fileList) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    }

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        _videoFile = null;
      }

      setState(() {});
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      videoController = VideoPlayerController.file(_videoFile!);
      await videoController!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    // Hide the status bar in Android
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    getPermissionStatus();
    controllerAnimated = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300), value: 0);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ถ่ายภาพด้่านหลังโค',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Phoenix.rebirth(context);
                },
                icon: const Icon(Icons.home))
          ],
          backgroundColor: Color(hex.hexColor("#007BA4")),
        ),
        backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1 / controller!.value.aspectRatio,
                        child: Stack(
                          children: [
                            CameraPreview(
                              controller!,
                              child: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints constraints) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (details) =>
                                      onViewFinderTap(details, constraints),
                                );
                              }),
                            ),
                            // TODO: Uncomment to preview the overlay

                            Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16.0,
                                      8.0,
                                      16.0,
                                      8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            // Flip the image
                                            await controllerAnimated.forward();
                                            setState(
                                                () => showFront = !showFront);
                                            await controllerAnimated.reverse();
                                          },
                                          icon: const Icon(Icons.compare_arrows),
                                          color: Colors.white,
                                          iconSize: 40,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(
                                                () => showState = !showState);
                                          },
                                          icon: const Icon(Icons.compare_outlined),
                                          color: Colors.white,
                                          iconSize: 40,
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16.0,
                                      8.0,
                                      16.0,
                                      8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: _isRecordingInProgress
                                                  ? () async {
                                                      if (controller!.value
                                                          .isRecordingPaused) {
                                                        await resumeVideoRecording();
                                                      } else {
                                                        await pauseVideoRecording();
                                                      }
                                                    }
                                                  : () {
                                                      setState(() {
                                                        _isCameraInitialized =
                                                            false;
                                                      });
                                                      onNewCameraSelected(cameras[
                                                          _isRearCameraSelected
                                                              ? 1
                                                              : 0]);
                                                      setState(() {
                                                        _isRearCameraSelected =
                                                            !_isRearCameraSelected;
                                                      });
                                                    },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.circle,
                                                    color: Colors.black38,
                                                    size: 60,
                                                  ),
                                                  _isRecordingInProgress
                                                      ? controller!.value
                                                              .isRecordingPaused
                                                          ? const Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  Colors.white,
                                                              size: 30,
                                                            )
                                                          : const Icon(
                                                              Icons.pause,
                                                              color:
                                                                  Colors.white,
                                                              size: 30,
                                                            )
                                                      : Icon(
                                                          _isRearCameraSelected
                                                              ? Icons
                                                                  .camera_front
                                                              : Icons
                                                                  .camera_rear,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                ],
                                              ),
                                            ),
                                            //  piture image and record video
                                            InkWell(
                                              onTap: _isVideoCameraSelected
                                                  ? () async {
                                                      if (_isRecordingInProgress) {
                                                        XFile? rawVideo =
                                                            await stopVideoRecording();
                                                        File videoFile = File(
                                                            rawVideo!.path);

                                                        int currentUnix = DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch;

                                                        final directory =
                                                            await getApplicationDocumentsDirectory();

                                                        String fileFormat =
                                                            videoFile.path
                                                                .split('.')
                                                                .last;

                                                        _videoFile =
                                                            await videoFile
                                                                .copy(
                                                          '${directory.path}/$currentUnix.$fileFormat',
                                                        );

                                                        _startVideoPlayer();
                                                      } else {
                                                        await startVideoRecording();
                                                      }
                                                    }
                                                  : () async {
                                                      // ****** picture ******
                                                      XFile? rawImage =
                                                          await takePicture();
                                                      File imageFile =
                                                          File(rawImage!.path);

                                                      int currentUnix = DateTime
                                                              .now()
                                                          .millisecondsSinceEpoch;

                                                      final directory =
                                                          await getApplicationDocumentsDirectory();

                                                      String fileFormat =
                                                          imageFile.path
                                                              .split('.')
                                                              .last;

                                                      print(fileFormat);

                                                      await imageFile.copy(
                                                        '${directory.path}/$currentUnix.$fileFormat',
                                                      );

                                                      refreshAlreadyCapturedImages();
                                                      // ****** picture ******
                                                    },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color:
                                                        _isVideoCameraSelected
                                                            ? Colors.white
                                                            : Colors.white38,
                                                    size: 80,
                                                  ),
                                                  Icon(
                                                    Icons.circle,
                                                    color:
                                                        _isVideoCameraSelected
                                                            ? Colors.red
                                                            : Colors.white,
                                                    size: 65,
                                                  ),
                                                  _isVideoCameraSelected &&
                                                          _isRecordingInProgress
                                                      ? const Icon(
                                                          Icons.stop_rounded,
                                                          color: Colors.white,
                                                          size: 32,
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap:
                                                  _imageFile != null ||
                                                          _videoFile != null
                                                      ? () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PreviewRearScreen(
                                                                idPro: widget
                                                                    .idPro,
                                                                idTime: widget
                                                                    .idTime,
                                                                imageFile:
                                                                    _imageFile!,
                                                                fileList:
                                                                    allFileList,
                                                                catTime: widget.catTime,
                                                                
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      : null,
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                  image: _imageFile != null
                                                      ? DecorationImage(
                                                          image: FileImage(
                                                              _imageFile!),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                                ),
                                                child: videoController !=
                                                            null &&
                                                        videoController!
                                                            .value.isInitialized
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: AspectRatio(
                                                          aspectRatio:
                                                              videoController!
                                                                  .value
                                                                  .aspectRatio,
                                                          child: VideoPlayer(
                                                              videoController!),
                                                        ),
                                                      )
                                                    : Container(),
                                              ),
                                            ),
                                            //  piture image and record video
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                            showState
                                ? Container()
                                : CattleNavigationLine(
                                    front: widget.localFront,
                                    back: widget.localBack,
                                    imageHeight: 380,
                                    imageWidth: 280,
                                    showFront: showFront)
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'LOADING',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(),
                  const Text(
                    'Permission denied',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      getPermissionStatus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Give permission',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
