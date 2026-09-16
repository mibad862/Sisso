import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../../../common/config.dart';
import '../../../../common/extensions/store_ext.dart';
import '../../../../common/tools/image_tools.dart';
import 'store_grid_style_layout.dart';

class ColumnStores extends StatelessWidget {
  static const String type = 'column';
  final String? searchName;

  int get columnCountVendor => kVendorConfig.columnCountVendor;

  const ColumnStores({this.searchName});

  @override
  Widget build(BuildContext context) {
    return StoreGridStyleLayout(
      countVendor: columnCountVendor,
      childAspectRatio: 0.75,
      searchName: searchName ?? '',
      itemBuilder: (store, index) {
        final bannerUrl = store.bannerUrl;
        final profileUrl = store.profileUrl;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                return FluxImage(
                  imageUrl: bannerUrl,
                  fit: ImageTools.boxFit(
                    kVendorConfig.bannerFit,
                    defaultValue: BoxFit.cover,
                  ),
                  width: constraints.maxWidth,
                );
              },
            ),
            Container(
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              child: Column(
                spacing: 5.0,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: FluxImage(
                      imageUrl: profileUrl,
                      fit: ImageTools.boxFit(
                        kVendorConfig.profileFit,
                        defaultValue: BoxFit.cover,
                      ),
                      height: 50.0,
                      width: 50.0,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  Text(
                    store.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
