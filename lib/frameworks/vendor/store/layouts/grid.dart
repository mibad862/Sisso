import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../../../common/config.dart';
import '../../../../common/tools.dart';
import 'store_grid_style_layout.dart';

class GridStores extends StatelessWidget {
  final String? searchName;

  int get gridCountVendor => kVendorConfig.gridCountVendor;

  const GridStores({this.searchName});

  @override
  Widget build(BuildContext context) {
    return StoreGridStyleLayout(
      countVendor: gridCountVendor,
      childAspectRatio: 1,
      searchName: searchName ?? '',
      itemBuilder: (store, index) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                width: constraints.maxWidth,
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 2,
                ),
                child: Column(
                  spacing: 8.0,
                  children: <Widget>[
                    FluxImage(
                      imageUrl: store.profileUrl,
                      width: 50,
                      height: 50,
                      fit: ImageTools.boxFit(
                        kVendorConfig.profileFit,
                        defaultValue: BoxFit.cover,
                      ),
                    ),

                    Text(
                      store.name ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
