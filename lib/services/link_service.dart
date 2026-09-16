import 'dart:async';
import 'dart:convert';

import '../app.dart';
import '../common/config.dart';
import '../common/config/models/index.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../common/tools/crypt_tools.dart';
import '../models/entities/index.dart';
import '../modules/native_payment/modem_pay/modempay_deeplink_handler.dart';
import '../routes/flux_navigate.dart';
import '../screens/index.dart';
import 'base_services.dart';
import 'services.dart';

class LinkService {
  final BaseServices _serviceApi;

  LinkService(this._serviceApi);

  Future<bool> handleWebLink(
    Uri uri, {
    bool popToRootBeforeHandle = false,
  }) async {
    // Ignore some links that should not be handled by the app, such as
    // FirebaseAuth links.
    if (['firebaseauth'].contains(uri.host.toLowerCase())) {
      return false;
    }

    final context = App.fluxStoreNavigatorKey.currentContext!;
    var didShowLoading = false;

    // Call this function manually to ensure only supported links are processed.
    // Avoid popping the current screen for unsupported links (e.g.,
    // FirebaseAuth links).
    void handlePop() {
      if (popToRootBeforeHandle) {
        context.navigator.popUntil((route) => route.isFirst);
      }
    }

    try {
      // Allow showing loading indicator to avoid nothing on screen when the link
      // is being processed. The loading indicator will be hidden after the link
      // is handled.
      didShowLoading = true;
      LoadingHelper.show();

      var initUri = uri;

      // If the link has query parameters, it will be parsed
      final queryParameters = initUri.queryParameters;

      final navigationConfig = {};

      // Cart
      final cartPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.cart],
        '/cart/',
      ];
      if (cartPaths.any(initUri.path.contains)) {
        navigationConfig['screen'] = 'cart';
      }
      final shouldHandleNavigationDirectly = [
        'screen',
        'tab_number',
      ].any(queryParameters.containsKey);
      if (shouldHandleNavigationDirectly) {
        navigationConfig.addAll(queryParameters);
      }

      if (navigationConfig.isNotEmpty) {
        handlePop();
        await NavigateTools.onTapNavigateOptions(
          config: navigationConfig,
          context: context,
        );
        return true;
      }

      // Handle ModemPay payment callback
      if (ModemPayDeeplinkHandler.canHandle(uri)) {
        handlePop();
        final handled = await ModemPayDeeplinkHandler.handleDeeplink(
          context,
          uri,
        );
        if (handled) {
          return true;
        }
      }

      // Handle Shopify password reset links.
      // Matches both classic (/account/reset/…) and new tokenized (/_t/c/…) URLs.
      final isShopifyResetUrl =
          initUri.path.contains('/account/reset/') ||
          initUri.path.startsWith('/_t/c/');
      if (isShopifyResetUrl) {
        handlePop();
        unawaited(
          FluxNavigate.pushNamed(
            RouteList.resetPassword,
            arguments: uri.toString(),
            context: context,
          ),
        );
        return true;
      }

      // _showLoading(context);

      final url = initUri.toString();

