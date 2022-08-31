import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/session.dart';
import 'package:flutter_uni_access/providers/session_overview_provider.dart';
import 'package:flutter_uni_access/widgets/session_overview_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class SessionOverviewsListWidget extends StatefulWidget {
  const SessionOverviewsListWidget({Key? key}) : super(key: key);

  @override
  State<SessionOverviewsListWidget> createState() =>
      _SessionOverviewsListWidgetState();
}

class _SessionOverviewsListWidgetState
    extends State<SessionOverviewsListWidget> {
  final GlobalKey _one = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase([_one]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Session> filteredSessions =
        Provider.of<SessionOverviewProvider>(context).sessions!;
    final List<String> filters =
        Provider.of<SessionOverviewProvider>(context).filters!;

    return SingleChildScrollView(
      child: Column(
        children: [
          if (filters.isNotEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height / 16,
              width: MediaQuery.of(context).size.width,
              child: Showcase(
                key: _one,
                description: 'Tap it to remove filter',
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 5.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          filters.removeAt(index);
                        });
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 204, 170, 49),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(child: Text(filters[index])),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredSessions.length,
            itemBuilder: (_, int index) => SessionOverviewCardWidget(
              session: filteredSessions[index],
            ),
          ),
        ],
      ),
    );
  }
}
