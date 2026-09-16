import 'package:flutter/material.dart';

import '../../../../models/entities/country.dart';
import '../../../../models/entities/country_state.dart';
import '../../../../services/services.dart';
import '../../../../widgets/common/checkout/state_selector.dart';
import '../../models/checkout_field.dart';
import 'text_input_field.dart';

class StateField extends StatefulWidget {
  const StateField({
    super.key,
    required this.countryCode,
    required this.field,
    this.controller,
  });
  final String countryCode;
  final CheckoutField field;
  final TextEditingController? controller;

  @override
  State<StateField> createState() => _StateFieldState();
}

class _StateFieldState extends State<StateField> {
  List<CountryState> states = [];
  bool _isLoading = true;

  Future<void> _loadCheckoutStates() async {
    try {
      var data = await Services().widget.loadStates(
        Country(id: widget.countryCode, name: widget.countryCode),
      );
      if (mounted) {
        setState(() {
          states = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCheckoutStates();
  }

  @override
  void didUpdateWidget(StateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload states when country code changes
    if (oldWidget.countryCode != widget.countryCode) {
      setState(() {
        _isLoading = true;
        states = [];
      });
      _loadCheckoutStates();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    if (widget.countryCode.isNotEmpty && states.isNotEmpty) {
      return StateSelector(
        states: states,
        state: widget.controller?.text,
        onChanged: (CountryState state) async {
          final currentText = state.code ?? state.id ?? '';
          widget.controller?.text = currentText;

          // Trigger rebuild to show state name immediately
          setState(() {});
        },
      );
    } else if (widget.countryCode.isNotEmpty && states.isEmpty) {
      return TextInputField(field: widget.field, controller: widget.controller);
    }
    return const SizedBox.shrink();
  }
}
