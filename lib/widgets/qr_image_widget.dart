import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AlertQrImageWidget extends StatelessWidget {
  const AlertQrImageWidget({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    // AlertDialog crashes on emulator
    // but should work on real device.
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      title: const Center(
        child: Text(
          'QR code',
          style: TextStyle(color: Colors.black),
        ),
      ),
      content: SizedBox(
        width: 200,
        height: 250,
        child: Column(
          children: [
            Center(
              child: QrImage(
                data: id,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            Tooltip(
              message: 'Show QR code',
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
