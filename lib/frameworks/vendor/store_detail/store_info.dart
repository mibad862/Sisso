import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../screens/detail/widgets/video_feature.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../widgets/common/index.dart';
import 'widgets/contact.dart';
import 'widgets/store_map.dart';

class StoreInfoWidget extends StatelessWidget {
  final Store? store;

  const StoreInfoWidget({super.key, this.store});

  bool get hasAnyInfo {
    final storeInfo = store;
    if (storeInfo == null) return false;

    final contact = Contact(store: storeInfo);
    final hasContactInfo = contact.contactDetails.isNotEmpty;

    final hasDescription =
        storeInfo.showDescription &&
        storeInfo.description != null &&
        storeInfo.description!.trim().isNotEmpty;

    final hasLocation =
        storeInfo.lat != null &&
        storeInfo.long != null &&
        !kVendorConfig.hideStoreContactInfo;

    return hasContactInfo || hasDescription || hasLocation;
  }

  @override
  Widget build(BuildContext context) {
    if (!hasAnyInfo) {
      return Center(
        child: EmptyStateWidget(
          title: S.of(context).noStoreInformation,
          image: kNoInfomation,
        ),
      );
    }

    // becase hasAnyInfo is true, so store is not null
    final storeInfo = store!;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Contact(store: storeInfo),
            ExpansionInfo(
              hide: !storeInfo.showDescription,
              expand: true,
              title: S.of(context).description,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: HtmlWidget(
                    storeInfo.description ?? '',
                    customWidgetBuilder: (element) {
                      // -------- YouTube iframe --------
                      if (element.localName == 'iframe') {
                        return FeatureVideoPlayer.fromHtmlYoutubeIframe(
                          attributes: element.attributes,
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (storeInfo.lat != null && storeInfo.long != null)
              ExpansionInfo(
                hide: kVendorConfig.hideStoreContactInfo,
                expand: kVendorConfig.expandStoreLocationByDefault,
                title: S.of(context).location,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: StoreMap(store: storeInfo),
                  ),
                ],
              ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
