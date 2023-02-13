// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'platform_widget.dart';

/// {@template ui.auth.widgets.internal.universal_text_form_field}
/// Uses [TextFormField] under mateiral library and [CupertinoTextFormFieldRow]
/// under cupertion.
class UniversalTextFormField extends PlatformWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? Function(String?)? validator;
  final void Function(String?)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool autofocus;
  final bool obscureText;
  final FocusNode? focusNode;
  final bool? enableSuggestions;
  final bool autocorrect;
  final Widget? prefix;
  final Iterable<String>? autofillHints;
  final bool allowToggleObscure;

  const UniversalTextFormField({
    Key? key,
    this.controller,
    this.prefix,
    this.placeholder,
    this.validator,
    this.onSubmitted,
    this.inputFormatters,
    this.keyboardType,
    this.autofocus = false,
    this.obscureText = false,
    this.focusNode,
    this.enableSuggestions,
    this.autocorrect = false,
    this.autofillHints,
    this.allowToggleObscure = false,
  }) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.inactiveGray,
          ),
        ),
      ),
      child: CupertinoTextFormFieldRow(
        autocorrect: autocorrect,
        autofillHints: autofillHints,
        focusNode: focusNode,
        padding: EdgeInsets.zero,
        controller: controller,
        placeholder: placeholder,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        autofocus: autofocus,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        obscureText: obscureText,
        prefix: prefix,
      ),
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    bool myObscureText = obscureText;
    return  StatefulBuilder(builder: (_context, _setState) {
      var myInputDec = InputDecoration(
        labelText: placeholder,
        prefix: prefix,
      );
      if (allowToggleObscure) {
        myInputDec = InputDecoration(
          labelText: placeholder,
          prefix: prefix,
          suffixIcon: IconButton(
            icon: Icon(
              myObscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.blue, // TODO need a theme color
            ),
            onPressed: () {
              // use _setState that belong to StatefulBuilder
              _setState(() {
                myObscureText = !myObscureText;
              });
            },
          ),
        );
      }
      return TextFormField(
        autocorrect: autocorrect,
        autofillHints: autofillHints,
        autofocus: autofocus,
        focusNode: focusNode,
        controller: controller,
        decoration: myInputDec,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        obscureText: myObscureText,
      );
    });
  }
}
