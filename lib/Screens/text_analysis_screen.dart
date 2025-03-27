// import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nlp_flutter/Services/network_service.dart';
import 'package:nlp_flutter/ViewModels/auth_vm.dart';
import '../Utilities/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Screens/camera_screen.dart';
import '../ViewModels/camera_vm.dart';
import '../ViewModels/text_analysis_vm.dart';
import 'TextAnalysis/text_analysis_tray.dart';

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
    final authState = ref.read(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    final textAnalysisViewModel = ref.read(
      textAnalysisViewModelProvider.notifier,
    );

    final double screenHeight = MediaQuery.of(context).size.height;

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

        if (authState.user != null) {
          try {
            await textAnalysisViewModel.onPhotoChange(
              next.imagePath,
              authState.user!,
            );
          } catch (e) {
            if (e is NetworkError) {
              authViewModel.showMessageOnly(e.message);
            } else {
              authViewModel.showMessageOnly('$e');
            }
          }
        }
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
          Positioned.fill(child: CameraScreen()),

          if (cameraState.isCameraInitialized && cameraState.imagePath.isEmpty)
            Positioned(
              bottom: 190,
              left: (MediaQuery.of(context).size.width - 82) / 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(255, 255, 255, 0.3),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await cameraViewModel.takePicture();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(36),
                      backgroundColor: AppColors.text,
                    ),
                    child: null,
                  ),
                ],
              ),
            ),

          if (cameraState.imagePath.isEmpty)
            Positioned(
              top: 20,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.16),
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    CupertinoIcons.chevron_back,
                    color: AppColors.text,
                    size: 32,
                  ),
                  padding: EdgeInsets.all(10), // Ensures a large tap target
                  onPressed: () {
                    textAnalysisViewModel.toggleTextAnalysis();
                  },
                ),
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
                    color: AppColors.text,
                    size: 28,
                  ),
                  padding: EdgeInsets.all(12),
                  splashRadius: 24, // Splash radius for the tap effect
                ),
              ),
            ),

          // Draggable control tray
          SizedBox(
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
