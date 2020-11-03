import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

loadingWidget(BuildContext context) {
  ProgressDialog progress = ProgressDialog(context,
      type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
  progress.style(
      message: 'Un instant...',
      progressWidget: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset('img/loading5.gif'),
      ));

  return progress;
}
