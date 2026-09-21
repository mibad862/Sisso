import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools/flash.dart';
import '../../models/app_model.dart';
import '../../services/service_config.dart';
import '../common/app_bar_mixin.dart';

class LanguageScreen extends StatefulWidget {
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> with AppBarMixin {
  bool isUpdating = false;

  Color _backgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surface
      : const Color(0xFFF7F7F9);

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    var languages = getLanguages();
    final currentLanguage = Provider.of<AppModel>(
      context,
      listen: false,
    ).langCode;

    for (var i = 0; i < languages.length; i++) {
      if (ServerConfig().isVendorManagerType()) {
        if (unsupportedLanguages.contains(languages[i]['code'])) {
          continue;
        }
      }
      final isSelected = currentLanguage == languages[i]['code'];
      list.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
            leading: FluxImage(
              imageUrl: languages[i]['icon'],
              width: 30,
              height: 20,
              fit: BoxFit.cover,
            ),
            title: Text(
              languages[i]['text'],
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            onTap: isUpdating
                ? null
                : () {
                    if (isSelected) {
                      return;
                    }
                    setState(() {
                      isUpdating = true;
                    });
                    Provider.of<AppModel>(
                      context,
                      listen: false,
                    ).changeLanguage(languages[i]['code'], context).then((_) {
                      setState(() {
                        isUpdating = false;
                      });
                      FlashHelper.message(
                        context,
                        message: S.of(context).languageSuccess,
                      );
                      context.navigator.pop();
                    });
                  },
            trailing: !isSelected
                ? null
                : Icon(Icons.check, color: Theme.of(context).primaryColor),
          ),
        ),
      );
    }

    return renderScaffold(
      routeName: RouteList.language,
      secondAppBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          S.of(context).language,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _backgroundColor(context),
        leading: isUpdating
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox.square(
                  dimension: 24.0,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 2.0,
                  ),
                ),
              )
            : Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
      ),
      backgroundColor: _backgroundColor(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            ...list,
            SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }
}
