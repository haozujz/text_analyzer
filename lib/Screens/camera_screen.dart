import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/ViewModels/text_analysis_vm.dart';
import '../Services/network_service.dart';
import '../Utilities/constants.dart';
import '../ViewModels/auth_vm.dart';
import '../ViewModels/camera_vm.dart';
import '../Services/logger_service.dart';
import 'photo_preview.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  @override
  void initState() {
    super.initState();

    // Future.microtask(() {
    //   // if (!ref.watch(cameraViewModelProvider).isCameraInitialized) {
    //   ref.read(cameraViewModelProvider.notifier).initializeCamera();
    //   // } else {
    //   // ref.read(cameraViewModelProvider.notifier).resumeCamera();
    //   // }
    // });

    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // @override
  // void dispose() {
  //   // Restore UI when leaving
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraViewModelProvider);
    final cameraViewModel = ref.read(cameraViewModelProvider.notifier);
    //final authState = ref.read(authViewModelProvider);
    //final textAnalysisState = ref.read(textAnalysisViewModelProvider);
    final textAnalysisViewModel = ref.read(
      textAnalysisViewModelProvider.notifier,
    );

    Future<void> onSaveTapped() async {
      try {
        await textAnalysisViewModel.postAnalysisResult();
        LoggerService().info("Saved new analysis result to the database");
      } catch (e) {
        if (e is NetworkError) {
          LoggerService().error(
            "Network error calling AWS Lambda: ${e.message}",
          );
        } else {
          LoggerService().error("Network Error calling AWS Lambda: $e");
        }
      }
    }

    return PopScope(
      canPop: cameraState.imagePath.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (cameraState.imagePath.isNotEmpty) {
          cameraViewModel.resetImage();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          color: Colors.black,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              child:
                  cameraState.cameraError != null
                      ? Text(
                        cameraState.cameraError!,
                        style: TextStyle(color: Colors.white),
                      )
                      : !cameraState.isCameraInitialized
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      )
                      : Stack(
                        children: [
                          // Conditionally show camera or captured image
                          AnimatedSwitcher(
                            duration: Duration(
                              milliseconds: 300,
                            ), // Smooth fade transition
                            transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child:
                                cameraState.imagePath.isEmpty
                                    ? Align(
                                      alignment: Alignment.topCenter,
                                      key: ValueKey(
                                        'CameraPreview',
                                      ), // Ensures proper switching
                                      child: CameraPreview(
                                        cameraViewModel.getCameraController()!,
                                      ),
                                    )
                                    : PhotoPreview(
                                      key: ValueKey(
                                        'PhotoPreview',
                                      ), // Unique key for animation
                                      imagePath: cameraState.imagePath,
                                    ),
                          ),

                          // Navigate to preview when imagePath is set
                          if (cameraState.imagePath.isNotEmpty)
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
                                    Icons.close,
                                    color: AppColors.text,
                                    size: 32,
                                  ),
                                  padding: EdgeInsets.all(
                                    10,
                                  ), // Ensures a large tap target
                                  onPressed: () {
                                    cameraViewModel.resetImage();
                                  },
                                ),
                              ),
                            ),

                          if (cameraState.imagePath.isNotEmpty)
                            Positioned(
                              top: 20,
                              right: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.16),
                                      blurRadius: 8,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: AppColors.text,
                                    size: 32,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  onPressed: () async {
                                    final RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    final Offset offset =
                                        renderBox.localToGlobal(Offset.zero) +
                                        Offset(
                                          renderBox.size.width,
                                          renderBox.size.height * 0.08,
                                        );

                                    _showPopupMenu(
                                      context,
                                      offset,
                                      onSaveTapped,
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showPopupMenu(BuildContext context, Offset position, VoidCallback onTap) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0), // Correctly position it
      Offset.zero &
          overlay.size, // Ensure menu appears within the screen bounds
    ),
    items: [
      PopupMenuItem(
        onTap: onTap,
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white),
        ), // Use the passed function
      ),
    ],
    color: Colors.grey[900], // Dark background
    elevation: 4,
  );
}

// void _showPopupMenu(BuildContext context, Offset position) {
//   final RenderBox overlay =
//       Overlay.of(context).context.findRenderObject() as RenderBox;

//   showMenu(
//     context: context,
//     position: RelativeRect.fromRect(
//       Rect.fromLTWH(position.dx, position.dy, 0, 0), // Correctly position it
//       Offset.zero &
//           overlay.size, // Ensure menu appears within the screen bounds
//     ),
//     items: [
//       PopupMenuItem(
//         child: Text(
//           "Save",
//           style: TextStyle(color: Colors.white),
//         ), // White text for dark mode
//         onTap: () => LoggerService().info("Save clicked"),
//       ),
//     ],
//     color: Colors.grey[900], // Dark background
//     elevation: 4,
//   );
// }
