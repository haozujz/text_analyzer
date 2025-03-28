import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Models/analysis_result_model.dart';
import '../../Services/logger_service.dart';
import '../../Services/network_service.dart';
import '../../Utilities/constants.dart';
import '../../ViewModels/auth_vm.dart';
import '../../ViewModels/text_analysis_vm.dart';
import '../../Views/s3_image_view.dart';

class AnalysisResultImageScreen extends ConsumerStatefulWidget {
  final AnalysisResult analysisResult;

  const AnalysisResultImageScreen({super.key, required this.analysisResult});

  @override
  ConsumerState<AnalysisResultImageScreen> createState() =>
      _AnalysisResultImageScreenState();
}

class _AnalysisResultImageScreenState
    extends ConsumerState<AnalysisResultImageScreen> {
  @override
  Widget build(BuildContext context) {
    final textAnalysisVM = ref.read(textAnalysisViewModelProvider.notifier);
    final authState = ref.read(authViewModelProvider);
    final authVM = ref.read(authViewModelProvider.notifier);

    void onDeleteTapped(String id) async {
      if (authState.user == null) {
        return;
      }
      ;
      try {
        await textAnalysisVM.deleteAnalysisResult(
          user: authState.user!,
          id: id,
        );
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        authVM.showMessageOnly("Network Error, please try again.");

        if (e is NetworkError) {
          LoggerService().error(
            "Network error calling AWS Lambda: ${e.message}",
          );
        } else {
          LoggerService().error("Network Error calling AWS Lambda: $e");
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: S3ImageView(
                  imageId: widget.analysisResult.imageId,
                  identityId: authState.identityId ?? '',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.all(Radius.circular(36)),
                ),
              ),
            ),

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
                  icon: Icon(Icons.close, color: AppColors.text, size: 32),
                  padding: EdgeInsets.all(10), // Ensures a large tap target
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

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
                  icon: Icon(Icons.more_vert, color: AppColors.text, size: 32),
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
                      () => onDeleteTapped(
                        widget.analysisResult.id,
                      ), // Pass the condition here
                    );
                  },
                ),
              ),
            ),
          ],
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
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    ),
    items: [
      PopupMenuItem(
        onTap: onTap, // Disable onTap based on the condition
        child: Text(
          "Delete",
          style: TextStyle(
            color: Colors.white,
            // Grey out text if not enabled
          ),
        ),
      ),
    ],
    color: Colors.grey[900],
    elevation: 4,
  );
}
