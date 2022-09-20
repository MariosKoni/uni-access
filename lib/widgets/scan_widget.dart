import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/widgets/alert_result_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class ScanWidget extends StatelessWidget {
  const ScanWidget({Key? key}) : super(key: key);

  Future<void> _showAuthorizeAlertDialog(
    BuildContext context,
    int mode,
    String msg,
  ) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(
          const Duration(seconds: 2),
          () => Navigator.of(context).pop(true),
        );
        return AlertResultWidget(mode: mode, msg: msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (barcode, args) async {
        if (barcode.rawValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Barcode has no value'),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );

          return;
        }

        final result = barcode.rawValue!;
        HapticFeedback.vibrate();
        Provider.of<SessionProvider>(context, listen: false)
            .authorizeUser(result);

        final int rightsResult =
            Provider.of<SessionProvider>(context, listen: false).authResult;

        String msg = '';
        switch (rightsResult) {
          case 1:
            msg = 'User Authorized';
            break;
          case 2:
            msg = 'User was not authorized';
            break;
          case 3:
            msg = 'User is already authorized';
            break;
        }

        Navigator.of(context).pop();

        await _showAuthorizeAlertDialog(context, rightsResult, msg);
      },
    );
  }
}
