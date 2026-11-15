import 'package:image_picker/image_picker.dart';

class ImageSelectionException implements Exception {
  const ImageSelectionException(this.code);
  final String code;
}

Future<XFile?> selectCropImage(ImageSource source) async {
  final image = await ImagePicker().pickImage(
    source: source,
    maxWidth: 2048,
    maxHeight: 2048,
    imageQuality: 90,
  );
  if (image != null && await image.length() > 10 * 1024 * 1024) {
    throw const ImageSelectionException('IMAGE_TOO_LARGE');
  }
  // The backend must still decode and validate actual content; file names are not trust.
  return image;
}
