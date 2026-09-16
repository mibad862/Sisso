import 'package:flutter/material.dart';
import 'package:inspireui/extensions/color_extension.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:provider/provider.dart';

import '../../../models/app_model.dart';
import '../config/app_config.dart';
import '../config/app_setting.dart';
import '../config/tab_bar_config.dart';
import '../helper/helper.dart';
import 'tab_indicator/index.dart';
import 'tab_minimize/index.dart';
import 'tabbar.dart' as custom;
import 'tabbar_icon.dart';

final _tweenOffset = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: const Offset(0.0, 0.0),
);

class TabBarCustom extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTap;
  final List<TabBarMenuConfig> tabData;
  final bool shouldHideTabBar;
  final bool showTabMinimize;
  final AppSetting config;

  final int totalCart;

  const TabBarCustom({
    super.key,
    this.shouldHideTabBar = false,
    this.showTabMinimize = false,
    required this.config,
    required this.totalCart,
    required this.tabController,
    required this.onTap,
    required this.tabData,
  });

  Decoration _buildIndicator(context) {
    final tabConfig = config.tabBarConfig;

    // In liquid glass mode the active tab item is wrapped in a real glass lens
    // (see [_buildTabBar]), so the indicator is skipped entirely.
    if (tabConfig.liquidGlass) {
      return const BoxDecoration(color: Colors.transparent);
    }

    final indicator = tabConfig.tabBarIndicator;

    switch (tabConfig.indicatorStyle) {
      case IndicatorStyle.dot:
        return DotIndicator(
          radius: indicator.radius ?? 3,
          color: indicator.color ?? Theme.of(context).primaryColor,
          distanceFromCenter: indicator.distanceFromCenter ?? 20.0,
          strokeWidth: indicator.strokeWidth ?? 1.0,
          paintingStyle: indicator.paintingStyle ?? PaintingStyle.fill,
        );
      case IndicatorStyle.material:
        final indicatorHeight = indicator.height ?? 4;
        if (indicatorHeight <= 0) {
          // What good is a indicator if its height is <= zero?
          break;
        }
        return MaterialIndicator(
          height: indicatorHeight,
          tabPosition: indicator.tabPosition,
          topRightRadius: indicator.topRightRadius ?? 5,
          topLeftRadius: indicator.topLeftRadius ?? 5,
          bottomRightRadius: indicator.bottomRightRadius ?? 0,
          bottomLeftRadius: indicator.bottomLeftRadius ?? 0,
          color: indicator.color ?? Theme.of(context).primaryColor,
          horizontalPadding: indicator.horizontalPadding ?? 0.0,
          strokeWidth: indicator.strokeWidth ?? 1.0,
          paintingStyle: indicator.paintingStyle ?? PaintingStyle.fill,
        );
      case IndicatorStyle.rectangular:
        return RectangularIndicator(
          topRightRadius: indicator.topRightRadius ?? 5,
          topLeftRadius: indicator.topLeftRadius ?? 5,
          bottomRightRadius: indicator.bottomRightRadius ?? 0,
          bottomLeftRadius: indicator.bottomLeftRadius ?? 0,
          color: indicator.color ?? Theme.of(context).primaryColor,
          horizontalPadding: indicator.horizontalPadding ?? 0.0,
          strokeWidth: indicator.strokeWidth ?? 1.0,
          verticalPadding: indicator.verticalPadding ?? 0.0,
          paintingStyle: indicator.paintingStyle ?? PaintingStyle.fill,
        );
      case IndicatorStyle.none:
      default:
        break;
    }

    return const BoxDecoration(color: Colors.transparent);
  }

  Widget _buildTabBar(context) {
    final theme = Theme.of(context);
    final tabConfig = config.tabBarConfig;

    final labelTextStyle = theme.primaryTextTheme.bodyLarge;
    final colorIcon = tabConfig.colorIcon ?? theme.colorScheme.secondary;
    final colorActiveIcon = tabConfig.colorActiveIcon ?? theme.primaryColor;

    final indicatorSize = tabConfig.liquidGlass
        ? TabBarIndicatorSize.tab
        : tabConfig.tabBarIndicator.indicatorSize ??
              (tabConfig.indicatorStyle == IndicatorStyle.rectangular
                  ? TabBarIndicatorSize.tab
                  : TabBarIndicatorSize.label);

    final position = tabConfig.tabBarFloating.position;
    final floatingIndex = (position != null && position < tabData.length)
        ? position
        : (tabData.length / 2).floor();

    Widget buildTab(int i) {
      if (tabData[i].visible == false || tabData[i].groupLayout == true) {
        return const SizedBox.shrink();
      }

      final currentTabIndex = tabController.index;
      final Widget icon = TabBarIcon(
        key: Key('TabBarIcon-$i'),
        item: tabData[i],
        totalCart: totalCart,
        isActive: i == currentTabIndex,
        isEmptySpace: tabConfig.showFloating && i == floatingIndex,
        config: tabConfig,
      );
      // In liquid glass mode, wrap the active tab item in a real glass lens
      // instead of drawing an indicator.
      if (tabConfig.liquidGlass && i == currentTabIndex) {
        return _wrapTabItemGlass(tabConfig, icon);
      }
      return icon;
    }

    return ListenableBuilder(
      listenable: tabController,
      builder: (context, child) {
        return custom.TabBar(
          key: const Key('mainTabBar'),
          controller: tabController,
          onTap: onTap,
          tabs: [for (var i = 0; i < tabData.length; i++) buildTab(i)],
          isScrollable: false,
          labelColor: colorActiveIcon,
          unselectedLabelColor: colorIcon,
          indicatorSize: indicatorSize,
          indicatorColor: colorActiveIcon,
          indicator: _buildIndicator(context),
          // Disable the ink splash/highlight so pressing or long-pressing a tab
          // shows no grey overlay.
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          unselectedLabelStyle: labelTextStyle,
          labelStyle: labelTextStyle,
        );
      },
    );
  }

  /// Wrap the tab bar with an iOS 26-style liquid glass effect.
  Widget _wrapLiquidGlass(TabBarConfig tabBarConfig, Widget child) {
    if (!tabBarConfig.liquidGlass) {
      return child;
    }

    final maxCorner = [
      tabBarConfig.radiusTopLeft,
      tabBarConfig.radiusTopRight,
      tabBarConfig.radiusBottomLeft,
      tabBarConfig.radiusBottomRight,
    ].reduce((a, b) => a > b ? a : b);
    final radius = maxCorner > 0 ? maxCorner : 50.0;

    return LiquidGlassLens(
      style: LiquidGlassStyle(
        shape: LiquidGlassShape.continuousRoundedRectangle(
          cornerRadius: radius,
          clipQuality: LiquidGlassClipQuality.roundedRectangle,
          borderColor: null,
          borderType: const ClassicBorder(),
          borderWidth: 1.0,
          lightColor: const Color(0xB2FFFFFF),
          lightDirection: 0.0,
          lightIntensity: 1.0,
          lightMode: LiquidGlassLightMode.edge,
        ),
        appearance: LiquidGlassAppearance(
          color: tabBarConfig.color ?? Colors.transparent,
          blur: const LiquidGlassBlur(sigmaX: 4, sigmaY: 4),
          enableInnerRadiusTransparent: false,
          saturation: 1.0,
        ),
        refraction: const LiquidGlassRefraction(
          distortion: 0.25,
          chromaticAberration: 0.003,
          diagonalFlip: 0,
          distortionWidth: 30,
          magnification: 1,
          refractionMode: LiquidGlassRefractionMode.shapeRefraction,
          refractionType: null,
        ),
      ),
      child: child,
    );
  }

  /// Wrap the active tab item in a real glass lens, honoring the
  /// `TabBarIndicator` config (color, paddings and corner radius).
  ///
  /// Note: [LiquidGlassShape] only supports a single corner radius, so the
  /// largest of the four configured radii is used.
  Widget _wrapTabItemGlass(TabBarConfig tabBarConfig, Widget child) {
    final indicator = tabBarConfig.tabBarIndicator;

    final maxCorner = [
      indicator.topLeftRadius ?? 0.0,
      indicator.topRightRadius ?? 0.0,
      indicator.bottomLeftRadius ?? 0.0,
      indicator.bottomRightRadius ?? 0.0,
    ].reduce((a, b) => a > b ? a : b);
    final radius = maxCorner > 0 ? maxCorner : 50.0;
    final hPad = indicator.horizontalPadding ?? 16.0;
    final vPad = indicator.verticalPadding ?? 4.0;

    Widget lens = LiquidGlassLens(
      style: LiquidGlassStyle(
        shape: LiquidGlassShape.continuousRoundedRectangle(
          cornerRadius: radius,
          clipQuality: LiquidGlassClipQuality.roundedRectangle,
          borderColor: (indicator.paintingStyle == PaintingStyle.fill)
              ? null
              : indicator.color,
          borderType: const OpticalBorder(),
          borderWidth: indicator.strokeWidth ?? 1.0,
          lightColor: const Color(0xB2FFFFFF),
          lightDirection: 0.0,
          lightIntensity: 1.0,
          lightMode: LiquidGlassLightMode.edge,
        ),
        appearance: LiquidGlassAppearance(
          color: (indicator.paintingStyle == PaintingStyle.fill)
              ? (indicator.color ?? Colors.transparent)
              : Colors.transparent,
          blur: const LiquidGlassBlur(),
          enableInnerRadiusTransparent: false,
          saturation: 1.0,
        ),
        refraction: const LiquidGlassRefraction(
          distortion: 0.25,
          chromaticAberration: 0.003,
          diagonalFlip: 0,
          distortionWidth: 30,
          magnification: 1,
          refractionMode: LiquidGlassRefractionMode.shapeRefraction,
          refractionType: null,
        ),
      ),
      child: (hPad > 0 || vPad > 0)
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: child,
            )
          : child,
    );

    return lens;
  }

  @override
  Widget build(BuildContext context) {
    final tabConfig = config.tabBarConfig;
    final appModel = Provider.of<AppModel>(context, listen: false);
    final advertisement = appModel.advertisement;
    final useSafeArea = advertisement.hasContainBannerAd && advertisement.enable
        ? false
        : tabConfig.isSafeArea;

    /// error could happen on hide tab menu length
    ErrorWidget.builder = (error) => const SizedBox();

    if (showTabMinimize) {
      return TabMinimize(
        tabData: tabData,
        totalCart: totalCart,
        selectedIndex: tabController.index,
        tabBarConfig: tabConfig,
        onTap: (index) => {tabController.animateTo(index)},
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        final offsetAnimation = _tweenOffset.animate(animation);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      child: shouldHideTabBar
          ? const SizedBox()
          : Container(
              color:
                  (tabConfig.showFloating ||
                      tabConfig.floating ||
                      tabConfig.liquidGlass)
                  ? null
                  : Theme.of(context).colorScheme.surface,
              child: Container(
                margin: EdgeInsets.only(
                  left: tabConfig.marginLeft,
                  right: tabConfig.marginRight,
                  bottom: tabConfig.marginBottom,
                  top: tabConfig.marginTop,
                ),
                decoration: BoxDecoration(
                  // Only set BoxDecoration color for bottom tabbar (can be
                  // understood as setting background color with
                  // BoxDecoration) when showFloating is false
                  //
                  // When showFloating = true then background color is set
                  // in _renderBottomBar function (lib/menu/maintab.dart)
                  color: tabConfig.showFloating || tabConfig.liquidGlass
                      ? null
                      : tabConfig.color ??
                            Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(tabConfig.radiusTopLeft),
                    topRight: Radius.circular(tabConfig.radiusTopRight),
                    bottomLeft: Radius.circular(tabConfig.radiusBottomLeft),
                    bottomRight: Radius.circular(tabConfig.radiusBottomRight),
                  ),
                  boxShadow: [
                    if (!tabConfig.showFloating)
                      BoxShadow(
                        spreadRadius: tabConfig.boxShadow?.spreadRadius ?? 0.0,
                        blurRadius: tabConfig.boxShadow?.blurRadius ?? 0.0,
                        offset: Offset(
                          tabConfig.boxShadow?.x ?? 0.0,
                          tabConfig.boxShadow?.y ?? 0.0,
                        ),
                        color: Colors.grey.withValueOpacity(
                          tabConfig.boxShadow?.colorOpacity ?? 0.0,
                        ),
                      ),
                  ],
                ),
                child: SafeArea(
                  bottom: useSafeArea,
                  child: _wrapLiquidGlass(
                    tabConfig,
                    Container(
                      margin: EdgeInsets.only(
                        left: tabConfig.paddingLeft,
                        right: tabConfig.paddingRight,
                        top: tabConfig.paddingTop,
                        bottom: tabConfig.paddingBottom,
                      ),
                      decoration: BoxDecoration(
                        border: tabConfig.enableDivider
                            ? Border(
                                top: !tabConfig.enableOnTop
                                    ? BorderSide(
                                        color: Theme.of(context).dividerColor,
                                        width: 0.5,
                                      )
                                    : BorderSide.none,
                                bottom: tabConfig.enableOnTop
                                    ? BorderSide(
                                        color: Theme.of(context).dividerColor,
                                        width: 0.5,
                                      )
                                    : BorderSide.none,
                              )
                            : null,
                      ),
                      child: !Layout.isDisplayDesktop(context)
                          ? SizedBox(
                              width: double.infinity,
                              child: _buildTabBar(context),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  Expanded(
                                    flex: 6,
                                    child: _buildTabBar(context),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
