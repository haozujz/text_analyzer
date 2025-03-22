import 'package:flutter/material.dart';
import '../Services/storage_service.dart';

class S3ImageView extends StatefulWidget {
  final String imageId;

  const S3ImageView({super.key, required this.imageId});

  @override
  _S3ImageViewState createState() => _S3ImageViewState();
}

class _S3ImageViewState extends State<S3ImageView> {
  String? imageUrl;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchImageUrl();
  }

  Future<void> fetchImageUrl() async {
    try {
      final url = await StorageService().getDownloadUrl(
        imageId: widget.imageId,
      );

      setState(() {
        imageUrl = url;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return Scaffold(
      appBar: AppBar(title: Text('View Image')),
      body: Center(
        child:
            imageUrl != null
                ? Image.network(imageUrl!) // Display the image
                : Text('No image available'),
      ),
    );
  }
}
