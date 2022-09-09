import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_overview_provider.dart';
import 'package:flutter_uni_access/widgets/filter_session_overview_form_option_widget.dart';
import 'package:provider/provider.dart';

class FiltersSessionOverviewDialogWidget extends StatelessWidget {
  const FiltersSessionOverviewDialogWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 100,
              width: MediaQuery.of(context).size.width / 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            'Filters',
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 10),
          FilterSessionOverviewFormOptionWidget(
            key: const Key('lab'),
            options:
                Provider.of<SessionOverviewProvider>(context, listen: false)
                    .labs!,
            titleOption: 'Lab',
          ),
          const SizedBox(
            height: 10,
          ),
          FilterSessionOverviewFormOptionWidget(
            key: const Key('subject'),
            options:
                Provider.of<SessionOverviewProvider>(context, listen: false)
                    .subjects!,
            titleOption: 'Subject',
          ),
        ],
      ),
    );
  }
}
