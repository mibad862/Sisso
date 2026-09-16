import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../common/extensions/extensions.dart';
import '../../../models/entities/country_state.dart';
import '../../../modules/dynamic_layout/helper/helper.dart';

class StateSelector extends StatelessWidget {
  const StateSelector({
    super.key,
    required this.states,
    this.state,
    required this.onChanged,
  });
  final List<CountryState> states;
  final String? state;
  final Function(CountryState) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Layout.isDisplayDesktop(context);
    var items = <DropdownMenuItem>[];
    for (var item in states) {
      items.add(
        DropdownMenuItem(
          value: item.id,
          child: Text(item.name?.toString().unescape() ?? ''),
        ),
      );
    }
    String? value;

    final firstState = states.firstWhereOrNull(
      (o) =>
          o.id.toString() == state?.toString() || o.name == state?.toString(),
    );

    if (firstState != null) {
      value = firstState.id;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              S.of(context).stateProvince,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
          ),
        Container(
          height: isDesktop ? 51 : null,
          decoration: isDesktop
              ? BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.surface,
                )
              : null,
          padding: isDesktop ? const EdgeInsets.all(16) : null,
          child: DropdownButton(
            items: items,
            value: value,
            onChanged: (dynamic val) async {
              onChanged(CountryState(id: val));
            },
            isExpanded: true,
            itemHeight: 70,
            icon: isDesktop
                ? const Icon(Icons.arrow_drop_down, size: 20)
                : null,
            hint: Text(S.of(context).stateProvince),
            underline: isDesktop ? const SizedBox() : null,
          ),
        ),
      ],
    );
  }
}
