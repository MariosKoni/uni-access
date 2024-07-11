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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.headlineSmall,
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
