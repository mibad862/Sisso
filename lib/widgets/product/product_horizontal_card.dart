import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../common/constants.dart';
import '../../models/index.dart' show Product;
import '../../modules/dynamic_layout/config/product_config.dart';
import '../card/short_description.dart';
import 'action_button_mixin.dart';
import 'index.dart'
    show
        ProductPricing,
        StockStatus,
        ProductRating,
        CartButton,
        HeartButton,
        StoreName,
        ProductTitle;

const _quantity = 1;

class ProductHorizontalCard extends StatefulWidget {
  final Product item;
  final ProductConfig productConfig;
  const ProductHorizontalCard({
    super.key,
    required this.item,
    required this.productConfig,
  });

  @override
  State<ProductHorizontalCard> createState() => _ProductHorizontalCardState();
}

class _ProductHorizontalCardState extends State<ProductHorizontalCard>
    with ActionButtonMixin {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: () =>
          onTapProduct(context, product: item, config: widget.productConfig),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: widget.productConfig.hMargin,
              vertical: widget.productConfig.vMargin,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.productConfig.hPadding,
              vertical: widget.productConfig.vPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                widget.productConfig.borderRadius ?? 10,
              ),
              color: Theme.of(context).cardColor,

              boxShadow: [
                if (widget.productConfig.boxShadow != null)
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(
                      widget.productConfig.boxShadow?.x ?? 0.0,
                      widget.productConfig.boxShadow?.y ?? 0.0,
                    ),
                    blurRadius:
                        widget.productConfig.boxShadow?.blurRadius ?? 0.0,
                  ),
              ],
              // color: widget.productConfig.backgroundColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        <Widget>[
                              if (widget.productConfig.showStockStatus)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: StockStatus(
                                    product: item,
                                    config: widget.productConfig,
                                  ),
                                ),
                              const SizedBox(),
                              ProductTitle(
                                product: item,
                                hide: widget.productConfig.hideTitle,
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w800,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                maxLines: widget.productConfig.titleLine,
                              ),
                              ShortDescription(
                                product: widget.item,
                                show: widget.productConfig.showShortDescription,
                              ),
                              StoreName(
                                store: item.store,
                                storeStyle: widget.productConfig.storeStyle,
                              ),
                              ProductRating(
                                product: item,
                                enableRating: widget.productConfig.enableRating,
                                hideEmptyProductListRating: widget
                                    .productConfig
                                    .hideEmptyProductListRating,
                              ),
                              ProductPricing(
                                product: item,
                                hide: widget.productConfig.hidePrice,
                              ),
                              if (widget.productConfig.showCartButton)
                                CartButton(
                                  product: item,
                                  hide: !item.canBeAddedToCartFromList(
                                    enableBottomAddToCart: widget
                                        .productConfig
                                        .enableBottomAddToCart,
                                  ),
                                  enableBottomAddToCart: widget
                                      .productConfig
                                      .enableBottomAddToCart,
                                  quantity: _quantity,
                                ),
                            ]
                            .expand(
                              (element) => [
                                element,
                                const SizedBox(height: 5.0),
                              ],
                            )
                            .toList()
                          ..removeLast(),
                  ),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.productConfig.borderRadius ?? 10),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: FluxImage(
                        imageUrl: item.imageFeature ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.productConfig.showHeart && !item.isEmptyProduct())
            Positioned(
              top: widget.productConfig.vMargin,
              right: context.isRtl ? null : widget.productConfig.hMargin,
              left: context.isRtl ? widget.productConfig.hMargin : null,
              child: HeartButton(product: item, size: 18),
            ),
        ],
      ),
    );
  }
}
