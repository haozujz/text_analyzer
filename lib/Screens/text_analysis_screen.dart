import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'camera_screen.dart';
import '../ViewModels/camera_vm.dart';
import '../ViewModels/text_analysis_vm.dart';
import 'text_analysis_tray.dart';

// import 'package:photo_manager/photo_manager.dart';
// import 'dart:io';
// import 'dart:typed_data';

class TextAnalysisScreen extends ConsumerStatefulWidget {
  const TextAnalysisScreen({super.key});

  @override
  ConsumerState<TextAnalysisScreen> createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends ConsumerState<TextAnalysisScreen> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  // File? _image;
  // AssetEntity? _lastImage;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadLastImage();
  // }

  // Future<void> _loadLastImage() async {
  //   // Request permissions to access the gallery
  //   final PermissionState permission =
  //       await PhotoManager.requestPermissionExtend();
  //   if (permission == PermissionState.authorized) {
  //     // Retrieve the last image taken from the gallery
  //     final List<AssetPathEntity> assets = await PhotoManager.getAssetPathList(
  //       onlyAll: true,
  //     );
  //     final AssetPathEntity path = assets.first;

  //     final List<AssetEntity> imageList = await path.getAssetListPaged(
  //       page: 0,
  //       size: 1,
  //     );
  //     if (imageList.isNotEmpty) {
  //       setState(() {
  //         _lastImage = imageList.first;
  //       });
  //     }
  //   }
  // }

  // Future<Widget> getThumbnail(AssetEntity asset) async {
  //   final Uint8List? thumbnailData = await asset.thumbnailData;
  //   if (thumbnailData != null) {
  //     return Image.memory(
  //       thumbnailData,
  //       width: 200,
  //       height: 200,
  //       fit: BoxFit.cover,
  //     );
  //   }
  //   return Icon(Icons.error, size: 200);
  // }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraViewModelProvider);
    final cameraViewModel = ref.read(cameraViewModelProvider.notifier);

    //final textAnalysisState = ref.watch(textAnalysisViewModelProvider);
    final textAnalysisViewModel = ref.read(
      textAnalysisViewModelProvider.notifier,
    );

    final double screenHeight = MediaQuery.of(context).size.height;

    // Define fixed pixel heights
    final double inactiveTrayHeightPx = 168;
    final double activeTrayHeightPx = 400;
    final double maxTrayHeightPx = 700;

    // Convert pixel heights to screen fractions
    final double minChildSize = inactiveTrayHeightPx / screenHeight;
    final double initialChildSize = minChildSize;
    final double activeChildSize = activeTrayHeightPx / screenHeight;
    final double maxChildSize = maxTrayHeightPx / screenHeight;

    // Ensure the max height does not exceed 100% of screen height
    final double safeMaxChildSize = maxChildSize.clamp(0.0, 1.0);

    // Listen for state changes to the camera provider
    ref.listen<CameraState>(cameraViewModelProvider, (previous, next) async {
      if (previous?.imagePath != next.imagePath) {
        _scrollController.animateTo(
          next.imagePath.isEmpty ? minChildSize : activeChildSize,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        textAnalysisViewModel.onNewPhotoTaken(next.imagePath);
      }
    });

    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        cameraViewModel.setImageFromPicker(pickedFile.path);
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CameraPreview at the back
          Positioned.fill(child: CameraScreen()),

          // Floating capture button above the 'controls' rectangle
          if (cameraState.imagePath.isEmpty)
            Positioned(
              bottom: 190,
              left: (MediaQuery.of(context).size.width - 82) / 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Large semi-transparent white circle around the button
                  Container(
                    width: 82, // Diameter of the concentric circle
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(
                        255,
                        255,
                        255,
                        0.3,
                      ), // Semi-transparent white fill
                      border: Border.all(
                        color: Colors.white,
                        width: 2, // Thickness of the white border
                      ),
                    ),
                  ),
                  // Floating button in the center
                  ElevatedButton(
                    onPressed: () async {
                      await cameraViewModel.takePicture();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(36),
                      backgroundColor: Colors.white,
                    ),
                    child: null,
                  ),
                ],
              ),
            ),

          if (cameraState.imagePath.isEmpty)
            Positioned(
              bottom: 200,
              left: 58,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.18),
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async {
                    pickImage();
                  },
                  icon: Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 28,
                  ),
                  padding: EdgeInsets.all(12),
                  splashRadius: 24, // Sets the splash radius for the tap effect
                ),
              ),
            ),

          // Draggable control tray
          Container(
            height: 5000,
            child: IgnorePointer(
              ignoring: cameraState.imagePath.isEmpty,
              child: DraggableScrollableSheet(
                controller: _scrollController,
                initialChildSize: initialChildSize,
                minChildSize: minChildSize,
                maxChildSize: safeMaxChildSize,
                builder: (
                  BuildContext context,
                  ScrollController scrollController,
                ) {
                  return TextAnalysisTray(scrollController: scrollController);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



              

          // Positioned(
          //   bottom: 200,
          //   left: 48,
          //   child: Stack(
          //     alignment: Alignment.center,
          //     children: [
          //       _image != null
          //           ? Image.file(
          //             _image!,
          //             width: 200,
          //             height: 200,
          //             fit: BoxFit.cover,
          //           )
          //           : _lastImage != null
          //           ? FutureBuilder<Widget>(
          //             future: getThumbnail(_lastImage!),
          //             builder: (context, snapshot) {
          //               if (snapshot.connectionState == ConnectionState.done) {
          //                 if (snapshot.hasData) {
          //                   return snapshot.data!;
          //                 }
          //               }
          //               return CircularProgressIndicator();
          //             },
          //           )
          //           : Text('No image selected'),
          //       SizedBox(height: 20),
          //       ElevatedButton(
          //         onPressed: pickImage,
          //         child: Text('Pick Image from Gallery'),
          //       ),
          //     ],
          //   ),
          // ),