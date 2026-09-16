import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../models/entities/tera_wallet/transaction.dart';
import '../../../../models/user_model.dart';
import '../../helpers/wallet_helpers.dart';
import '../transaction_detail_screen.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final accentColor = transaction.isCredit
        ? Colors.green.shade600
        : Theme.of(context).colorScheme.error;
    var icon = Icon(CupertinoIcons.shopping_cart, color: accentColor);
    var prefix = '-';
    if (transaction.isCredit) {
      icon = Icon(CupertinoIcons.plus_circled, color: accentColor);
      prefix = '+';
    } else if (transaction.isTransfer) {
      icon = Icon(
        CupertinoIcons.arrowshape_turn_up_right_circle,
        color: accentColor,
      );
    }

    var userCreate = transaction.userCreate;
    final currentUser = Provider.of<UserModel>(context, listen: false).user!;

    var title = transaction.details;
    if (transaction.isCredit &&
        userCreate?.id != currentUser.id &&
        userCreate != null) {
      title = S
          .of(context)
          .receivedMoneyFrom(userCreate.fullName.toUpperCase());
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 20,
      minVerticalPadding: 8,
      minLeadingWidth: 24,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      subtitle: Text(
        transaction.createdTime ?? '',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Text(
          '$prefix ${WalletHelpers.parseNumberToCurrencyText(transaction.amount, currency: transaction.currency)}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      leading: Padding(padding: const EdgeInsets.only(left: 16.0), child: icon),
      onTap: () => Navigator.of(context).pushNamed(
        RouteList.teraWalletTransactionDetail,
        arguments: TransactionDetailArguments(transaction: transaction),
      ),
    );
  }
}
