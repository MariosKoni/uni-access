import 'package:flutter/material.dart';

class FiltersSessionOverviewDialogWidget extends StatelessWidget {
  const FiltersSessionOverviewDialogWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('W.I.P'),
        ],
      ),
    );
  }
}
