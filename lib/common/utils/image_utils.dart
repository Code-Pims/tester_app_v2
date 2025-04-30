import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageService {
  Future<Size> getImageSize(String imageUrl) {
    Completer<Size> completer = Completer();
    Image image = Image(
        image: CachedNetworkImageProvider(imageUrl)); // I modified this line
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  /// Check if the image is portrait or landscape
  Future<bool> isPortrait(String imageUrl) async {
    final size = await getImageSize(imageUrl);
    return size.height > size.width;
  }
}
