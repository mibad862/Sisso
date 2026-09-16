import 'package:flux_ui/flux_ui.dart';

import '../constants.dart';

extension StoreImageExt on Store? {
  String get bannerUrl =>
      _resolveVendorImage(this?.banner, kDefaultStoreBanner);

  String get profileUrl =>
      _resolveVendorImage(this?.image, kDefaultStoreProfile);
}

String _resolveVendorImage(String? imageUrl, String fallback) {
  final normalizedUrl = imageUrl?.trim().toLowerCase();
  if (normalizedUrl == null || normalizedUrl.isEmpty) {
    return fallback;
  }
  return imageUrl!.trim();
}
