import 'dart:io';

/// A small wrapper for an image file to be sent to the backend via multipart.
class SkinRequest {
  final File imageFile;

  SkinRequest({required this.imageFile});
}
