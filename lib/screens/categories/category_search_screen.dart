import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show AutoHideKeyboard;

import '../../common/constants.dart';
import '../common/app_bar_mixin.dart';
import '../index.dart' show SearchBox;
import 'widgets/fetch_product_layout.dart';

class CategorySearch extends StatefulWidget {
  const CategorySearch();

  @override
  State<StatefulWidget> createState() => _CategorySearchState();
}

class _CategorySearchState<T> extends State<CategorySearch> with AppBarMixin {
  final _searchFieldNode = FocusNode();
  final _searchFieldController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  /// Keyword actually sent to the API, updated after the user stops typing.
  String _keyword = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    screenScrollController = _scrollController;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFieldNode.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  void _onSearchTextChange(String value) {
    // Searching hits the server, so wait until typing pauses.
    _debounce?.cancel();
    final keyword = value.trim();
    if (keyword == _keyword) return;

    if (keyword.isEmpty) {
      setState(() {
        _keyword = '';
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _keyword = keyword;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    var theme = Theme.of(context);
    theme = Theme.of(context).copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryTextTheme: theme.textTheme,
    );
    final searchFieldLabel = MaterialLocalizations.of(context).searchFieldLabel;
    var routeName = isIos ? '' : searchFieldLabel;

    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: routeName,
      child: renderScaffold(
        routeName: RouteList.categorySearch,
        backgroundColor: theme.colorScheme.surface,
        resizeToAvoidBottomInset: false,
        secondAppBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: theme.colorScheme.surface,
          iconTheme: theme.primaryIconTheme,
          centerTitle: false,
          leadingWidth: 24,
          titleSpacing: 0,
          title: SearchBox(
            showQRCode: false,
            showSearchIcon: false,
            showCancelButton: false,
            autoFocus: true,
            controller: _searchFieldController,
            focusNode: _searchFieldNode,
            onChanged: _onSearchTextChange,
          ),
        ),
        child: AutoHideKeyboard(
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 300),
                  child: buildResult(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResult() {
    if (_keyword.isEmpty) {
      return const SizedBox.shrink();
    }
    // Same layout as the category page, so results look identical to
    // browsing a category.
    return FetchProductLayout(
      key: ValueKey('categorySearch_$_keyword'),
      search: _keyword,
      scrollController: _scrollController,
    );
  }

  void close() {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    Navigator.of(context).pop();
  }
}
