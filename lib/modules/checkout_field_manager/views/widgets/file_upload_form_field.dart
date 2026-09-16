import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:path/path.dart' as path_util;
import 'package:provider/provider.dart';

import '../../../../models/index.dart' show UserModel;
import '../../../../services/services.dart';
import '../../helpers/checkout_helper.dart';
import '../../models/checkout_field.dart';

class FileUploadFormField extends StatefulWidget {
  const FileUploadFormField({
    super.key,
    required this.field,
    this.controller,
    this.validator,
  });

  final CheckoutField field;

  /// Holds the uploaded file URL as text, same contract as other text fields.
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  @override
  State<FileUploadFormField> createState() => _FileUploadFormFieldState();
}

class _FileUploadFormFieldState extends State<FileUploadFormField> {
  bool _uploading = false;

  String? get _fileUrl => widget.controller?.text.isNotEmpty == true
      ? widget.controller!.text
      : null;

  String? get _fileName =>
      _fileUrl != null ? Uri.parse(_fileUrl!).pathSegments.last : null;

  Future<void> _pick(FormFieldState<String> state) async {
    final cookie = context.read<UserModel>().user?.cookie;
    if (cookie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).pleaseSignInBeforeUploading)),
      );
      return;
    }

    final file = await FilePicker.pickFile();
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final response = await Services().api.uploadImage({
        'title': {'rendered': path_util.basename(file.path ?? file.name)},
        'media_attachment': base64.encode(bytes),
        'media_path': 'checkout_field_uploads',
      }, cookie);
      // Prefer source_url (direct WP path) over guid.rendered which may be
      // rewritten by CDN plugins such as Optimole.
      final url =
          response?['source_url']?.toString() ??
          response?['guid']?['rendered']?.toString() ??
          '';
      widget.controller?.text = url;
      state.didChange(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).fileUploadFailed)));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _remove(FormFieldState<String> state) {
    widget.controller?.clear();
    state.didChange(null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final label = getLabelInput(widget.field);
    final description = widget.field.description;
    final theme = Theme.of(context);

    return FormField<String>(
      initialValue: _fileUrl,
      validator: (val) {
        final base = validateField(
          context,
          widget.controller?.text,
          widget.field,
        );
        if (base != null) return base;
        if (widget.validator != null) return widget.validator!(val);
        return null;
      },
      builder: (state) {
        return Column(
          spacing: 5.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 4.0,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (description?.isNotEmpty ?? false)
                  Tooltip(
                    message: description!,
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.hintColor,
                    ),
                  ),
              ],
            ),
            if (_fileUrl != null)
              _FileChip(
                name: _fileName ?? _fileUrl!,
                onRemove: () => _remove(state),
              )
            else
              OutlinedButton.icon(
                onPressed: _uploading ? null : () => _pick(state),
                icon: _uploading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.attach_file, size: 18),
                label: Text(
                  widget.field.placeholder?.isNotEmpty == true
                      ? widget.field.placeholder!
                      : S.of(context).uploadImage,
                ),
              ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FileChip extends StatelessWidget {
  const _FileChip({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.insert_drive_file_outlined, size: 18),
      label: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
    );
  }
}
