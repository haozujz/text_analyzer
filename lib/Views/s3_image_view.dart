import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nlp_flutter/Services/logger_service.dart';
import '../Services/storage_service.dart';
import '../Utilities/Constants.dart';

class S3ImageView extends StatefulWidget {
  final String imageId;
  final String identityId;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const S3ImageView({
    super.key,
    required this.imageId,
    required this.identityId,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<S3ImageView> createState() => _S3ImageViewState();
}

class _S3ImageViewState extends State<S3ImageView> {
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImageUrl();
  }

  Future<void> _fetchImageUrl() async {
    try {
      final url = await StorageService().getUrl(
        imageId: widget.imageId,
        identityId: widget.identityId,
      );

      if (!mounted) return;

      setState(() {
        imageUrl = url;
        isLoading = false;
      });
    } catch (e) {
      LoggerService().error("Error fetching image URL: $e");
      if (!mounted) return;
      setState(() {
        imageUrl = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (isLoading) {
      return _buildPlaceholder(
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        cacheKey: '${widget.identityId}/${widget.imageId}.jpg',
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        placeholder:
            (context, url) => _buildPlaceholder(
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
              ),
            ),
        errorWidget: (context, url, error) {
          LoggerService().error('Cached image load failed: $error');
          return _buildFallbackBox();
        },
      );
    }

    return _buildFallbackBox();
  }

  Widget _buildPlaceholder({Widget? child}) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.background,
      alignment: Alignment.center,
      child: child ?? const SizedBox.shrink(),
    );
  }

  Widget _buildFallbackBox() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
    );
  }
}