      final productPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.product],
        '/product/', // WooCommerce
        'controller=product', // PrestaShop
        '/products/', // Shopify, https://shopify.inspireui.com/products/5-pocket-jean
      ];
      final productListPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.productList],
        // '/products/', // Not sure about this one, it is conflicting with product detail page in Shopify
        '/shop/',
        'collections/all', // Shopify
      ];
      final categoryPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.category],
        '/product-category/', // WooCommerce
        '/collections/', // Shopify
        'controller=category', // PrestaShop
      ];
      final brandPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.brand],
        '/brand/',
      ];
      final tagPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.tag],
        '/product-tag/', // WooCommerce
      ];
      final vendorPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.vendor],
        '/store/', // Dokan, WCFM
      ];
      final listingPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.listing],
        '/listing/',
      ];
      final blogPaths = [
        ...?customPathsToHandleDeepLink[CustomPath.blog],
        '/blog/', // WordPress
        '/post/', // WordPress
      ];

      /// PRODUCT DETAIL CASE
      if (productPaths.any(url.contains)) {
        /// Note: the deepLink URL will look like:
        /// https://domain.com/en/product/product-slug/ or
        /// https://domain.com/product/product-slug/
        final product = await Services().api.getProductByPermalink(url);
        if (product != null) {
          handlePop();

          unawaited(
            FluxNavigate.pushNamed(
              RouteList.productDetail,
              arguments: product,
              context: context,
            ),
          );
          return true;
        }

        /// PRODUCTS LIST CASE
      } else if (productListPaths.any(url.contains)) {
        handlePop();
        unawaited(
          FluxNavigate.pushNamed(
            RouteList.backdrop,
            arguments: BackDropArguments(data: [], config: {}),
            context: context,
          ),
        );
        return true;

        /// PRODUCT CATEGORY CASE
      } else if (categoryPaths.any(url.contains)) {
        final category = await Services().api.getProductCategoryByPermalink(
          url,
        );
        if (category != null) {
          handlePop();
          unawaited(
            FluxNavigate.pushNamed(
              RouteList.backdrop,
              context: context,
              arguments: BackDropArguments(
                cateId: category.id,
                cateName: category.name,
              ),
            ),
          );
          return true;
        }

        /// PRODUCT TAGS CASE
      } else if (tagPaths.any(url.contains)) {
        final slug = Uri.tryParse(url)?.pathSegments.last;

        if (slug == null) throw '';

        final tag = await Services().api.getTagBySlug(slug);
        if (tag != null) {
          handlePop();
          unawaited(
            FluxNavigate.pushNamed(
              RouteList.backdrop,
              arguments: BackDropArguments(tag: tag.id.toString()),
              context: context,
            ),
          );
          return true;
        }

        /// VENDOR DETAIL CASE
      } else if (vendorPaths.any(url.contains)) {
        final vendor = await Services().api.getStoreByPermalink(url);
        if (vendor != null) {
          handlePop();
          unawaited(
            FluxNavigate.pushNamed(
              RouteList.storeDetail,
              context: context,
              arguments: StoreDetailArgument(store: vendor),
            ),
          );
          return true;
        }

        /// BRAND CASE
      } else if (brandPaths.any(url.contains)) {
        final slug = Uri.tryParse(url)?.pathSegments.last;

        if (slug == null) throw '';

        final brand = await Services().api.getBrandBySlug(slug);
        if (brand != null) {
          handlePop();
          unawaited(
            FluxNavigate.pushNamed(
              RouteList.backdrop,
              context: context,
              arguments: BackDropArguments(
                brandId: brand.id,
                brandName: brand.name,
                brandImg: brand.image,
              ),
            ),
          );
          return true;
        }

        /// LISTING DETAIL CASE
      } else if (listingPaths.any(url.contains)) {
        final listing = await _serviceApi.getBlogByPermalink(url);
        if (listing != null) {
          final product = await _serviceApi.getProduct(listing.id);
          if (product != null) {
            handlePop();
            unawaited(
              FluxNavigate.pushNamed(
                RouteList.productDetail,
                context: context,
                arguments: product,
              ),
            );
            return true;
          }
        }

        /// BLOG CASE
      } else if (blogPaths.any(url.contains)) {
        final blog = await Services().api.getBlogByPermalink(url);
        if (blog != null) {
          handlePop();
          unawaited(
            FluxNavigate.pushNamed(
              RouteList.detailBlog,
              context: context,
              arguments: BlogDetailArguments(blog: blog),
            ),
          );
          return true;
        }
      } else {
        final base64Params = queryParameters['shared-mobile-params']
            ?.toString();
        final decryptedParams = base64Params != null
            ? CryptTools.decrypt(base64Params)
            : null;
        final paramsString = decryptedParams != null
            ? utf8.decode(base64Decode(decryptedParams))
            : null;
        final params = paramsString != null ? jsonDecode(paramsString) : {};

        /// PRODUCT LIST WITH FILTER CASE
        if (params is Map && params.isNotEmpty) {
          handlePop();
          unawaited(
            FluxNavigate.pushNamed(
              RouteList.backdrop,
              arguments: BackDropArguments(config: params, data: []),
              context: context,
            ),
          );
          return true;
        } else {
          /// BLOG CASE FALLBACK FOR BACKWARD COMPATIBILITY
          var blog = await Services().api.getBlogByPermalink(url);
          if (blog != null) {
            handlePop();
            unawaited(
              FluxNavigate.pushNamed(
                RouteList.detailBlog,
                context: context,
                arguments: BlogDetailArguments(blog: blog),
              ),
            );
            return true;
          }
        }
      }
    } catch (err) {
      // _showErrorMessage(context);
    } finally {
      if (didShowLoading) {
        LoadingHelper.hide();
      }
    }

    return false;
  }

  //
  // static void _showLoading(context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(S.of(context).loadingLink),
  //       duration: const Duration(seconds: 3),
  //       action: SnackBarAction(
  //         label: 'DISMISS',
  //         onPressed: () {
  //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //         },
  //       ),
  //     ),
  //   );
  // }
  //
  // static void _showErrorMessage(context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(S.of(context).canNotLoadThisLink),
  //       duration: const Duration(seconds: 2),
  //       action: SnackBarAction(
  //         label: 'DISMISS',
  //         onPressed: () {
  //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //         },
  //       ),
  //     ),
  //   );
  // }
}
