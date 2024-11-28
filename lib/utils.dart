import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'model.dart';

final isDesktop = (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

Future launchUrlPlus(String? url) async {
  if (url == null) {
    return;
  }

  if (!await launchUrlString(url,
      mode: LaunchMode.externalNonBrowserApplication)) {
    await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}

void progressDialog({
  required BuildContext context,
  required Future future,
}) =>
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) => FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {}
          if (snapshot.connectionState == ConnectionState.waiting) {}
          if (snapshot.connectionState == ConnectionState.active) {}
          if (snapshot.connectionState == ConnectionState.done) {
            if (context.mounted && context.canPop()) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.pop();
              });
            }
          }
          if (snapshot.hasError) {}

          final textTheme = Theme.of(context).textTheme.titleMedium;

          return (context.watch<Model>().progress < 100)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade300),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.watch<Model>().progressMessage,
                      style: textTheme?.copyWith(color: Colors.white),
                    ),
                  ],
                )
              : const SizedBox.shrink();
        },
      ),
    );

void showConfirmDialog({
  required BuildContext context,
  required Widget content,
  required Function() onOk,
  Widget title = const Text('Confirm'),
  Widget ok = const Text('Ok'),
  Widget cancel = const Text('Cancel'),
}) =>
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title,
          content: content,
          actions: <Widget>[
            TextButton(
              child: cancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: ok,
              onPressed: () {
                Navigator.of(context).pop();
                onOk();
              },
            ),
          ],
        );
      },
    );

Widget rdIconButton({
  required Widget icon,
  required String label,
  Function()? onPressed,
  IconAlignment iconAlignment = IconAlignment.start,
}) {
  return isDesktop
      ? TextButton.icon(
          iconAlignment: iconAlignment,
          icon: icon,
          label: Text(label),
          onPressed: onPressed,
        )
      : IconButton(
          icon: icon,
          tooltip: label,
          onPressed: onPressed,
        );
}
