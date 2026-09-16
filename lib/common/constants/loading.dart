part of '../constants.dart';

Widget kCustomFooter(BuildContext context) => CustomFooter(
  height: 200.0,
  builder: (BuildContext context, LoadStatus? mode) {
    Widget body;
    if (mode == LoadStatus.idle) {
      body = Text(S.of(context).pullToLoadMore);
    } else if (mode == LoadStatus.loading) {
      body = kLoadingWidget(context);
    } else if (mode == LoadStatus.failed) {
      body = Text(S.of(context).loadFail);
    } else if (mode == LoadStatus.canLoading) {
      body = Text(S.of(context).releaseToLoadMore);
    } else {
      body = Text(S.of(context).noData);
    }
    return SizedBox(
      height: 48.0,
      child: Align(alignment: Alignment.topCenter, child: body),
    );
  },
);

Widget kClassicHeader(BuildContext context) => ClassicHeader(
  completeText: S.of(context).refreshCompleted,
  refreshingText: S.of(context).refreshing,
  releaseText: S.of(context).releaseToRefresh,
  idleText: S.of(context).pullToRefresh,
  failedText: S.of(context).loadFailed,
);
