import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_overview_provider.dart';
import 'package:flutter_uni_access/widgets/session_overview_card_widget.dart';
import 'package:flutter_uni_access/widgets/session_overview_filter_list_widget.dart';
import 'package:provider/provider.dart';

class SessionOverviewsWidget extends StatelessWidget {
  const SessionOverviewsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredSessions =
        Provider.of<SessionOverviewProvider>(context).sessions!;
    final filters =
        Provider.of<SessionOverviewProvider>(context, listen: false).filters!;

    return SingleChildScrollView(
      child: Column(
        children: [
          if (filters.isNotEmpty)
            const SessionOverviewFilterListWidget()
          else
            Container(),
          if (filteredSessions.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSessions.length,
              itemBuilder: (_, int index) => SessionOverviewCardWidget(
                session: filteredSessions[index],
              ),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.5,
              child: const Center(
                child: Text(
                  'Could not find any sessions',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
