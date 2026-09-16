import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flux_ui/flux_ui.dart';

void main() {
  group('JsonSafe entity parsing', () {
    test('handles malformed scalar values without throwing', () {
      final vendor = FeaturedVendorConfig.fromJson({
        'name': 123,
        'columnCount': '4',
        'showRating': 'false',
        'enableAutoSliding': 1,
        'durationAutoSliding': '30',
        'enableBackground': 'yes',
        'isSnapping': 0,
        'limit': 'bad',
        'imageBoxfit': 9,
        'alignment': false,
      });

      expect(vendor.name, '123');
      expect(vendor.columnCount, 4);
      expect(vendor.showRating, isFalse);
      expect(vendor.enableAutoSliding, isTrue);
      expect(vendor.durationAutoSliding, 30);
      expect(vendor.enableBackground, isTrue);
      expect(vendor.isSnapping, isFalse);
      expect(vendor.limit, isNull);
      expect(vendor.imageBoxfit, '9');
      expect(vendor.alignment, 'false');
    });

    test('falls back for malformed maps and lists', () {
      final grid = CardGridLayoutConfig.fromJson({
        'gridConfig': 'not-a-map',
        'items': [
          {'name': 123, 'imageUrl': null},
          'not-a-map',
        ],
        'borderRadius': '6',
      });

      expect(grid.gridConfig, const FluxGridViewConfig());
      expect(grid.items, hasLength(1));
      expect(grid.items.first.name, '123');
      expect(grid.items.first.imageUrl, '');
      expect(grid.borderRadius, 6);

      final menu = MenuListLayoutConfig.fromJson({
        'items': 'not-a-list',
        'style': 'not-a-map',
        'itemSpacing': '12',
        'padding': {'all': 'bad'},
      });

      expect(menu.items, isEmpty);
      expect(menu.style, const MenuListItemStyle());
      expect(menu.itemSpacing, 12);
      expect(menu.padding, const EdgeInsetsDirectional.all(0));
    });

    test('handles malformed nested style config without throwing', () {
      final text = FluxTextConfig.fromJson({
        'text': 42,
        'styleConfig': {
          'styleSource': 'not-real',
          'customStyle': {
            'color': '#123',
            'fontSize': '18',
            'shadows': [
              {
                'color': '#000',
                'offset': {'dx': 'bad', 'dy': 2},
                'blurRadius': '3',
              },
              'not-a-shadow',
            ],
          },
          'textOverflow': 'ellipsis',
          'maxLines': '2',
          'textAlign': 'center',
          'containerConfig': {
            'clipBehavior': 'bad',
            'padding': {'horizontal': 'bad', 'vertical': '4'},
          },
        },
      });

      expect(text.text, '42');
      expect(text.styleConfig?.styleSource, isNull);
      expect(text.styleConfig?.customStyle?.fontSize, 18);
      expect(text.styleConfig?.textOverflow, TextOverflow.ellipsis);
      expect(text.styleConfig?.maxLines, 2);
      expect(text.styleConfig?.textAlign, TextAlign.center);
      expect(text.styleConfig?.containerConfig?.clipBehavior, Clip.none);
      expect(
        text.styleConfig?.containerConfig?.padding,
        const EdgeInsetsDirectional.symmetric(vertical: 4),
      );
    });

    test('handles malformed product and testimonial configs', () {
      final product = ProductPreview.fromJson({
        'title': 1,
        'textPrice': 2,
        'imageUrl': false,
        'textDiscountedPrice': {'bad': true},
        'discountPercentage': 'bad',
        'isFavorite': 'yes',
        'colorVariants': ['#fff', 'not-a-color'],
      });

      expect(product.title, '1');
      expect(product.textPrice, '2');
      expect(product.imageUrl, 'false');
      expect(product.textDiscountedPrice, isNull);
      expect(product.discountPercentage, isNull);
      expect(product.isFavorite, isTrue);
      expect(product.colorVariants, [Colors.white]);

      final testimonial = HorizontalTestimonialConfig.fromJson({
        'style': {
          'elementOrder': ['image', 'bad', 'reviewText'],
          'ratingStyleConfig': {'color': '#444444', 'size': '20'},
        },
        'listConfig': 'not-a-map',
        'items': [
          {
            'id': 7,
            'userTile': {
              'name': 99,
              'rating': '4.5',
              'ratingStyleConfig': 'not-a-map',
            },
          },
          'not-a-map',
        ],
        'design': 'chat',
      });

      expect(testimonial.design, HorizontalTestimonialDesign.chat);
      expect(testimonial.listConfig, const FluxListViewConfig());
      expect(testimonial.items, hasLength(1));
      expect(testimonial.items.first.id, '7');
      expect(testimonial.items.first.userTile?.name, '99');
      expect(testimonial.items.first.userTile?.rating, 4.5);
      expect(testimonial.style.elementOrder, [
        ProductReviewTileElement.image,
        ProductReviewTileElement.reviewText,
      ]);
      expect(testimonial.style.ratingStyleConfig.size, 20);
    });
  });
}
