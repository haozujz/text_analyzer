import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Services/network_service.dart';
// import 'package:nlp_flutter/appsync.dart';
// import 'package:nlp_flutter/Services/logger_service.dart';
import '../ViewModels/auth_vm.dart';
import '../ViewModels/camera_vm.dart';
import 'Screens/text_analysis_screen.dart';
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

class BaseViewState extends ConsumerState<BaseView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    ref.read(cameraViewModelProvider.notifier).initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final textAnalysisState = ref.watch(textAnalysisViewModelProvider);
    // final textAnalysisViewModel = ref.read(
    //   textAnalysisViewModelProvider.notifier,
    // );
    final authState = ref.watch(authViewModelProvider);
    final cameraViewModel = ref.read(cameraViewModelProvider.notifier);

    return Consumer(
      builder: (context, ref, child) {
        ref.listen<TextAnalysisState>(textAnalysisViewModelProvider, (
          previous,
          next,
        ) async {
          if (previous?.isTextAnalysisVisible != next.isTextAnalysisVisible &&
              !next.isTextAnalysisVisible) {
            cameraViewModel.stopCamera();
          } else {
            Future.microtask(() {
              ref.read(cameraViewModelProvider.notifier).initializeCamera();
            });
          }
        });

        ref.listen<AuthState>(authViewModelProvider, (previous, next) async {
          if (previous?.isSignedIn != next.isSignedIn && !next.isSignedIn) {
            cameraViewModel.stopCamera();
          }
          // else {
          //   textAnalysisViewModel.toggleTextAnalysis(true);
          // }

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

          if (next.user != null) {
            // Connect to the WebSocket server
            WebSocketService().connect();

            // Send a message to the server
            //WebSocketService().sendMessage('Hello WebSocket!');

            // Disconnect after some time (for example, after 5 seconds)
            // Future.delayed(Duration(seconds: 60), () {
            //   WebSocketService().disconnect();
            // });
          }
        });

        return authState.isSignedIn
            ? Stack(
              children: [
                TabView(),
                Stack(
                  children: [
                    TabView(),
                    AnimatedOpacity(
                      opacity:
                          textAnalysisState.isTextAnalysisVisible
                              ? 1.0
                              : 0.0, // Control visibility
                      duration: const Duration(
                        milliseconds: 200,
                      ), // Smooth transition
                      child: IgnorePointer(
                        ignoring:
                            !textAnalysisState
                                .isTextAnalysisVisible, // Control interactability
                        child: TextAnalysisScreen(),
                      ),
                    ),
                  ],
                ),
              ],
            )
            : const LoginScreen();
      },
    );
  }
}
