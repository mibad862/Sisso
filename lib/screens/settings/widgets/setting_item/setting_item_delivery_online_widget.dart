import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../../common/constants.dart';
import '../../../../models/index.dart';
import '../../../../services/service_config.dart';
import '../../../../services/services.dart';
import 'setting_card_widget.dart';

class SettingDeliveryOnlineWidget extends StatefulWidget {
  const SettingDeliveryOnlineWidget({super.key, this.cardStyle, this.user});

  final SettingItemStyle? cardStyle;
  final User? user;

  @override
  State<SettingDeliveryOnlineWidget> createState() =>
      _SettingDeliveryOnlineWidgetState();
}

class _SettingDeliveryOnlineWidgetState
    extends State<SettingDeliveryOnlineWidget> {
  bool get _canToggleOnline {
    final user = widget.user;
    final cookie = user?.cookie ?? '';

    return user?.isDeliveryBoy == true &&
        cookie.isNotEmpty &&
        user?.isDriverAvailable != null &&
        // Delivery availability endpoint is only supported for Woo/Dokan.
        (ServerConfig().platform.isWoo || ServerConfig().platform.isDokan);
  }

  void _onUpdateDeliveryStatus(bool isOnline) {
    final user = widget.user!;
    final cookie = user.cookie ?? '';
    final previousValue = user.isDriverAvailable ?? false;

    user.isDriverAvailable = isOnline;
    setState(() {});

    final debounceKey = 'updateDeliveryStatus_${user.id ?? cookie}';
    EasyDebounce.debounce(debounceKey, const Duration(seconds: 1), () async {
      final statusCode = await Services().api.setOffTime(
        cookie,
        user.isDriverAvailable ?? false,
      );
      if (statusCode == 200) {
        return;
      }

      user.isDriverAvailable = previousValue;
      if (!mounted) {
        return;
      }

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).somethingWrong),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_canToggleOnline) {
      return const SizedBox();
    }

    final title = Text(
      '${S.of(context).deliveryManagement} ${S.of(context).availability}',
      style: const TextStyle(fontSize: 16),
    );

    final theme = Theme.of(context);

    final icon = Icon(
      CupertinoIcons.power,
      color: theme.colorScheme.secondary,
      size: 24,
    );

    switch (widget.cardStyle) {
      case SettingItemStyle.flatShadow:
        return SettingCardWidget(
          style: SettingItemStyle.flatShadow,
          child: SwitchListTile(
            secondary: Container(padding: const EdgeInsets.all(8), child: icon),
            value: widget.user!.isDriverAvailable ?? false,
            onChanged: _onUpdateDeliveryStatus,
            title: title,
          ),
        );
      case SettingItemStyle.flat:
        return SettingCardWidget(
          style: SettingItemStyle.flat,
          child: SwitchListTile(
            secondary: Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withValueOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: icon,
            ),
            value: widget.user!.isDriverAvailable ?? false,
            onChanged: _onUpdateDeliveryStatus,
            title: title,
          ),
        );
      case SettingItemStyle.flatListTile:
        return SettingCardWidget(
          style: SettingItemStyle.flatListTile,
          child: SwitchListTile(
            secondary: Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withValueOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: icon,
            ),
            value: widget.user!.isDriverAvailable ?? false,
            onChanged: _onUpdateDeliveryStatus,
            title: title,
          ),
        );
      default:
        return Column(
          children: [
            SettingCardWidget(
              style: SettingItemStyle.listTile,
              child: SwitchListTile(
                secondary: icon,
                value: widget.user!.isDriverAvailable ?? false,
                onChanged: _onUpdateDeliveryStatus,
                title: title,
              ),
            ),
            const Divider(color: Colors.black12, height: 1.0, indent: 75),
          ],
        );
    }
  }
}
