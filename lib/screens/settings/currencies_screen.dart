import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools/flash.dart';
import '../../models/app_model.dart';
import '../../services/services.dart';
import '../base_screen.dart';
import '../common/app_bar_mixin.dart';

class CurrenciesScreen extends StatefulWidget {
  @override
  BaseScreen<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends BaseScreen<CurrenciesScreen>
    with AppBarMixin {
  final ValueNotifier<List<Currency>?> _availableCurrenciesNotifier =
      ValueNotifier<List<Currency>?>(null);
  String? currencyDisplay;

  @override
  void afterFirstLayout(BuildContext context) {
    currencyDisplay = Provider.of<AppModel>(context, listen: false).currency;
    getCurrency();
    setState(() {});
  }

  Future<void> getCurrency() async {
    final currencies = await Services().api.getAvailableCurrencies();
    _availableCurrenciesNotifier.value = currencies;
  }

  @override
  void dispose() {
    _availableCurrenciesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return renderScaffold(
      routeName: RouteList.currencies,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: showAppBar(RouteList.currencies) ? EdgeInsets.zero : null,
        ),
        child: Scaffold(
          backgroundColor: _backgroundColor(context),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: _backgroundColor(context),
            title: Text(
              S.of(context).currencies,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          body: buildListCurrency(),
        ),
      ),
    );
  }

  Widget buildListCurrency() {
    final currencies = kCurrencyConfig.currencies;
    return ValueListenableBuilder(
      valueListenable: _availableCurrenciesNotifier,
      builder: (_, availableCurrencies, __) {
        if (availableCurrencies == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final supportedCurrencies = availableCurrencies.isEmpty
            ? currencies
            : currencies.where(
                (element) => availableCurrencies.any(
                  (e) => e.countryCode == element.countryCode,
                ),
              );

        // final unsupportedCurrencies = currencies
        //     .where((element) => !supportedCurrencies.contains(element));

        // final allCurrencies = [
        //   ...supportedCurrencies,
        //   ...unsupportedCurrencies
        // ];
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: currencies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final currency = currencies[index];
            return buildItem(
              currency,
              isEnable: supportedCurrencies.contains(currency),
            );
          },
        );
      },
    );
  }

  Color _backgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surface
      : const Color(0xFFF7F7F9);

  Widget buildItem(Currency currency, {bool isEnable = true}) {
    final theme = Theme.of(context);
    final isSelected = currencyDisplay == currency.currencyDisplay;

    return Opacity(
      opacity: isEnable ? 1 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.dividerColor.withValues(alpha: 0.35),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          enabled: isEnable,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 6,
          ),
          title: Text(
            '${currency.currencyDisplay} (${currency.symbol})',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          onTap: () {
            setState(() {
              currencyDisplay = currency.currencyDisplay;
            });

            Provider.of<AppModel>(
              context,
              listen: false,
            ).changeCurrency(context, currency);

            FlashHelper.message(
              context,
              message: S
                  .of(context)
                  .changedCurrencyTo(currency.currencyDisplay),
            );
            context.navigator.pop();
          },
          trailing: isSelected
              ? Icon(Icons.check, color: theme.primaryColor)
              : const SizedBox(width: 20),
        ),
      ),
    );
  }
}
