import 'package:flutter/material.dart';
import 'package:nlp_flutter/Utilities/constants.dart';

import '../../Models/analysis_result_model.dart';
import '../../Utilities/helpers.dart';
import '../../Views/s3_image_view.dart';
import 'analysis_result_detail.dart';

class AnalysisResultItem extends StatefulWidget {
  final AnalysisResult result;
  final String identityId;

  const AnalysisResultItem({
    super.key,
    required this.result,
    required this.identityId,
  });

  @override
  AnalysisResultItemState createState() => AnalysisResultItemState();
}

class AnalysisResultItemState extends State<AnalysisResultItem> {
  String getExcerptTextOnly(String text, {int maxChars = 100}) {
    final clean = text.trim().replaceAll('\n', ' ');
    if (clean.length <= maxChars) {
      return clean;
    } else {
      final snippet = clean.substring(0, maxChars);
      final lastSpace = snippet.lastIndexOf(' ');
      final safeCut =
          lastSpace != -1 ? snippet.substring(0, lastSpace) : snippet;
      return '$safeCut…'; // truncated snippet with ellipsis
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisResultDetail(analysisResult: widget.result),
          ),
        );
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          S3ImageView(
            imageId: widget.result.imageId,
            identityId: widget.identityId,
            width: 120,
            height: 180,
            fit: BoxFit.cover,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),

          SizedBox(width: 48),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppColors.text,
                    ),
                    children: [
                      const TextSpan(
                        text: '“ ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextSpan(text: getExcerptTextOnly(widget.result.text)),
                      const TextSpan(
                        text: ' ”',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                Text(
                  Utils.formatDate(widget.result.createdAt),
                  style: TextStyle(fontSize: 12, color: AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
