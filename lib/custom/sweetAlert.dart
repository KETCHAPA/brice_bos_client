import 'package:sweetalert/sweetalert.dart';
import 'package:flutter/material.dart';

sweetalert(
    {@required BuildContext context,
    @required bool withConfirmation,
    String title,
    @required String subtitle,
    @required SweetAlertStyle type,
    Function onPressed,
    String successMessage,
    String errorMessage}) {
  if (withConfirmation) {
    SweetAlert.show(context,
        title: title,
        subtitle: subtitle,
        style: type,
        cancelButtonText: 'Annuler',
        confirmButtonText: 'Continuer',
        showCancelButton: true, onPress: (bool isConfirm) {
      if (isConfirm) {
        SweetAlert.show(context,
            subtitle: "Un instant...", style: SweetAlertStyle.loading);
        onPressed();
        new Future.delayed(new Duration(seconds: 2), () {
          SweetAlert.show(context,
              subtitle: successMessage, style: SweetAlertStyle.success);
        });
      } else {
        new Future.delayed(new Duration(seconds: 4), () {
          SweetAlert.show(context,
              subtitle: errorMessage,
              style: SweetAlertStyle.error);
        });
      }

      return true;
    });
  } else {
    SweetAlert.show(context, title: title, subtitle: subtitle, style: type,
        onPress: (_) {
      return onPressed ?? true;
    });
  }
}
