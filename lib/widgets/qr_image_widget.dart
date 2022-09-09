import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AlertQrImageWidget extends StatefulWidget {
  const AlertQrImageWidget({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  State<AlertQrImageWidget> createState() => _AlertQrImageWidgetState();
}

class _AlertQrImageWidgetState extends State<AlertQrImageWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: AlertDialog(
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
                  data: widget.id,
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
      ),
    );
  }
}
