import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Monitors/network_monitor.dart';
import 'package:nlp_flutter/Monitors/screen_monitor.dart';
import 'package:nlp_flutter/Services/logger_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ViewModels/auth_vm.dart';
import '../ViewModels/camera_vm.dart';
import 'Screens/TextAnalysis/text_analysis_screen.dart';
import 'Screens/Authentication/login_screen.dart';
import '../Views/custom_alert_dialog.dart';
import 'Services/websocket.dart';
import 'Utilities/constants.dart';
import 'ViewModels/text_analysis_vm.dart';
import 'nav_bar_view.dart';

class BaseView extends ConsumerStatefulWidget {
  const BaseView({super.key});

  @override
  BaseViewState createState() => BaseViewState();
}

class BaseViewState extends ConsumerState<BaseView>
    with WidgetsBindingObserver {
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    NetworkMonitor().startListening();
    ScreenMonitor().startListening();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The app is in the foreground
      WebSocketService().connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textAnalysisState = ref.watch(textAnalysisViewModelProvider);
    final textAnalysisVM = ref.read(textAnalysisViewModelProvider.notifier);
    final authState = ref.watch(authViewModelProvider);
    final authVM = ref.read(authViewModelProvider.notifier);
    final cameraVM = ref.read(cameraViewModelProvider.notifier);

    Future<void> initializeCamera() async {
      if (_isRequestingPermission) {
        return;
      }
      _isRequestingPermission = true;
      final cameraPermission = await Permission.camera.request();
      _isRequestingPermission = false;

      if (cameraPermission.isGranted) {
        await ref.read(cameraViewModelProvider.notifier).initializeCamera();
      } else if (cameraPermission.isDenied) {
        LoggerService().error(
          "Camera permission denied. Please grant permission.",
        );
        authVM.showMessageOnly(
          'Camera permission denied. Please grant permission to allow this app to use the camera.',
        );
      } else if (cameraPermission.isPermanentlyDenied) {
        LoggerService().error(
          "Camera permission permanently denied. Opening app settings...",
        );
        Future.delayed(const Duration(milliseconds: 5000), () {
          openAppSettings();
        });
      }
    }

    return Consumer(
      builder: (context, ref, child) {
        ref.listen<TextAnalysisState>(textAnalysisViewModelProvider, (
          previous,
          next,
        ) async {
          if (previous?.isTextAnalysisVisible != next.isTextAnalysisVisible &&
              !next.isTextAnalysisVisible) {
            cameraVM.stopCamera();
          } else {
            await initializeCamera();
          }
        });

        ref.listen<AuthState>(authViewModelProvider, (previous, next) async {
          if (previous?.isSignedIn != next.isSignedIn && !next.isSignedIn) {
            cameraVM.stopCamera();
          }

          if (next.error != null) {
            showCustomAlertDialog(
              context: context,
              title: 'Error',
              message: '${next.error}',
              buttonText: 'OK',
              textColor: AppColors.text,
              bgColor: AppColors.background,
              onButtonPressed: () {
                ref.read(authViewModelProvider.notifier).clearError();
                Navigator.of(context).pop();
              },
            );
          }

          if (previous?.user != next.user && next.user != null) {
            textAnalysisVM.emptyStoredAnalysisResults();
            try {
              await textAnalysisVM.fetchAnalysisResults(next.user!);
            } catch (e) {
              LoggerService().info('Error fetching analysis results: $e');
            }
            // Reconnecting is not always necessary, as this app's dynamoDB item contains connectionId only,
            // but you must include userId as well if sending userId-specific messages,
            // hence you will need to update the userId field here
            WebSocketService().connect();
          }
        });

        return authState.isSignedIn
            ? Stack(
              children: [
                TabView(),
                AnimatedOpacity(
                  opacity: textAnalysisState.isTextAnalysisVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !textAnalysisState.isTextAnalysisVisible,
                    child: TextAnalysisScreen(),
                  ),
                ),
              ],
            )
            : const LoginScreen();
      },
    );
  }
}
