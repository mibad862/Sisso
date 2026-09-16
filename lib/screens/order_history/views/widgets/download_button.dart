import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:inspireui/inspireui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/config.dart';
import '../../../../common/theme/colors.dart';
import '../../../../models/entities/product.dart';
import '../../../../models/order/order.dart';
import '../../../../services/services.dart';

class ProductDownloadButton extends StatefulWidget {
  final ProductItem product;
  final OrderStatus orderStatus;

  const ProductDownloadButton({
    super.key,
    required this.product,
    required this.orderStatus,
  });

  @override
  State<ProductDownloadButton> createState() => _ProductDownloadButtonState();
}

class _ProductDownloadButtonState extends State<ProductDownloadButton> {
  bool isLoading = false;
  bool? _hasDownloadableFiles;

  bool get _shouldShow =>
      widget.orderStatus == OrderStatus.completed &&
      kPaymentConfig.enableDownloadProduct &&
      _hasDownloadableFiles == true;

  @override
  void initState() {
    super.initState();
    _checkDownloadableAvailable();
  }

  @override
  void didUpdateWidget(covariant ProductDownloadButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.productId != widget.product.productId ||
        oldWidget.product.variationId != widget.product.variationId ||
        oldWidget.orderStatus != widget.orderStatus) {
      _checkDownloadableAvailable();
    }
  }

  Future<void> _checkDownloadableAvailable() async {
    if (widget.orderStatus != OrderStatus.completed ||
        !kPaymentConfig.enableDownloadProduct) {
      if (!mounted) return;
      setState(() => _hasDownloadableFiles = false);
      return;
    }

    // Avoid calling the API with an invalid or missing productId.
    final productId = widget.product.productId;
    if (productId == null || productId.isEmpty) {
      if (!mounted) return;
      setState(() => _hasDownloadableFiles = false);
      return;
    }

    if (mounted) {
      setState(() => _hasDownloadableFiles = null);
    }

    try {
      final items = await _fetchDownloadableFiles();

      if (!mounted) return;
      setState(() => _hasDownloadableFiles = items.isNotEmpty);
    } catch (_) {
      if (!mounted) return;
      // Treat failures as if there are no downloadable files to avoid crashing.
      setState(() => _hasDownloadableFiles = false);
    }
  }

  Future<List<ProductDownloadItem>> _fetchDownloadableFiles() async {
    final productId = widget.product.productId;
    final variationId = widget.product.variationId;

    if (productId != null && variationId != null) {
      final variationItems = await _getVariationDownloadableFiles(
        productId,
        variationId,
      );
      if (variationItems.isNotEmpty) {
        return variationItems;
      }
    }

    return _getProductDownloadableFiles(productId);
  }

  Future<List<ProductDownloadItem>> _getVariationDownloadableFiles(
    String productId,
    String variationId,
  ) async {
    final variation = await Services().api.getVariationProduct(
      productId,
      variationId,
    );

    return _filterDownloadableFiles(variation?.downloadItems);
  }

  Future<List<ProductDownloadItem>> _getProductDownloadableFiles(
    String? productId,
  ) async {
    final product = await Services().api.overrideGetProduct(productId);

    return _filterDownloadableFiles(product?.downloadItems);
  }

  List<ProductDownloadItem> _filterDownloadableFiles(
    List<ProductDownloadItem>? sourceItems,
  ) {
    if (sourceItems == null || sourceItems.isEmpty) {
      return const [];
    }

    return sourceItems
        .where((item) => item.file?.trim().isNotEmpty == true)
        .toList();
  }

  Future<void> _handleDownloadAction(
    String file, {
    bool closeSheet = false,
  }) async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      if (closeSheet) {
        Navigator.pop(context);
      }

      await Tools.launchURL(file, mode: LaunchMode.externalApplication);

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (err) {
      if (!mounted) return;
      Tools.showSnackBar(ScaffoldMessenger.of(context), '$err');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _showDownloadableFiles() async {
    late final List<ProductDownloadItem> items;

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      items = await _fetchDownloadableFiles();
    } catch (err) {
      if (!mounted) return;
      Tools.showSnackBar(ScaffoldMessenger.of(context), '$err');
      return;
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }

    if (!mounted) return;

    try {
      if (items.isEmpty) {
        throw S.of(context).noFileToDownload;
      }

      if (items.length == 1) {
        final file = items[0].file!.trim();
        await _handleDownloadAction(file);
      } else {
        await showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final file = item.file!.trim();
                      final fileName = item.name?.trim().isNotEmpty == true
                          ? item.name!.trim()
                          : Tools.getFileNameFromUrl(file);

                      return ListTile(
                        title: Text(fileName),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            await _handleDownloadAction(file, closeSheet: true);
                          },
                          child: Text(
                            S.of(context).download,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: 1,
                  decoration: const BoxDecoration(color: kGrey200),
                ),
                ListTile(
                  title: Text(
                    S.of(context).selectTheFile,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (err) {
      if (!mounted) return;
      Tools.showSnackBar(ScaffoldMessenger.of(context), '$err');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox();
    final theme = Theme.of(context);

    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: theme.primaryColor.withValueOpacity(0.2),
      ),
      onPressed: isLoading ? null : _showDownloadableFiles,
      icon: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            )
          : Icon(Icons.file_download, color: theme.primaryColor),
      label: Text(
        S.of(context).download,
        style: TextStyle(color: theme.primaryColor),
      ),
    );
  }
}
